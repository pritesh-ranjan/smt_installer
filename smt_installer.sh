#!/bin/bash

error()
{
	echo -e "\033[0;31m Oops! ERROR"
	echo -e "\033[0;31m Please check if you have a working internet connection and you are authorised to install programs in this system"
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
	echo 'Updating apt-get'
	spinner &
	sudo apt-get -y update &> /dev/null || error
	echo 'Downloading and installing all required packages'
	sudo apt-get install -y g++ git automake libtool zlib1g-dev libboost-all-dev libbz2-dev liblzma-dev libgoogle-perftools-dev python-dev graphviz imagemagick cmake build-essential subversion autoconf &> /dev/null || error
	sudo apt-get install -y make &> /dev/null
	sudo apt-get install -y unzip &> /dev/null
	kill "$!"
	echo "All packages downloded"
}



indic_nlp_library_install()
{
	echo "Downloading indic_nlp_library"
	spinner &
	git clone https://github.com/anoopkunchukuttan/indic_nlp_library.git &> /dev/null || error
	sudo cp indic_nlp_library/src/indicnlp/tokenize/indic_tokenize.py /usr/local/bin/indic_tokenize.py 
	echo "Indic nlp library successfully installed"
	kill "$!"
}

boost_cpp_libraries_install()
{
	spinner &
	echo "Downloading boost_cpp_libraries"
	wget http://downloads.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.tar.gz &> /dev/null || error || error
	echo 'unpacking boost'
	tar zxvf boost_1_55_0.tar.gz &> /dev/null || error
	cd boost_1_55_0
	echo 'Setting up boost'
	./bootstrap.sh &> /dev/null || error
	#boost install
	echo 'Installing Boost cpp libraies'
	./b2 -j4 --prefix=$PWD --libdir=$PWD/lib64 --layout=system link=static install &> /dev/null || error
	cd ..
	kill "$!"

}

giza_pp_install()
{
	spinner &
	echo "Downloading giza-pp"
	git clone https://github.com/moses-smt/giza-pp.git &> /dev/null || error
	cd giza-pp
	echo 'Compiling giza++'
	make &> /dev/null || error
	cd ../
	mkdir bin
	echo 'Installing giza++'
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
	echo "Downloading irstlm"
	wget -O irstlm.zip https://sourceforge.net/projects/irstlm/files/irstlm/irstlm-5.80/irstlm-5.80.08.zip/download &> /dev/null || error
	echo 'unpacking irstlm..'
	unzip irstlm.zip &> /dev/null || error
	cd irstlm-5.80.08/trunk || error
	echo 'Setting up irstlm...'
	./regenerate-makefiles.sh &> /dev/null || error
	./regenerate-makefiles.sh &> /dev/null || error

	./configure --prefix=$wdirect/irstlm &> /dev/null || error
	echo 'compiling....' 
	make &> /dev/null
	echo 'Installing irstlm....'
	make install &> /dev/null || error
	kill "$!"
	cd ..

}
srilm_install()
{
	spinner &
	echo "Downloading srilm"
	wget --no-check-certificate 'https://doc-08-7s-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/0r058qu02u5n9prn6frd4bm8vk820fgc/1510768800000/03823376703766152229/*/1Wh8dvGI47AebYz1ZBxl8784YtrZ_cIwY?e=download' -O srilm.zip &> /dev/null || error
	echo 'unpacking srilm..'
	unzip srilm.zip &> /dev/null
	cd srilm
	echo 'Setting up srilm...'
	make || error
	echo 'Installing srilm....'
	make World || error
	kill "$!"
	cd ..

}

xmlrpc_install()
{
	echo "Downloading xmlrpc for moses2/moses_server "
	wget -O xmlrpc-c-1.39.12.tgz https://sourceforge.net/projects/xmlrpc-c/files/Xmlrpc-c%20Super%20Stable/1.39.12/xmlrpc-c-1.39.12.tgz/download &> /dev/null || error
	tar -xvzf xmlrpc-c-1.39.12.tgz || error
	cd xmlrpc-c-1.39.12
	./configure --prefix=$wdirect/xmlrpc || error
	make || error
	make install || error
	echo "xmlrpc installed "
	cd ..

}

moses_install()
{
	spinner &
	echo "Downloading mosesdecoder toolkit"
	git clone https://github.com/moses-smt/mosesdecoder.git &> /dev/null || error
	echo 'Compiling and Installing Mosesdecoder with giza++ ; boost ; irstlm, etc.'
	cd mosesdecoder/
	./bjam --with-giza-pp=$HOME/bin -j4 &> /dev/null || error
	./bjam --with-boost=$wdirect/boost_1_55_0 --with-irstlm=$wdirect/irstlm --with-giza-pp=$wdirect/bin -j4 &> /dev/null || error
	sudo cp mosesdecoder/bin/build_binary /usr/local/bin/build_binary
	sudo cp mosesdecoder/bin/moses /usr/local/bin/moses
	sudo cp mosesdecoder/scripts/recaser/train-truecaser.perl /usr/local/bin/train-truecaser.perl
	sudo cp mosesdecoder/scripts/tokenizer/tokenizer.perl /usr/local/bin/tokenizer.perl 
	sudo cp mosesdecoder/scripts/recaser/truecase.perl /usr/local/bin/truecase.perl
	sudo cp mosesdecoder/scripts/training/clean-corpus-n.perl /usr/local/bin/clean-corpus-n.perl
	sudo cp mosesdecoder/scripts/training/mert-moses.pl /usr/local/bin/mert-moses.pl 
	echo "moses installed successfully"
	kill "$!"
	cd ..

}

moses2_install()
{
	spinner &
	echo "Downloading mosesdecoder toolkit"
	git clone https://github.com/moses-smt/mosesdecoder.git &> /dev/null
	xmlrpc_install || error
	cd mosesdecoder
	./bjam --with-xmlrpc-c=$wdirect/xmlrpc -j4 || error
	./bjam --with-boost=$wdirect/boost_1_55_0 --with-irstlm=$wdirect/irstlm --with-giza-pp=$wdirect/bin --with-xmlrpc-c=$wdirect/xmlrpc --with-srilm=$wdirect/srilm -j4 || error || error
	sudo cp mosesdecoder/bin/build_binary /usr/local/bin/build_binary
	sudo cp mosesdecoder/bin/moses /usr/local/bin/moses2
	sudo cp mosesdecoder/scripts/recaser/train-truecaser.perl /usr/local/bin/train-truecaser.perl
	sudo cp mosesdecoder/scripts/tokenizer/tokenizer.perl /usr/local/bin/tokenizer.perl 
	sudo cp mosesdecoder/scripts/recaser/truecase.perl /usr/local/bin/truecase.perl
	sudo cp mosesdecoder/scripts/training/clean-corpus-n.perl /usr/local/bin/clean-corpus-n.perl
	sudo cp mosesdecoder/scripts/training/mert-moses.pl /usr/local/bin/mert-moses.pl 
	
	echo "moses2 installed successfully"
	cd ..

	kill "$!"

}

test_moses()
{
	spinner &
	echo "Downloding test cases"
	wget http://www.statmt.org/moses/download/sample-models.tgz  &> /dev/null || error
	echo 'Validating install'
	tar xzf sample-models.tgz &> /dev/null || error
	cd sample-models
	~/smt/mosesdecoder/bin/moses -f phrase-model/moses.ini < phrase-model/in > out &> /dev/null || error
	echo "moses installation successful"
	notify-send moses installation successful
	cd ..

	kill "$!"

}



default_install() 
{
  echo "Installing mosesdecoder toolkit alongwith giza++, irstlm and boost c++ libraries "
  #spinner &
  linux_packages_install
  boost_cpp_libraries_install
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
	./bjam --with-giza-pp=$HOME/bin -j4 &> /dev/null || error
	kill "$!"
	cd ..

}



#trap "clear" 0 1 2 5 15

chk_internet_connection 2> /dev/null

sleep 1

echo "Please choose installation directory"
sleep 3
wdirect=$(zenity --file-selection --directory)
sleep 1

mkdir -p ${wdirect} || error
cd ${wdirect}
echo ""
#echo "enter password"

sudo echo "working directory"
pwd

echo ''
sleep 1
#spinner &
sudo apt-get install -y dialog &> /dev/null || error

#kill "$!"


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
    1 "mosesdecoder with boost, giza++ and kenlm" on \
    2 "moses2/moses-server and srilm with boost and giza++ " off \
    3 irstlm on \
    4 srilm off \
    5 indic_nlp_library off \
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
                      clear
                      case $choice in
                      0 )
                        clear
                        echo "Installer terminated."
                        ;;
                      1 )
                        echo 1
                          linux_packages_install
                          boost_cpp_libraries_install
			  giza_pp_install
			  moses_install
			  test_moses
                        ;;
                      2 )
                        echo 2
                          linux_packages_install
                          boost_cpp_libraries_install
			  giza_pp_install
			  srilm_install
			  moses2_install
			  test_moses
                        ;;
                      3 )
                        echo 3
                        linux_packages_install
                        irstlm_install
                        ;;
                      4 )
                        echo 4
                        linux_packages_install
                        srilm_install
                        ;;
                      5 )
                          echo 5
                          indic_nlp_library_install
        
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
echo "installer terminated"
notify-send installer terminated




