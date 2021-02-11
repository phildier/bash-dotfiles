#!/usr/bin/env bash

# git-related functions
#

# list my open github PRs
glpr() {
    RED='\033[01;31m'
    GREEN='\033[01;32m'
    YELLOW='\033[01;33m'
    BLUE='\033[01;34m'
    NONE='\033[0m'

    # shellcheck disable=SC2016
    hub api \
        -t graphql \
        -f q="is:open is:pr author:phildier user:AgencyPMG archived:false" \
        -f query='query($q: String!, $n: Int = 30, $after: String) {search(query:$q, type: ISSUE, first: $n, after: $after) {edges {
            node {
                ...on PullRequest{
                    title,
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
        $1~/\.title/{print y"\nPR: "substr($0,index($0,$2))n} 
        $1~/\.url$/{print b$2n} 
        $1~/\.author\.login$/{printf("- %s ",$2)} 
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
    exo-open --launch WebBrowser "$(git remote -v | awk '/fetch/{print $2}' | sed 's#git@\([^:]\+\):#\1/#')"
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

git_main_branch() {
    git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
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
