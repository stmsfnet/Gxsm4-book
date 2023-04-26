#!/bin/bash
# This bash script generates the manual for Gxsm.
# 1. Look for embedded plugin documentation.
# 2. Call pdflatex
# 3. Generate index.
#
# Don't forget to run this script twice to get up-to-date references.
# 

if [ -z `which pdflatex` ] ; then
    echo "FATAL: You don't have pdflatex. Sorry."
    exit
fi

# We want to include the embedded documentation from the plug-in's sources
# Make sure we have a soft link to the plug-ins folder:
if test -L "plug-ins"; then
    echo "Found symlink to plug-ins: OK"
else
    echo "Oh, plug-ins folder not there yet..."
    echo "--------"
    ls -al Gxsm-4.0
    echo "--------"
    
    # Take a guess
    if [ -d ../gxsm4-git/plug-ins ] ; then
        echo "a) Symlinking plug-ins of Gxsm-4.0."
        ln -s ../gxsm4-git/plug-ins .
    # Take another guess
    elif [ -d ../Gxsm-4.0/plug-ins ] ; then
        echo "b) Symlinking plug-ins of Gxsm-4.0."
        ln -s ../Gxsm-4.0/plug-ins .
    elif [ -d ./Gxsm-4.0/plug-ins ] ; then
        echo "c) Symlinking plug-ins of Gxsm-4.0."
        ln -s ./Gxsm-4.0/plug-ins .
    else
        look_for_plugins=$(find ~ -name plug-ins | grep Gxsm | head -1)
        if [ -d $look_for_plugins ] ; then
	    echo "d) Symlinking plug-ins of Gxsm-4.0."
            ln -v -s "$look_for_plugins" .
        else
            # All attempts to find the plug-ins folder failed.
            echo "Unable to find plug-ins. They will not be included in the manual."
        fi
    fi
fi

# Now harvest the plug-ins.
./helpers/docuscangxsmplugins.pl | tail - -n14 > docuscan.log

pushd src/
latexmk -pdf Gxsm-4.0-Manual.tex --shell-escape
popd

cat docuscan.log

echo "-------------------------------------------------------------------"
echo -n "Result of PDF-generation (./Gxsm-4.0-Manual.pdf): "
if [ -f ./src/Gxsm-4.0-Manual.pdf ] ; then
   echo "SUCCESS"
   mv -v ./src/Gxsm-4.0-Manual.pdf .
else
   echo "ERROR"
fi
echo "-------------------------------------------------------------------"

echo "Done."

