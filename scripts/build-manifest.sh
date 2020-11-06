#!/bin/bash
echo "$1"
echo "$2"
for f in "$1"/*.md;
do
	echo "$f"
	[[ "$f" == "README.md" ]] && continue;
	[[ -f "$f" ]] && echo -e "$f" >> "$2";
done
jq -R -s 'split("\n")' < "$2" | jq '.[:-1]' > "$2".json

