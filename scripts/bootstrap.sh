#!/usr/bin/env bash
set -euo pipefail

########################################
# CONFIG: toggle modules here (1 = on, 0 = off)
########################################

ENABLE_INPUTLEAP=0
ENABLE_PASSWORDLESS_SUDO=0
ENABLE_NET_TOOLS=1
ENABLE_SLACK=1
ENABLE_BITWARDEN=1
ENABLE_VIM=1
ENABLE_TMUX=1
ENABLE_GAWK=1
ENABLE_BASHRCD_DOTFILES=0
ENABLE_VIMRC_DOTFILES=0
ENABLE_DIRENV=1
ENABLE_ASDF_VM=1
ENABLE_TFENV=1
ENABLE_GIT=1
ENABLE_BUILD_ESSENTIAL=1
ENABLE_HUB=1
ENABLE_JQ=1
ENABLE_XCLIP=1
ENABLE_IMAGEMAGICK=1
ENABLE_GPG_TECH_KEY=1
ENABLE_RLWRAP=1
ENABLE_PAVUCONTROL=1
ENABLE_MYSQL_CLIENT_DEV=1
ENABLE_DOCKER_GROUP=1
ENABLE_DOCKER_COMPOSE=1
ENABLE_AWS_CLI_AND_SSM=0
ENABLE_COPY_DOTFILES=0
ENABLE_VOLUME_GROUP_INFO=0

# Where your dotfiles / backups live
BACKUP_HOME="${BACKUP_HOME:-}"                    # e.g. /mnt/backup/oldhome

# Path to your armored GPG key, if you want to auto-import it
TECH_GPG_KEY_FILE="${TECH_GPG_KEY_FILE:-}"

########################################
# Helpers
########################################

APT_UPDATED=0

apt_update_once() {
  if [[ "$APT_UPDATED" -eq 0 ]]; then
    echo "==> Running apt-get update"
    sudo apt-get update -y
    APT_UPDATED=1
  fi
}

install_pkgs() {
  apt_update_once
  sudo apt-get install -y "$@"
}

run_step() {
  local flag="$1"
  local name="$2"
  shift 2
  local fn="$1"

  if [[ "$flag" -eq 1 ]]; then
    echo
    echo "----------------------------------------"
    echo "==> ${name}"
    echo "----------------------------------------"
    "$fn"
  else
    echo "Skipping ${name}"
  fi
}

########################################
# Steps
########################################

install_prereqs() {
  install_pkgs git curl 
}

install_inputleap() {
  # Uses official .deb from GitHub Releases for Ubuntu 24.04+
  local tmpdir
  tmpdir="$(mktemp -d)"
  pushd "$tmpdir" >/dev/null
  echo "Downloading InputLeap .deb for Ubuntu 24.04..."
  curl -LO "$(curl -s https://api.github.com/repos/input-leap/input-leap/releases/latest \
    | grep 'ubuntu_24-04_amd64.deb' | head -n1 | cut -d '"' -f 4)"
  sudo dpkg -i ./*.deb || sudo apt-get -f install -y
  popd >/dev/null
  rm -rf "$tmpdir"
}

configure_passwordless_sudo() {
  local file="/etc/sudoers.d/99-${USER}-nopasswd"
  echo "Configuring passwordless sudo for user ${USER} in ${file}"
  echo "${USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee "$file" >/dev/null
  sudo chmod 440 "$file"
}

install_net_tools() {
  install_pkgs net-tools
}

install_slack() {
  # Slack is easiest via snap on Ubuntu
  sudo snap install slack --classic
}

install_bitwarden() {
  # Desktop Bitwarden via snap
  sudo snap install bitwarden
}

install_vim() {
    ASDF_VIM_CONFIG="--with-tlib=ncurses \
        --with-compiledby=asdf \
        --enable-multibyte \
        --enable-cscope \
        --enable-terminal \
        --enable-perlinterp \
        --enable-rubyinterp \
        --enable-python3interp \
        --enable-luainterp \
        --with-features=huge \
        --enable-gui=auto \
        --with-x" asdf install vim
}

install_tmux() {
  install_pkgs tmux
}

install_gawk() {
  install_pkgs gawk
}

install_bashrcd_dotfiles() {
  echo "not implemented"
}

install_vimrc_dotfiles() {
  echo "not implemented"
}

install_direnv() {
  install_pkgs direnv
  mkdir -p "$HOME/.bashrc.d"
  cat <<'EOF' > "$HOME/.bashrc.d/direnv.sh"
# direnv integration
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi
EOF
}

install_asdf_vm() {
  if [[ ! -d "$HOME/.asdf" ]]; then
    git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf"
  else
    echo "~/.asdf already exists; skipping clone."
  fi

  mkdir -p "$HOME/.bashrc.d"
  cat <<'EOF' > "$HOME/.bashrc.d/asdf.sh"
# asdf-vm
if [ -d "$HOME/.asdf" ]; then
  . "$HOME/.asdf/asdf.sh"
  . "$HOME/.asdf/completions/asdf.bash"
fi
EOF
}

install_tfenv() {
  if [[ ! -d "$HOME/.tfenv" ]]; then
    git clone https://github.com/tfutils/tfenv.git "$HOME/.tfenv"
  else
    echo "~/.tfenv already exists; skipping clone."
  fi

  mkdir -p "$HOME/.local/bin"
  ln -sf "$HOME/.tfenv/bin/*" "$HOME/.local/bin/" 2>/dev/null || true

  mkdir -p "$HOME/.bashrc.d"
  cat <<'EOF' > "$HOME/.bashrc.d/tfenv_path.sh"
# tfenv in PATH
if [ -d "$HOME/.local/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
fi
EOF
}

install_git() {
  install_pkgs git
}

install_build_essential() {
  install_pkgs build-essential
}

install_hub() {
  # GitHub hub (if available in Ubuntu repos)
  install_pkgs hub || {
    echo "hub package not found; you may need to install gh instead."
  }
}

install_jq() {
  install_pkgs jq
}

install_xclip() {
  install_pkgs xclip
}

install_imagemagick() {
  install_pkgs imagemagick
}

install_gpg_and_tech_key() {
  install_pkgs gnupg
  if [[ -n "$TECH_GPG_KEY_FILE" && -f "$TECH_GPG_KEY_FILE" ]]; then
    echo "Importing GPG key from ${TECH_GPG_KEY_FILE}"
    gpg --import "$TECH_GPG_KEY_FILE"
  else
    echo "TECH_GPG_KEY_FILE not set or file missing; skipping key import."
  fi
}

install_rlwrap() {
  install_pkgs rlwrap
}

install_pavucontrol() {
  install_pkgs pavucontrol
}

install_mysql_client_dev() {
  install_pkgs default-libmysqlclient-dev
}

add_user_to_docker_group() {
  install_pkgs docker.io
  sudo usermod -aG docker "$USER"
  echo "Added ${USER} to docker group (log out/in for it to take effect)."
}

install_docker_compose() {
  # Ubuntu 24.04 has docker-compose-v2 package
  install_pkgs docker-compose-v2
  echo "Docker Compose v2 installed. Use: docker compose ..."
}

install_aws_cli_and_ssm() {
  # awscli from Ubuntu
  install_pkgs awscli

  # Session Manager plugin from AWS
  local tmpdir
  tmpdir="$(mktemp -d)"
  pushd "$tmpdir" >/dev/null
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" \
    -o "session-manager-plugin.deb"
  sudo dpkg -i session-manager-plugin.deb || sudo apt-get -f install -y
  popd >/dev/null
  rm -rf "$tmpdir"
}

copy_dotfiles_from_backup() {
  if [[ -z "$BACKUP_HOME" || ! -d "$BACKUP_HOME" ]]; then
    echo "BACKUP_HOME not set or not a directory; skipping copy."
    return 0
  fi

  echo "Copying dotfiles from ${BACKUP_HOME} to ${HOME}"

  for item in .aws .ssh .asdf .terraform.d .terraformrc .tmux.conf .tfenv .gitconfig .gitignore; do
    if [[ -e "${BACKUP_HOME}/${item}" ]]; then
      rsync -av "${BACKUP_HOME}/${item}" "$HOME/"
    else
      echo "  ${item} not found in backup; skipping."
    fi
  done

  chmod 700 "$HOME/.ssh" 2>/dev/null || true
}

show_volume_group_info() {
  install_pkgs lvm2
  echo "Volume groups / physical volumes (with VG UUID):"
  sudo pvs -o +vg_uuid
}

########################################
# Main
########################################

main() {
  echo "Starting laptop setup on Ubuntu $(lsb_release -ds 2>/dev/null || echo 24.04)..."
  echo "Using BACKUP_HOME=${BACKUP_HOME:-<unset>}"
  echo

  install_prereqs

  run_step "$ENABLE_INPUTLEAP"              "Install InputLeap"                    install_inputleap
  run_step "$ENABLE_PASSWORDLESS_SUDO"      "Configure passwordless sudo"          configure_passwordless_sudo
  run_step "$ENABLE_NET_TOOLS"              "Install net-tools"                    install_net_tools
  run_step "$ENABLE_SLACK"                  "Install Slack (snap)"                 install_slack
  run_step "$ENABLE_BITWARDEN"              "Install Bitwarden (snap)"             install_bitwarden
  run_step "$ENABLE_VIM"                    "Install Vim"                          install_vim
  run_step "$ENABLE_TMUX"                   "Install tmux"                         install_tmux
  run_step "$ENABLE_GAWK"                   "Install gawk"                         install_gawk
  run_step "$ENABLE_BASHRCD_DOTFILES"       "Install bashrc.d dotfiles"            install_bashrcd_dotfiles
  run_step "$ENABLE_VIMRC_DOTFILES"         "Install vimrc dotfiles"               install_vimrc_dotfiles
  run_step "$ENABLE_DIRENV"                 "Install direnv"                       install_direnv
  run_step "$ENABLE_ASDF_VM"                "Install asdf-vm"                      install_asdf_vm
  run_step "$ENABLE_TFENV"                  "Install tfenv"                        install_tfenv
  run_step "$ENABLE_GIT"                    "Install git"                          install_git
  run_step "$ENABLE_BUILD_ESSENTIAL"        "Install build-essential"              install_build_essential
  run_step "$ENABLE_HUB"                    "Install hub"                          install_hub
  run_step "$ENABLE_JQ"                     "Install jq"                           install_jq
  run_step "$ENABLE_XCLIP"                  "Install xclip"                        install_xclip
  run_step "$ENABLE_IMAGEMAGICK"            "Install ImageMagick"                  install_imagemagick
  run_step "$ENABLE_GPG_TECH_KEY"           "Install gpg and tech private key"     install_gpg_and_tech_key
  run_step "$ENABLE_RLWRAP"                 "Install rlwrap"                       install_rlwrap
  run_step "$ENABLE_PAVUCONTROL"            "Install pavucontrol"                  install_pavucontrol
  run_step "$ENABLE_MYSQL_CLIENT_DEV"       "Install default-libmysqlclient-dev"   install_mysql_client_dev
  run_step "$ENABLE_DOCKER_GROUP"           "Add user to docker group"             add_user_to_docker_group
  run_step "$ENABLE_DOCKER_COMPOSE"         "Install Docker Compose v2"            install_docker_compose
  run_step "$ENABLE_AWS_CLI_AND_SSM"        "Install AWS CLI & SSM plugin"         install_aws_cli_and_ssm
  run_step "$ENABLE_COPY_DOTFILES"          "Copy dotfiles from backup"            copy_dotfiles_from_backup
  run_step "$ENABLE_VOLUME_GROUP_INFO"      "Show volume group info"               show_volume_group_info

  echo
  echo "All selected steps completed."
}

main "$@"
