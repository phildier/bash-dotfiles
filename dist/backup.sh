#!/usr/bin/env bash

backup() {
    dir=${1:-/home/phil/}

    exclude_patterns=(
        '.asdf/*'
        '.cache'
        '.mozilla'
        '.thunderbird'
        '.ssh'
        '.npm'
        '.tfenv'
        '.terraform'
        '.terraform.d'
        '.pki'
        '.gnupg'
        '.zoom'
        'minecraft'
        'Downloads'
        'snap'
        'go'
    )
    
    # remove leading and trailing slashes
    backup_dir=${dir#/}
    backup_dir=${backup_dir%/}

    # set destination
    backup_dest="s3://s3.spark5.com/backups/$(hostname)/${backup_dir}/"

    echo "backing up $dir to $backup_dest" 
    cd "$dir" || return

    # using exclude_patterns list, create an --exclude argument for each
    # element of the list
    exclude_args=""
    for pattern in "${exclude_patterns[@]}"; do
        exclude_args+=" --exclude '$pattern'"
    done

    echo "$exclude_args"
    echo "${exclude_patterns[@]}"

    # shellcheck disable=SC2086
    aws-vault exec spark5 --no-session -- \
        aws s3 sync "$dir" "$backup_dest" $exclude_args --dryrun
}
