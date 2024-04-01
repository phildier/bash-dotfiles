_bitwarden_hook() {
  local previous_exit_status=$?;
  trap -- '' SIGINT;
  if find ~/.config/ -ctime +1 -type f -iname bitwarden_session | grep . &>/dev/null; then
    if ! bw unlock --check &>/dev/null; then
      bw unlock --raw > ~/.config/bitwarden_session;
    fi
  fi
  eval "export BW_SESSION=$(cat ~/.config/bitwarden_session)"
  trap - SIGINT;
  return $previous_exit_status;
};
if ! [[ "${PROMPT_COMMAND:-}" =~ _bitwarden_hook ]]; then
  PROMPT_COMMAND="_bitwarden_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi

bwu() {
  bw unlock --raw > ~/.config/bitwarden_session
}
