#!/usr/bin/env bash

save_ifs=$IFS
IFS=$'\n'

tags=($(git for-each-ref --sort refname --format '%(contents:subject)::%(refname)' refs/tags | sed 's/refs\/tags\///'))

function_find_tag() {
  local -a matches=()
  for index in "${tags[@]}" ; do
    msg="${index%%::*}"
    tag="${index##*::}"
    if [ "$1" == "$msg" ]; then
        matches+=($tag)
    fi
  done
  echo "${matches[@]}"
}

echo git fetch
echo git checkout solution

git tag -l | while read line; do
  echo "git push --delete origin ${line}"
  echo "git tag -d ${line}"
done


IFS=$' '

git log --pretty=oneline --abbrev-commit --full-history | while read line; do
  sha="$( cut -d ' ' -f 1 <<< "$line" )";
  commit_message="$( cut -d ' ' -f 2- <<< "$line" )"
  matched_tags=($(function_find_tag "${commit_message}"))

  for matched_tag in ${matched_tags[@]} ; do
    echo "git tag $matched_tag $sha"
  done
done

echo git push --follow-tags

IFS=${save_ifs}
