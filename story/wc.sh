grep -v section -h *.tex | grep -v '%' | sed 's/\\\w\+\(\[.*\]\)*{.*}//g' | wc -w
