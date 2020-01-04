#!/bin/bash

set -eu

files=$(git ls-files '*.rb')

echo Execute script
for file in $files; do
  echo $file
  time ruby $file
  echo
done

echo Run rubocop
rubocop $files

echo Done!
