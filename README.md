# smt_installer

A shell script installer for statistical machine translation tools like mosesdecoder, moses2, giza++, irstlm, srilm, indic nlp library. This script uses "dialog" for its terminal gui. All linux packages are installed using apt-get only.
Firstly the script check for a stable internet connection, then asks for the sudo password and finally asks to choose where to install. 
The installer is highly configurable and comes with the following options: 
    1. Default: Only Moses, giza-pp, boost and irstlm installation
    2. Advanced: Choose between the different options what to install (like mose2/moses-server, srilm, kenlm, irstlm, indic nlp library)

Mosesdecoder is a statistical machine translation toolkit that allows one to
automatically train translation models for any language pair. All we need is a
collection of translated texts.

Use as : bash smt_installer.sh

PS: This is just an installer, all the softwares installed by this script have been developed by other people. 
