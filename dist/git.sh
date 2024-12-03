#!/usr/bin/env bash
# vim:set ts=4 sw=4 expandtab:
# git-related functions

# list my open github PRs
glpr() {
    author=${1:-phildier}
    is=${2:-open}
    RED='\033[01;31m'
    GREEN='\033[01;32m'
    YELLOW='\033[01;33m'
    BLUE='\033[01;34m'
    NONE='\033[0m'

    # shellcheck disable=SC2016
    hub api \
        -t graphql \
        -f q="is:$is is:pr author:$author user:AgencyPMG archived:false" \
        -f query='query($q: String!, $n: Int = 30, $after: String) {search(query:$q, type: ISSUE, first: $n, after: $after) {edges {
            node {
                ...on PullRequest{
                    title,
                    changedFiles,
                    additions,
                    deletions,
                    url,
                    timelineItems(first: 20, itemTypes: [PULL_REQUEST_REVIEW, PULL_REQUEST_REVIEW_THREAD, PULL_REQUEST_COMMIT_COMMENT_THREAD]) {
                        nodes {
                            ... on PullRequestReview {
                                author {
                                    login
                                }
                                state
                            }
                        }
                    }
                }
            }
        }
    }
    }' \
    | awk -v r="$RED" -v y="$YELLOW" -v g="$GREEN" -v b="$BLUE" -v n="$NONE" '
        $1~/\.title/{printf "%s ", y"\nPR: "substr($0,index($0,$2))n; getline; printf "[%s files,", $2; getline; printf y" +%s, "n, $2; getline; print r"-"$2n"]"} 
        $1~/\.url$/{print b$2n} 
        $1~/.author.login$/{printf("- %s ",$2)} 
        $1~/\.state$/{
            if($2=="APPROVED")
                print "\t"g$2n 
            else
                print "\t"r$2n 
        }'
}

# shows git short-format status, with current branch
gss() {
    git status -bs
}

# does a git diff, piping through vim less
gvl() {
    local cached=""
    if [ "$1" = "1" ]; then
        cached="--cached"
    fi
    git diff $cached | vless
}

gbo() {
    xdg-open  "https://$(git remote -v \
        | awk '/origin.*fetch/{print $2}' \
        | perl -pe 's#git@([^:]+):([^.]+)(\.git)?$#$1/$2#'
    )"
}

gbl() {
    git branch -l
}

gbs() {
    git-branch-status "$*"
}

gpb() {
    branch=$(git rev-parse --abbrev-ref HEAD)
    echo -n "push $branch? [Y/n]"
    read -r response
    if [ "$response" != "n" ]; then
        git push origin "$branch"
    fi
}

gtl() {
    git tag -l | sort -V
}

# if this doesn't work, run
# $ git remote set-head origin master (or main)
git_main_branch() {
    git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
}

git_current_branch_name() {
    git rev-parse --abbrev-ref HEAD
}

grsho() {
  branch="${1:-master}"
  git remote set-head origin "$branch"
}

gsetupstream() {
    branch=$(git_current_branch_name)
    git branch --set-upstream-to=origin/"$branch" "$branch"
}

gcmp() {
    git checkout "$(git_main_branch)" && git pull
}

gdmb() {
    git diff "$(git_main_branch)...$(git rev-parse --abbrev-ref HEAD)" | vless
}

squashbranch() {
    local branch_name
    branch_name=$(git rev-parse --abbrev-ref HEAD)
    gcmp
    git checkout "$branch_name"
    local merge_base
    merge_base=$(git merge-base HEAD "$(git_main_branch)")
    git reset --soft "$merge_base"
    git branch --set-upstream-to=origin/"$branch_name" "$branch_name"
}

gffm() {
    git fetch origin "$(git_main_branch)":"$(git_main_branch)"
}

gmm() {
    git merge "$(git_main_branch)"
}

# lists or deletes merged branches
# rm-merged   # lists
# rm-merged 1 # deletes
rm-merged() {
    local branch
    branch="$(git_main_branch)"

    if [ "$1" = "1" ]; then
        git branch --merged | awk '$2!~/'"$branch"'/{print $1}' | xargs -n1 git branch -d
    else 
        git branch --merged | awk '$2!~/'"$branch"'/{print $1}'
    fi
}

gitbehindlocal() {
    git rev-list --left-right --count "$(git_main_branch)...$(git_current_branch_name)" \
        | awk '{print "behind: "$1" ahead: "$2}'
    git rev-list --left-right --pretty=oneline "$(git_main_branch)...$(git_current_branch_name)"
}

gitbehindremote() {
    git rev-list --left-right --count "origin/$(git_main_branch)...origin/$(git_current_branch_name)" \
        | awk '{print "behind: "$1" ahead: "$2}'
    git rev-list --left-right --pretty=oneline "origin/$(git_main_branch)...origin/$(git_current_branch_name)"
}

gsl() {
    git stash list --date=relative
}

ghorgusers() {
    org=${1:-AgencyPMG}
    raw=${2:-0}

    response=$(hub api --paginate -X GET "/orgs/$org/members")
    if [ "$raw" = "1" ]; then 
        echo "$response"
    else
        echo "$response" | jq -r '.[].login'
    fi
}

ghuserdetails() {
    user=${1:-phildier}

    hub api -X GET "/users/$user"
}

ghorgusersreport() {
    org=${1:-AgencyPMG}

    # shellcheck disable=SC2207
    users=($(ghorgusers "$org"))
    for user in "${users[@]}"; do
        ghuserdetails "$user" | jq -r '[.login, .email, .name] | @csv'
    done
}
