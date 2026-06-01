#!/usr/bin/env bash

template_len=$((${#2} + 2))
target_file=$1/$(echo $3 | cut -c $template_len-)

echo Doing subst of file $3 into $target_file
target_dir=$(dirname $target_file)
if [ ! -d $target_dir ]; then
  mkdir -p $target_dir
fi
envsubst < $3 > $target_file
