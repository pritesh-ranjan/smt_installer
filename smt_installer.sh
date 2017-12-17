#!/bin/bash

lipdf = 0

error()
{
	echo -e "\033[0;31m Oops! ERROR" | tee -a smt_installer.log
	echo -e "\033[0;31m Please check if you have a working internet connection and you are authorised to install programs in this system" | tee -a smt_installer.log
	kill "$!"
	exit
}

chk_internet_connection() 
{
	ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` 2> /dev/null && echo "Internet is working" || error
}

spinner()
{
	local i sp n
    echo ' '
    sp='  /-\|'
    n=${#sp}
    printf ' '
    while sleep 0.1; do
        printf "%s\b" "${sp:i++%n:1}"
    done
}


linux_packages_install()
{
	echo 'Updating apt-get' | tee -a smt_installer.log
	spinner &
	sudo apt-get -y update   || error
	echo 'Downloading and installing all required packages' | tee -a smt_installer.log
	sudo apt-get install -y g++ git automake libtool zlib1g-dev libboost-all-dev libbz2-dev liblzma-dev libgoogle-perftools-dev python-dev graphviz imagemagick cmake build-essential subversion autoconf unzip   || error
	sudo apt-get install -y make  
	sudo apt-get install -y unzip  
	kill "$!"
	lipdf = 1

	echo "All packages downloded" | tee -a smt_installer.log
}



indic_nlp_library_install()
{
	if [ -d "indic_nlp_library/src" ]; then
		echo -e '\033[0;32m indicnlp found, skipping installation \e[0m' | tee -a smt_installer.log
		return 1
	fi
	echo "Downloading indic_nlp_library" | tee -a smt_installer.log
	spinner &
	git clone https://github.com/anoopkunchukuttan/indic_nlp_library.git  
	sudo cp indic_nlp_library/src/indicnlp/tokenize/indic_tokenize.py /usr/local/bin/indic_tokenize.py 
	echo "Indic nlp library successfully installed" | tee -a smt_installer.log
	kill "$!"
}


#use if current way does not work
old_boost_cpp_libraries_install()
{		
	spinner &
	echo "Downloading boost_cpp_libraries" | tee -a smt_installer.log
	wget https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.gz  
	echo 'unpacking boost' | tee -a smt_installer.log
	tar zxvf boost_1_64_0.tar.gz  
	cd boost_1_64_0/
	echo 'Setting up boost' | tee -a smt_installer.log
	./bootstrap.sh   || error
	#boost install
	echo 'Installing Boost cpp libraies' | tee -a smt_installer.log
	./b2   || error
	./b2 -j4 --prefix=${PWD} --libdir=${PWD}/lib64 --layout=system link=static install
	echo "done" | tee -a smt_installer.log
	#./b2 -j4 --prefix=${PWD} --libdir=${PWD}/lib64 --layout=system link=static install
	cd ..
	kill "$!"

}

old_xmlrpc_install()
{
	echo "Downloading xmlrpc for moses2/moses_server " | tee -a smt_installer.log
	wget -O xmlrpc-c-1.39.12.tgz https://sourceforge.net/projects/xmlrpc-c/files/Xmlrpc-c%20Super%20Stable/1.39.12/xmlrpc-c-1.39.12.tgz/download  
	tar -xvzf xmlrpc-c-1.39.12.tgz || error
	cd xmlrpc-c-1.39.12
	./configure --prefix=$wdirect/xmlrpc || error
	make || error
	make install || error
	echo "xmlrpc installed " | tee -a smt_installer.log
	cd ..

}


giza_pp_install()
{
	spinner &
	if [ -d "bin/" ]; then
		echo -e '\033[0;32m giza-pp binaries found, skipping installation \e[0m' | tee -a smt_installer.log
		kill "$!"
		return 1
	fi
	sudo rm giza-pp/
	echo "Downloading giza-pp" | tee -a smt_installer.log
	git clone https://github.com/moses-smt/giza-pp.git  
	cd giza-pp
	echo 'Compiling giza++'
	make   || error
	cd ../
	mkdir bin | tee -a smt_installer.log
	echo 'Installing giza++' | tee -a smt_installer.log
	cp giza-pp/GIZA++-v2/GIZA++ giza-pp/GIZA++-v2/snt2cooc.out giza-pp/GIZA++-v2/snt2plain.out giza-pp/GIZA++-v2/plain2snt.out giza-pp/mkcls-v2/mkcls bin

	
	sudo cp giza-pp/GIZA++-v2/GIZA++ /usr/local/bin/GIZA++
	sudo cp giza-pp/GIZA++-v2/snt2cooc.out /usr/local/bin/snt2cooc.out
	sudo cp giza-pp/GIZA++-v2/snt2plain.out /usr/local/bin/snt2plain.out
	sudo cp giza-pp/GIZA++-v2/plain2snt.out /usr/local/bin/plain2snt.out
	sudo cp giza-pp/mkcls-v2/mkcls /usr/local/bin/mkcls || error
	kill "$!"

}

irstlm_install()
{
	spinner &
	if [ -d "irstlm/bin" ]; then
		echo -e '\033[0;32m irstlm binaries found, skipping installation \e[0m' | tee -a smt_installer.log
		kill "$!"
		return 1
	fi
	sudo rm irstlm/ irstlm-5.80.08/
	echo "Downloading irstlm" | tee -a smt_installer.log
	sudo apt-get install irstlm
	wget -O irstlm.zip https://sourceforge.net/projects/irstlm/files/irstlm/irstlm-5.80/irstlm-5.80.08.zip/download  
	echo 'unpacking irstlm..' | tee -a smt_installer.log
	unzip irstlm.zip   || error
	cd irstlm-5.80.08/trunk || error
	echo 'Setting up irstlm...' | tee -a smt_installer.log
	./regenerate-makefiles.sh   || error
	./regenerate-makefiles.sh   || error

	./configure --prefix=$wdirect/irstlm   || error
	echo 'compiling....'  | tee -a smt_installer.log
	make  
	echo 'Installing irstlm....' | tee -a smt_installer.log
	make install   || error
	kill "$!"
	cd ../../

}
srilm_install()
{
	spinner &
	if [ -d "srilm/bin" ]; then
		echo -e '\033[0;32m srilm binaries found, skipping installation \e[0m' | tee -a smt_installer.log
		kill "$!"
		return 1
	fi
	sudo rm srilm/
	echo "Downloading srilm" | tee -a smt_installer.log
	wget --no-check-certificate 'https://www.dropbox.com/s/mnfgpaw0oyh81gy/srilm%20%281%29.zip?dl=1' -O srilm.zip  
	echo 'unpacking srilm..' | tee -a smt_installer.log
	unzip srilm.zip  
	cd srilm
	echo 'Setting up srilm...' | tee -a smt_installer.log
	make || error
	echo 'Installing srilm....' | tee -a smt_installer.log
	make World || error
	kill "$!"
	cd ..

}

xmlrpc_install()
{
	echo "Downloading xmlrpc for moses2/moses_server " | tee -a smt_installer.log
	sudo apt-get install -y libxmlrpc-c++8-dev libxmlrpc-c++8v5 libxmlrpc-core-c3 libxmlrpc-core-c3-dev xmlrpc-api-utils
	echo "xmlrpc installed " | tee -a smt_installer.log
	

}

moses_install()
{
	spinner &
	echo "Downloading mosesdecoder toolkit" | tee -a smt_installer.log
	git clone https://github.com/moses-smt/mosesdecoder.git  
	echo 'Compiling and Installing Mosesdecoder with giza++ ; boost ; irstlm, etc.' | tee -a smt_installer.log
	cd mosesdecoder/
	./bjam --with-irstlm=$wdirect/irstlm --with-giza-pp=$wdirect/bin -j4   

	sudo cp bin/build_binary /usr/local/bin/build_binary
	sudo cp bin/moses /usr/local/bin/moses
	sudo cp scripts/recaser/train-truecaser.perl /usr/local/bin/train-truecaser.perl
	sudo cp scripts/tokenizer/tokenizer.perl /usr/local/bin/tokenizer.perl 
	sudo cp scripts/recaser/truecase.perl /usr/local/bin/truecase.perl
	sudo cp scripts/training/clean-corpus-n.perl /usr/local/bin/clean-corpus-n.perl
	sudo cp scripts/training/mert-moses.pl /usr/local/bin/mert-moses.pl 
	echo "moses installed successfully" | tee -a smt_installer.log
	kill "$!"
	cd ..

}

moses2_install()
{
	spinner &
	if [ ! -d "mosesdecoder/" ]; then
		echo "Downloading mosesdecoder toolkit" | tee -a smt_installer.log
		git clone https://github.com/moses-smt/mosesdecoder.git  
	fi
	xmlrpc_install || error
	# old_xmlrpc_install
	cd mosesdecoder
	
	./bjam --with-irstlm=$wdirect/irstlm --with-giza-pp=$wdirect/bin -j4

	sudo cp bin/build_binary /usr/local/bin/build_binary
	sudo cp bin/moses /usr/local/bin/moses
	sudo cp scripts/recaser/train-truecaser.perl /usr/local/bin/train-truecaser.perl
	sudo cp scripts/tokenizer/tokenizer.perl /usr/local/bin/tokenizer.perl 
	sudo cp scripts/recaser/truecase.perl /usr/local/bin/truecase.perl
	sudo cp scripts/training/clean-corpus-n.perl /usr/local/bin/clean-corpus-n.perl
	sudo cp scripts/training/mert-moses.pl /usr/local/bin/mert-moses.pl 
	
	echo "moses2 installed successfully" | tee -a smt_installer.log
	cd ..

	kill "$!"

}

test_moses()
{
	spinner &
	if [ ! -d "sample-models/" ]; then
		echo "Downloding test cases" | tee -a smt_installer.log
		wget http://www.statmt.org/moses/download/sample-models.tgz    || chk_internet_connection 2> /dev/null
		tar xzf sample-models.tgz   || error
	fi
	echo 'Validating install' | tee -a smt_installer.log
	cd sample-models
	../mosesdecoder/bin/moses -f phrase-model/moses.ini < phrase-model/in > out   || error
	echo "moses installation successful" | tee -a smt_installer.log
	notify-send "moses installation successful" 
	
	#feature yet to release
	cd ..
	clear
	cat smt_installer.log


	kill "$!"

}



default_install() 
{
  echo "Installing mosesdecoder toolkit alongwith giza++, irstlm and boost c++ libraries " | tee -a smt_installer.log
  #spinner &
  linux_packages_install
  giza_pp_install
  irstlm_install
  moses_install
  test_moses
  #kill "$!"

   
}

recompile_moses()
{
	cd mosesdecoder/
	spinner &
	./bjam --with-giza-pp=$HOME/bin -j4   || error
	kill "$!"
	cd ..

}



trap "echo 'exiting installer';exit" 0 1 2 5 15

chk_internet_connection 2> /dev/null

echo "loading installer" | tee -a smt_installer.log
sudo apt-get install -y dialog   || chk_internet_connection 2> /dev/null

echo ''




echo "Please choose installation directory"
sleep 3
wdirect=$(zenity --file-selection --directory)
sleep 1

mkdir -p ${wdirect} || error
cd ${wdirect}
echo ""
#echo "enter password"

sudo echo "working directory" | tee -a smt_installer.log
pwd 

echo ''
sleep 1



DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0




advanced_options()
{
  #choices=`/usr/bin/dialog --stdout --checklist "Choose additional softwares" 60 70 6         1 "mosesdecoder with boost and giza++" on         2 "moses2/moses-server and srilm with boost and giza++ " off         3 irstlm on         4 srilm off         5 indic_nlp_library off`
  #spinner &
 
  while true; do
  exec 3>&1
  selection=$(dialog \
    --clear \
    --cancel-label "Exit" \
    --checklist "Choose additional softwares" 60 70 6 \
    1 indic_nlp_library off \
    2 srilm off  \
    3 "irstlm (for moses on ubuntu 16.04 and below )" on \
    4 "just irstlm, not integretable with moses (for ubuntu 17.10 and above) " off \
    5 "moses, moses2/moses-server, srilm with boost and giza++ " off \
    6 "mosesdecoder with boost, giza++ and kenlm" on \
    2>&1 1>&3)
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL)
      clear
      echo "Installer terminated."
      exit
      ;;
    $DIALOG_ESC)
      clear
      echo "Installer aborted." >&2
      exit 1
      ;;
  esac
  if [ $? -eq 0 ]
    then  
               
        for choice in $selection
                 do                 
                      echo "You chose: $choice"
                      #clear
                      case $choice in
                      0 )
                        #clear
                        echo "Installer terminated."
                        ;;
                      1 )
                        echo 1
                          indic_nlp_library_install
                          #test_moses
                        ;;
                      2 )
                        echo 2
                          if [[ $lipdf -eq 0 ]]; then
							linux_packages_install
						  fi
                          lipdf=1
                          srilm_install
                        ;;
                      3 )
                        echo 3
                         if [[ $lipdf -eq 0 ]]; then
							linux_packages_install
						  fi
                          lipdf=1
                         irstlm_install
                        ;;
                      4 )
                        echo 4
                         sudo apt-get install irstlm
                        ;;
                      5 )
                        echo 4
                         if [[ $lipdf -eq 0 ]]; then
							linux_packages_install
						  fi
                          lipdf=1
                          #old_boost_cpp_libraries_install
						 giza_pp_install
						 srilm_install
					     moses2_install
					     test_moses
                        ;;
                      6 )
                          echo 5
                          if [[ $lipdf -eq 0 ]]; then
							linux_packages_install
						  fi
                          lipdf=1
                          # old_boost_cpp_libraries_install
			  			  giza_pp_install
			              moses_install
			              test_moses
                          
        
                        ;;
                    esac
                                                
                 done
   else         echo cancel selected

   fi
   #kill "$!"
  
   exit
  
done

}


while true; do
  exec 3>&1
  selection=$(dialog \
    --backtitle "Mosesdecoder toolkit installer" \
    --title "Options" \
    --clear \
    --cancel-label "Exit" \
    --menu "Please select installation method:" $HEIGHT $WIDTH 4 \
    "1" "Default: install only moses with giza++ and irstlm" \
    "2" "Advanced: Choose your configuration" \
    "3" "Run bjam" \
    2>&1 1>&3)
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL)
      clear
      echo "Installer terminated."
      exit
      ;;
    $DIALOG_ESC)
      clear
      echo "Installer aborted." >&2
      exit 1
      ;;
  esac
  case $selection in
    0 )
      clear
      echo "Installer terminated."
      ;;
    1 )
      default_install
      ;;
    2 )
      advanced_options
      ;;
    3 )
        recompile_moses
        
      ;;
  esac
done
clear





