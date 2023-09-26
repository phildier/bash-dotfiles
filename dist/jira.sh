#!/usr/bin/env bash
# shellcheck disable=SC2162

export JIRA_ASSIGNEE="Phil Dier"

jira_setup() {
  jira_check_env
}

jira_usage() {
  echo "usage: $1 not found in environment"
}

jira_check_env() {
  if [ -z "$JIRA_PROJECT" ]
  then
    jira_usage "JIRA_PROJECT"
  fi

  if [ -z "$JIRA_COMPONENT" ]
  then
    jira_usage "JIRA_COMPONENT"
  fi

  if [ -z "$JIRA_LABEL" ]
  then
    jira_usage "JIRA_LABEL"
  fi
}

jira_current_sprint() {
  jira sprint list --table | grep -ie 'core.*active$' | awk -F'\t' '{print $2}'
}

jlpd() {
  jira issue list -a"$JIRA_ASSIGNEE" -q"status = 'Pending Deployment'"
}

jlnc() {
  jira issue list -a"$JIRA_ASSIGNEE" -q"status != Completed and status != Canceled and status != 'Pending Deployment'"
}

jcs() {
  jira_setup

  read -r -d '' cmd <<-EOF
  jira issue create \
    --type Story \
    --project "$JIRA_PROJECT" \
    --component "$JIRA_COMPONENT" \
    --label "$JIRA_LABEL" \
    --custom responsible-team="$JIRA_RESPONSIBLE_TEAM" \
    --web \
    --summary "$1" \
    --body "$2"
EOF

  echo "press enter to run:"
  read -p "$cmd"

  $cmd
}

jcb() {
  jira_setup

  jira issue create -tBug -p"$JIRA_PROJECT" -C"$JIRA_COMPONENT" -l"$JIRA_LABEL" --web -s "$1" -b "$2"
}

jce() {
  jira_setup

  jira issue create -tEpic -p"$JIRA_PROJECT" -C"$JIRA_COMPONENT" -l"$JIRA_LABEL" --web -s "$1" -b "$2"
}

jiraskye() {
  jira issue list -q'project = "ALLI" AND assignee = "Skye Mckay" AND status IN ("Code In Review",Completed,"Pending Deployment") and updated >= "2023-04-12"'
}

jiradon() {
  jira issue list -q'project = "ALLI" AND assignee = "Donavan Aldrich" AND status IN ("Code In Review",Completed,"Pending Deployment") and updated >= "2023-04-12"'
}
