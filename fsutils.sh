#!/bin/bash

E_FILE_EXIST=50
E_DIR_EXIST=51

fs_is_valid_file()
{
  local file="$1"

  if [ ! -e "$file" ]; then
      return $E_FSRC
  fi

  return 0
}

fs_is_valid_dir()
{
  local dir="$1"

  if [ ! -d "$dir" ]; then
      exit $E_DIR
  fi

  return 0
}

fs_parse_file_from_path()
{
  local path="$1"
  local file=${path##*/}
  
  echo "$file"
}

fs_parse_path_no_file()
{
  local path="$1"
  local path_no_file=${path%/*}
  
  echo "$path_no_file"
}


fs_get_files_for_filter()
{
  local files=()
  local filter="$@"

  for file in $filter; do
    if [ "$file" = "$filter" ]; then
      break
    fi
    file_no_dir=${file##*/}
    files=( "${files[@]}" "$file_no_dir" )
  done

  echo "${files[@]}"
}

