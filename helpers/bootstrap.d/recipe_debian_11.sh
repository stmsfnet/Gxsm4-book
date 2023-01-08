
echo "This is the recipe for Debian 11."

echo "Step 1"
apt update
echo "Step 2"
apt -y install texlive-latex-recommended \
	texlive-latex-base \
	texlive-fonts-recommended \
	texlive-latex-extra \
	texlive-fonts-extra \
	texlive-bibtex-extra \
	latex2html \
	make \
	latexmk \
	biber \
	pandoc mkdocs mkdocs-nature \
	mkdocs-bootstrap \
	inkscape
echo "Step 3"
pip install mkdocs-windmill
