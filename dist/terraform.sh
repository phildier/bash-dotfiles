#!/usr/bin/env bash

tf() {
    ave terraform "$@"
}

tfi() {
    tf init "$@"
}

tfp() {
    tf plan -out=plan.out
}

tfa() {
    tf apply plan.out
}
