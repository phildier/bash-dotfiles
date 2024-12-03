#!/usr/bin/env bash

share_file() {
  title=$1
  file=$2
  email=$3

  op item create \
    --category Login \
    --title "$title" \
    --emails "$email" \
    'FileName[file]'="$file"
}
