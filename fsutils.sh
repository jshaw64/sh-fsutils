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

fs_copy_file()
{
  local dir_src="$1"
  local dir_dst="$2"
  local file_src="$3"
  local file_dst="$4"

  local path_src="${dir_src}/${file_src}"
  local path_dst="${dir_dst}/${file_dst}"

  if [ ! -e "$path_src" ]; then
    return $E_COPY_SRC
  fi

  cp "$path_src" "$path_dst"

  if [ ! -e "$path_dst" ]; then
    return $E_COPY_DST
  fi

  echo "$path_dst"
}

fs_copy_dir()
{
  local dir_src="$1"
  local dir_dst="$2"

  if [ ! -d "$dir_src" ]; then
    return $E_COPY_SRC
  fi

  cp -r "$dir_src" "$dir_dst"

  if [ ! -d "$dir_dst" ]; then
    return $E_COPY_DST
  fi

  echo "$dir_dst"
}

fs_rm_file()
{
  local dir="$1"
  local file="$2"
  local path="${dir}/${file}"

  if [ ! -e "$path" ]; then
    return $E_RM_SRC
  fi

  rm -r "$path"

  if [ -e "$path" ]; then
    return $E_RM
  fi

  return 0
}

fs_rm_dir()
{
  local dir="$1"

  if [ ! -d "$dir" ]; then
    return $E_RM_DIR
  fi

  rm -r "$dir"

  if [ -d "$dir" ]; then
    return $E_RM_DIR
  fi

  return 0
}

fs_rm_dir_contents()
{
  local dir="$1"

  if [ ! -d "$dir" ]; then
    return $E_RM_DIR
  fi

  rm -r "${dir}"/*

  local found=
  for file in "${dir}"/*; do
    found="$file"
  done

  if [ -n "$found" ]; then
    return $E_RM_FAIL
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
  local file=${path##*/}
  local extension=${file##*.}
  local path_no_file=

  if [ "$extension" = "$file" ]; then
    path_no_file="$path"
  else
    path_no_file=${path%/*}
  fi

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

