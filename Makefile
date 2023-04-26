#
# This file is part of Gxsm
#

INSTALLDIR=/usr/local/share/gxsm4

.PHONY: html markdown pages pdfmanual

all: pdfmanual 

prepare:
	bash helpers/bootstrap_buildenvironment.sh

pdfmanual:
	bash helpers/make-gxsm-manual.sh

install: 
	install -o root -g root Gxsm-4.0-Manual.pdf $(INSTALLDIR)

clean:
	bash helpers/make-clean.sh

#html:
#	latex2html -local_icons -antialias -antialias_text -mkdir -dir html -split +1 -prefix gxsm- Gxsm-4.0-Manual

view:
	xdg-open Gxsm-4.0-Manual.pdf

markdown:
	pandoc \
		--resource-path docs \
		--number-sections \
		--listings \
		--pdf-engine pdflatex --toc \
		--include-in-header ../markdown/titlesec.tex \
		--template ../markdown/pandoc.template \
		-o test.pdf \
		docs/*Gxsm*.md 

pages:
	mkdocs build

