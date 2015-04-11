#!/bin/bash

LIST=$(list-all-repos.pl $1 | sed -n '/^2/{s/.* //;p}')

for i in $LIST; do
	DIR="${i%.git}"
	[ -d "$DIR" ] || git clone rich:$i
done

