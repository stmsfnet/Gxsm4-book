#!/bin/bash
echo "Removing temporary files generated during latex compilation"
pushd src/ 
rm -rf *.dvi *.log *.aux *.idx *.ilg *.ind *.bbl *.bcf *.blg *.out *.toc *.bak latex/*.aux 
popd
echo "Done."

