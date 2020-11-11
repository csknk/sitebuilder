#!/bin/bash
FILE_NAME="$1"
EXT=${FILE_NAME#*.}
[[ "${EXT}" != css ]] && { echo "Compression on CSS only. Ingnoring."; exit 0; }

FILE_BASE=$(basename "${FILE_NAME}")

# Remove spaces but not if enclosed between "", .., #., :; #{ etc. 
sed -ir 's/\([#\.\"'\'':].*[\.\"'\'';{]\)\|\s*/\1/g' "${FILE_NAME}" 

# Remove newlines
tr -d '\n' < "${FILE_NAME}" > /tmp/"${FILE_BASE}"
mv /tmp/"${FILE_BASE}" "${FILE_NAME}" 



