all: book graph

graph: story.dot
	dot story.dot > output/story.png -Tpng

book: story/*.tex
	mkdir build output -p
	cd story && latexmk -aux-directory=../build -output-directory=../output story.tex -pdf -dvi-
	# https://linuxfr.org/forums/programmationautre/posts/problème-dimpression-dun-document-latex-a5-sur-a4

.PHONY: clean
clean:
	rm -rf build story.png output/{story.aux,story.dvi,story.fls,story.log}
