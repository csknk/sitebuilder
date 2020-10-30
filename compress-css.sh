#!/bin/bash

compress() {
	# Remove all posix blank (whitespace) characters
	sed -i 's/[[:space:]]//g' "$@"
	# Remove all Comments
	sed -i 's/\/\*[^*]*\*\///g' "$@"
	# Remove all newlines
	tr -d '\n' < "$@"
}

compress "$@"

