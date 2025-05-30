#!/usr/bin/env bash

# shellcheck disable=SC2016
vimruntime=$(vim -e -T dumb --cmd 'exe "set t_cm=\<C-M>"|echo $VIMRUNTIME|quit' | tr -d '\015' | xargs)
# shellcheck disable=SC2016
[[ -z $vimruntime ]] && { echo 'Sorry, $VIMRUNTIME was not found' >&2; }

vless=$vimruntime/macros/less.sh
[[ -x $vless ]] || { echo "Sorry, '$vless' is not accessible/executable" >&2; }

# reloads functions
sf()
{
    # shellcheck disable=SC1090
    source ~/.bashrc
}

# execute vi and set xterm title to filename
vi()
{
    set_xterm_title "$@"
    vim "$@"
    set_xterm_title "\$$(hostname -s)"
}

vless()
{
    $vless "$@"
}

set_xterm_title()
{
    # shellcheck disable=SC1117
    echo -ne "\033]0;${*}\007";
}

# sshs to imp
si()
{
    ssh -A phil@10.2.0.250
}

# echos todays date
today()
{
    date +%m%d%Y
}

# fixes filenames. lowercases and removes special characters
fixnames()
{
    ext=$1;
    changed=0;
    for i in *"$ext"; do
        fixone "$i"
    done
    echo "[-] fixed $changed files";
}

# fix one filename
fixone()
{
    old=$*
    # shellcheck disable=SC1117
    sedcmd=(sed 's/\(\x27\|\"\|,\|!\|*\)//g')
    new=$(echo "$old" | "${sedcmd[@]}")
    sedcmd=(sed 's/\x26/and/g')
    new=$(echo "$new" | "${sedcmd[@]}")
    sedcmd=(sed 's/\x20\+/_/g')
    new=$(echo "$new" | "${sedcmd[@]}")
    if [[ "$old" != "$new" ]]; then
            mv -- "$old" "$new"
            changed=$((changed+1));
            echo "[*]    fixed: $new";
    else
            echo "[o] unchanged: $new";
    fi
}

# upload a file to spark5.com
upl()
{
    local file=$1
    scp "$file" ec2-user@spark5.com:/www/virtual/spark5.com/downloads/
    echo "link: http://spark5.com/downloads/$file"
}

# generate a random password
pw()
{
    apg -a 0 -m 8 -x 8 -MLN -n 1
}

# scrape .jpg images from a page
scrape()
{
    wget -r -l1 --span-hosts -nd -A.jpg "$@"
}

# lints modified php files
checkphp()
{
    if [ -e .svn ]; then
        svn status -q | awk '$2~/.php$/{print $2}' | xargs -l1 php -l
    elif [ -e .git ]; then
        git status -s | awk '$NF~/php$/{print $NF}' | xargs -l1 php -l
    else 
        echo "not a git or svn repo"
    fi
}

# uppercases parameters
upper() {
    echo "${@^^}"
}

# pipes svn diff through vim less
svl() {
    svn diff | /usr/share/vim/vim80/macros/less.sh
}

# uploads given file to sprunge, outputs url
pasty() {
    local file=$1
    curl -F 'sprunge=<-' http://sprunge.us < "$file"
}

json_encode() {
    ruby << EOF
    require 'json'
    puts IO.read('$1').to_json
EOF
}

ctrlc() {
    xclip -selection clipboard
}

ctrlv() {
    xclip -o -selection clipboard
}

# start tmux environment with pre-split windows
# or attach to existing session if it exists
mx() {
    local workdir=$1
    cd "$workdir" || return

    if [ -n "$TMUX" ]; then
        echo "refusing to execute nested tmux session"
        return
    fi

    SESSION_NAME=$(basename "$PWD" | sed 's/\./-/g')
    printf "\033]0;%s\007" "$SESSION_NAME"

    if tmux list-sessions | grep -e "^$SESSION_NAME:" &>/dev/null; then
        tmux attach-session -t "$SESSION_NAME"
    else
        SESSION=$(tmux new-session -dP -s "$SESSION_NAME")
        tmux split-window -p 20 -v
        tmux split-window -h
        tmux select-pane -t 0
        tmux split-window -h
        tmux select-pane -t 0

        tmux send-keys "resize" C-m

        sleep 1
        tmux send-keys "vi" C-m

        tmux attach-session -t "$SESSION"
    fi
}

# start tmux in current directory
mxp() {
    mx "$(pwd)"
}

certissuer() {
    file=$1

    if [ -f "$file" ]
    then
        openssl crl2pkcs7 -nocrl -certfile "$file" | openssl pkcs7 -print_certs -text -noout
    fi
}

certinfo() {
    domain=$1

    if [ -f "$domain" ]; then
            openssl x509 -in "$domain" -noout -text
    else
            echo | \
                    openssl s_client -showcerts \
                    -servername "$domain" \
                    -connect "$domain":443 2>/dev/null | \
                    openssl x509 -inform pem -noout -text
    fi
}

oskyhosts() {
    if hosts=$(awk '/HostName/ && /'"$1"'/ {num++; printf("%0d %s\n", num, $2)}' ~/.ssh/config.d/51_oskhosts); then
            echo "$hosts"
            echo -n "which host?: "
            read -r selection
            ssh "$(echo "$hosts" | awk '$1~/^'"$selection"'$/ {print $2}')"
    else
            echo "$1: no matches found"
    fi
}

#vpn() {
#    if [ "$1" = "down" ]; then
#            nmcli connection down "$(nmcli connection show --active | awk '/vpn/{sub(/ [a-z0-9]+-[a-z0-9]+-.*$/,""); sub(/ +$/,""); print}')"
#            return
#    fi
#
#    if vpns=$(nmcli connection | awk '/vpn/{num++; sub(/ [a-z0-9]+-[a-z0-9]+-.*$/,""); sub(/ +$/,""); printf("%0d %s\n", num, $0)}'); then
#            echo "$vpns"
#            echo -n "which VPN?: "
#            read -r selection
#            nmcli connection up "$(echo "$vpns" | awk '$1~/^'"$selection"'$/ {$1=""; sub(/^ +/,""); print $0}')"
#    fi
#}

gilbert() {
    pushd ~/Downloads/gilbert || return
    youtube-dl -x "$1"
    popd || return
}

function greenbar() { 
    awk '{if (NR%3==0){print "\033[32m" $0 "\033[0m"} else{print}}'
}

cptv() {
    scp ~/Downloads/*.torrent 10.2.0.250:~/watch/tv/
    rm ~/Downloads/*.torrent
}

cpmovies() {
    scp ~/Downloads/*.torrent 10.2.0.250:~/watch/movies/
    rm ~/Downloads/*.torrent
}

avl() {
    if [ -n "$VAULT_ENV" ]; then
        echo "logging in to $VAULT_ENV"
        aws-vault login --duration=1h "$VAULT_ENV" "$@"
    elif [ -n "$1" ]; then
        echo "logging in to $1"
        aws-vault login --duration=1h "$@"
    else
        echo "usage: $0 <vault profile>"
        echo "or set VAULT_ENV variable"
    fi
}

ave() {
    if [ -z "$VAULT_ENV" ]; then
        echo "VAULT_ENV is not set"
        "$@"
        return
    fi

    aws-vault exec -d 8h "$VAULT_ENV" -- "$@"
}


# outputs epoch parameter in human-readable format
fromepoch()
{
    php << EOF
<?php date_default_timezone_set("America/Chicago"); echo date("Y-m-d H:i:s",$1)."\n"; ?>
EOF
}

# converts input date to epoch
toepoch()
{
    php << EOF
<?php date_default_timezone_set("America/Chicago"); echo date("U",strtotime("$1"))."\n"; ?>
EOF
}

# greps all files matching $1 for $2
# fin \*.php mysql_connect
fin() {
    find . -type f -iname "$1" -exec grep -i "$2" {} +
}

# find files named $1
ff() {
    find . -type f -iname "$1"
}

###########################################
# HOW MUCH RAM IS A PROCESS USING         #
# #########################################
function ram() {
  local sum
  local app="$1"
  if [ -z "$app" ]; then
    echo "First argument - pattern to grep from processes"
  else
    sum=0
    # shellcheck disable=SC2009
    for i in $(ps aux | grep -i "$app" | grep -v "grep" | awk '{print $6}'); do
      sum=$((i + sum))
    done
    sum=$(echo "scale=2; $sum / 1024.0" | bc)
    if [[ $sum != "0" ]]; then
      echo "${app} uses ${sum} MBs of RAM."
    else
      echo "There are no processes with pattern '${app}' are running."
    fi
  fi
}
 
# vim:set syntax=sh:
