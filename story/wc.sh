grep -v section -h $(ls *.tex | grep -v story.tex) | grep -v '%' | sed 's/\\\w\+\(\[.*\]\)*{.*}//g' | wc -w
