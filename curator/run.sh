#!/bin/bash

TIMES=60

function waitForES() {
  for ((i=1; i<=$TIMES; i++ )); do
    # test for ES to be up first by checking for existance of .searchguard* index
    # if we could do indices:admin/exists we would use -XHEAD -i instead
    result=$(curl --cacert $ES_CA --key $ES_CLIENT_KEY --cert $ES_CLIENT_CERT -s -w "%{http_code}" -XGET "https://$ES_HOST:$ES_PORT/.searchguard*" -o /dev/null)
    [[ $result -eq 200 ]] && return 0
    sleep 1
  done

  echo "Was not able to connect to Elasticearch at $ES_HOST:$ES_PORT within $TIMES attempts"
  exit 255
}

waitForES
# this will parse out the retention settings, combine like settings, create cron line definitions for them with curator, run the jobs immediately, then run the jobs again every CURATOR_CRON_HOUR and CURATOR_CRON_MINUTE (by default, every midnight)
python -u run_cron.py
