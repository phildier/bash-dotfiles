#!/usr/bin/env bash

ecstasks() {
    # shellcheck disable=SC2046
    ave aws ecs describe-tasks \
        --cluster "${CLUSTER_NAME}" \
        --tasks $(
            ave aws ecs list-tasks \
                --cluster "${CLUSTER_NAME}" \
                --query 'taskArns[]' \
                --output text
        ) \
    | jq -r '.tasks | map([(.startedAt | strflocaltime("%Y-%m-%dT%H:%M:%SZ")), (.taskDefinitionArn | split("/")[1]), .lastStatus]) | .[] | @tsv' \
    | expand -t30
}

cloudwatchlogs() {
    if [ -z "$*" ]; then
        PARAMS=(-w -i 10)
    fi

    ave awslogs get "${LOG_GROUP}" "${PARAMS[@]}" "$@"
}
