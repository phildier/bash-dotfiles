export BB_API_URL=https://api.bitbucket.org/2.0

bb_api_command() {
    BB_USER=${BB_USER:-phildier}

    curl -s -u "${BB_USER}:${BB_APP_PASSWORD}" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        "$@"
}

bb_get_pull_requests() {
    BB_WORKSPACE=${BB_WORKSPACE:-hortongroup}
    BB_REPO=${BB_REPO:-horton}

    nickname=${1:-phildier}
    state=${2:-OPEN}
    RED='\033[01;31m'
    GREEN='\033[01;32m'
    YELLOW='\033[01;33m'
    BLUE='\033[01;34m'
    NONE='\033[0m'

    # return output as object, with pr id as key and title as value
    bb_api_command "$BB_API_URL/repositories/$BB_WORKSPACE/$BB_REPO/pullrequests" | jq \
        --arg nickname "$nickname" \
        --arg state "$state" \
        -r '.values[] | select(.author.nickname == $nickname and .state == $state) | 
            "\(.id) \(.title) \(.source.commit.file_count) \(.source.commit.url) \(.author.nickname) \(.state)"' 


#    | awk -v r="$RED" -v y="$YELLOW" -v g="$GREEN" -v b="$BLUE" -v n="$NONE" '
#        $1~/\.title/{printf "%s ", y"\nPR: "substr($0,index($0,$2))n; getline; printf "[%s files,", $2; getline; printf y" +%s, "n, $2; getline; print r"-"$2n"]"} 
#        $1~/\.url$/{print b$2n} 
#        $1~/.author.login$/{printf("- %s ",$2)} 
#        $1~/\.state$/{
#            if($2=="APPROVED")
#                print "\t"g$2n 
#            else
#                print "\t"r$2n 
#        }'
}

blpr() {
    BB_WORKSPACE=${BB_WORKSPACE:-hortongroup}

    repositories=$(bb_api_command $BB_API_URL/repositories/$BB_WORKSPACE | jq -r '.values[].name')

    for repo in $repositories; do
        BB_REPO=$repo
        bb_get_pull_requests | while read -r pr; do
            echo "$pr"
        done
    done
}
