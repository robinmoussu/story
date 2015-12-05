all: book graph

graph: story.dot
	dot story.dot > output/story.png -Tpng

book: story/*.tex
	mkdir build output -p
	cd story && latexmk -aux-directory=../build -output-directory=../build story.tex -dvi- -pdf
	ln build/story.pdf output/ -f
	cd output && pdfbook --short-edge story.pdf

.PHONY: clean realclean
clean:
	rm -rf build story.png

realclean: clean
	rm -rf output
