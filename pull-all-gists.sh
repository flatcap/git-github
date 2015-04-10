#!/bin/bash

LIST=$(list-all-gists.pl $1 | sed -n '/^2/{s/.* //;p}')

for i in $LIST; do
	git clone gist:$i
done

