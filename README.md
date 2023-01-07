# Gxsm4 manual

This is the README.md for the MANUAL of GXSM4, the open source SPM solution.

The code is based on Stefan Schröder's GXSM3-book which is available here: 

  ttps://github.com/StefanSchroeder/Gxsm3-book 

and earlier versions of GXSM.

The GXSM4 project is located here:

	https://github.com/pyzahl/Gxsm4

## Quick-Install

	# Download all the necessary packages (on debian-type systems)
	make prepare
	# Build the manual
	make
	# Open the manual
	make view 


## Gxsm-Manual

It contains _most_ of the files to generate the
PDF-manual for Gxsm (but not the plug-in documentation
which is embedded in the plug-ins).

Run 
	
	make prepare # to install build-dependencies
	make # to generate Gxsm-4.0-Manual.pdf
	make clean # to remove build-artifacts
	make view # to view the PDF
	make install # install the PDF to /usr/local

FIXME: HTML generation doesnt work 05/2015.
Run 'make html' to create a HTML version in 'html'.

The document is pretty sophisticated and requires a 
number of packages as dependencies. The bootstrap-scripts
should take care of retrieving all the necessary 
latex-packages. If your latex-distro is not supported,
please let us know in the forums. Please contribute
the instructions for your distro if you have been
able to figure the dependencies out yourself.

Consider using Eisvogel:

https://github.com/Wandmalfarbe/pandoc-latex-template

pandoc-latex-environment:
  noteblock: [note]
  tipblock: [tip]
  warningblock: [warning]
  cautionblock: [caution]
  importantblock: [important]
...
