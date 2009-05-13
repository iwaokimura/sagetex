SHELL=/bin/bash
pkg=sagetexpackage
dest=/home/drake/texmf/tex/latex/sagetex/
dtxs=$(wildcard *.dtx)
# the subdir stuff makes the tarball have the directory correct
srcs=../sagetex/example.tex ../sagetex/README ../sagetex/sagetexpackage.dtx ../sagetex/sagetexpackage.ins
ver=2.1

.SUFFIXES:

all: sagetex.sty sagetex.py example.pdf $(pkg).pdf

# just depend on the .ind file, since we'll make the .gls and .ind together
$(pkg).pdf: $(dtxs) $(pkg).ind
	latex $(pkg).dtx
	sage $(pkg).sage
	latex $(pkg).dtx
	sage $(pkg).sage
	latex $(pkg).dtx
	pdflatex $(pkg).dtx

example.pdf: example.tex sagetex.sty sagetex.py
	latex example.tex
	sage example.sage
	latex example.tex
	pdflatex example.tex

%.ind: $(dtxs)
	latex $(pkg).dtx
	sed -e 's/usage|hyperpage/usagehyperpage/g' -i sagetexpackage.idx
	makeindex -s gglo.ist -o $(pkg).gls $(pkg).glo 
	makeindex -s gind.ist -o $(pkg).ind $(pkg).idx

sagetex.sty: py-and-sty.dtx
	yes | latex $(pkg).ins

sagetex.py: py-and-sty.dtx
	yes | latex $(pkg).ins

clean: 
	latexcleanup clean .
	rm -fr sage-plots-for-* E2.sobj *.pyc sagetex.tar.gz sagetex.py sagetex.pyc sagetex.sty makestatic.py sagetexparse.py extractsagecode.py dist MANIFEST

# the following bit requires SHELL=bash
auxclean:
	rm -f {$(pkg),example}.{glo,gls,aux,sout,out,toc,dvi,pdf,ps,log,ilg,ind,idx,sage}

install: sagetex.sty sagetex.py
	cp sagetex.sty $(dest)

# make a tarball suitable for CTAN uploads, or for someone who knows how
# to handle .dtx files
ctandist: all
	@echo
	@echo Did you turn off Imagemagick in example.tex?
	@echo
	tar zcf sagetex.tar.gz $(srcs) ../sagetex/example.pdf ../sagetex/sagetexpackage.pdf

# otherwise, make gets confused since there's a file named "test"
.PHONY: test
test:
	./test

# make a source distribution, used for building the spkg
dist: all
	python setup.py sdist --formats=tar

