#!/bin/bash

DEF_TMP_NAME="fs-tmp"

E_FILE_EXIST=50
E_DIR_EXIST=51

fs_is_valid_file()
{
  local dir="$1"
  local file="$2"
  local path="${dir}/${file}"

  if [ ! -e "$path" ]; then
      return $E_FILE_EXIST
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

fs_create_tmp_dir()
{
  local tmp_dir=$( mktemp -d 2>/dev/null || mktemp -d -t "$DEF_TMP_NAME"$$ )

  if [ ! -d "$tmp_dir" ]; then
    return $E_TMP_DIR
  fi

  echo "$tmp_dir"
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

  return 0
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

  return 0
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

fs_zip_dir()
{
  local dir_src_root="$1"
  local dir_src_name="$2"
  local dir_dst="$3"
  local file_dst="$4"
  local file_out_path="${dir_dst}/${file_dst}"

  if [ ! -d "$dir_src_root" ]; then
    return $E_ZIP_SRC
  fi

  (
  cd "$dir_src_root"
  zip -qry "${file_dst}" "${dir_src_name}"
  cp "$file_dst" "$file_out_path"
  )

  if [ ! -e "$file_out_path" ]; then
    return $E_ZIP_DST
  fi

  return 0
}

fs_unzip()
{
  local dir_src="$1"
  local file_src="$2"
  local path_src="${dir_src}/${file_src}"
  local dir_dst="$3"

  unzip "$path_src" -d "$dir_dst" > /dev/null

  return $?
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

fs_get_abs_path()
{
  local rel_path="$1"
  local abs_path=

  case "$rel_path" in
    ./* )
      abs_path="${PWD}/${rel_path:2}"
      ;;
    . )
      abs_path="${PWD}/${rel_path:1}"
      ;;
    * )
      abs_path="$rel_path"
  esac

  echo "$abs_path"
}

fs_get_files_for_filter()
{
  local files=()
  local filter="$@"

  for file in $filter; do
    if [ "$file" = "$filter" ]; then
      break
    fi
    files=( "${files[@]}" "$file" )
  done

  echo "${files[@]}"
}

