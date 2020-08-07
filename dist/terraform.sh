#!/usr/bin/env bash

tf() {
	if [ -z "$VAULT_ENV" ]; then
		echo "VAULT_ENV is not set"
		return
	fi

	aws-vault exec "$VAULT_ENV" -- terraform "$@"
}

tfi() {
	tf init
}

tfp() {
	tf plan -out=plan.out
}

tfa() {
	tf apply plan.out
}
