#!/bin/bash

E_FILE_EXIST=50

fs_is_valid_file()
{
  local file="$1"

  if [ ! -e "$file" ]; then
      return $E_FSRC
  fi

  return 0
}

