#!/bin/bash
echo "$1" "$2" "$3"
if [ $(basename "$1") = "src/README" ]; then
	pandoc "$3" -o "$4"/index.html "$1" ;
else
	pandoc "$3" -o "$2" "$1";
fi

