# smt_installer

A shell script installer for statistical machine translation tools like mosesdecoder, moses2, giza++, irstlm, srilm, indic nlp library. This script uses "dialog" for its terminal based graphical user interface. All linux packages are installed using apt-get only.
 
The installer is highly configurable and comes with the following options: 
    1. Default: Only Moses, giza-pp, boost and irstlm installation
    2. Advanced: Choose between the different options what to install (like mose2/moses-server, srilm, kenlm, irstlm, indic nlp library)

Mosesdecoder is a statistical machine translation toolkit that allows one to
automatically train translation models for any language pair. All we need is a
collection of translated texts.

Irstlm ver 5.8 fails to compile and install in Ubunto 17.10 and above. So it is reccomeded to use standalone irstlm from apt package manager. Also on Ubuntu systems 12.04 and lower use manual methods for boost cpp libraries installation.

Run as : bash smt_installer.sh


########################################

To add more installation functionality for more programs, go through the following steps:

	1. Add a bash function just before moses_install() function

	2. Write the spinner command as the first coomand in your function ending with and "&"

	3. Add the installation commands for the installation candidate. To get absolute path for the installation directory use variable "$wdirect"

	4. Please add echo statements where ever necessary to show status of installation, in the following format:
						echo 'Compiling xyz' | tee -a  $wdirect/smt_installer.log

	5. At the end of the installation script kill the spinner via kill "$!"

	6. It is reccomended to install program binaries and executable scripts to /usr/local/bin for easy access using:
						sudo cp bin/xyz /usr/local/bin/xyz 

	7. Now finally add the option to install the tool in the dialog main menu or advanced configuration menu.



PS: This is just an installer, all the softwares installed by this script have been developed by other people. 
