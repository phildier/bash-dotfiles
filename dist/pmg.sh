#!/usr/bin/env bash

dwh() {
    psql -h redshift.data.pmg.com -p 5439 -U phil@pmg.com datawarehouse "$@"
#    psql -h 3.93.105.232 -p 5439 -U phil@pmg.com datawarehouse "$@"
}

dwh-datauser() {
    psql -h redshift.data.pmg.com -p 5439 -U datauser datawarehouse "$@"
}

dwh-test() {
    psql -h datawarehouse-test.coe8ikkn195e.us-east-1.redshift.amazonaws.com -p 5439 -U phil@pmg.com datawarehouse "$@"
}

dwh-devopsmetrics() {
    psql -h redshift.data.pmg.com -p 5439 -U devopsmetrics datawarehouse "$@"
}

dwh-staging() {
    psql -h staging.redshift.data.pmg.com -p 5439 -U phil@pmg.com datawarehouse "$@"
}

dwh-corereportingstaging() {
    psql -h staging.redshift.data.pmg.com -p 5439 -U corereportingstaging datawarehouse "$@"
}

dwh-jc() {
    psql -h staging.redshift.data.pmg.com -p 5439 -U jason.cavnar@pmg.com datawarehouse "$@"
}

dwh-beats() {
    psql -h beats.redshift.alliplatform.com -p 5439 -U phil@pmg.com datawarehouse "$@"
}

dwh-venus() {
    psql -h venus.redshift.alliplatform.com -p 5439 -U phil@pmg.com datawarehouse "$@"
}

dwh_query() {
    outfile=${2:-/dev/stdout}
    dwh -P pager=off -P tuples_only -AF $'\t' -c "$1" -o "$outfile"
}

dwh-moroch() {
    psql -h moroch.redshift.alliplatform.com -p 5439 -U phil@pmg.com datawarehouse "$@"
}

dwh-nike() {
    psql -h nike.redshift.alliplatform.com -p 5439 -U phil@pmg.com datawarehouse "$@"
}

dwh-digitalco() {
    psql -h digitalco.redshift.alliplatform.com -p 5439 -U pmguser datawarehouse "$@"
}

dwh-searchdiscovery() {
    psql -h searchdiscovery.redshift.alliplatform.com -p 5439 -U pmguser datawarehouse "$@"
}

dwh-searchdiscovery-clientcreds() {
    psql -h searchdiscovery.redshift.alliplatform.com -p 5439 -U pmguser datawarehouse "$@"
}

dwh-mars() {
    psql -h mars.redshift.alliplatform.com -p 5439 -U pmguser datawarehouse "$@"
}

dwh-bose() {
    psql -h bose.redshift.alliplatform.com -p 5439 -U pmguser datawarehouse "$@"
}
