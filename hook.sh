#!/usr/bin/env bash
#
# Hook script for dns-01 challenge via GoDaddy API
#
# https://developer.godaddy.com/doc
# https://github.com/dehydrated-io/dehydrated/blob/master/docs/examples/hook.sh
##

# set -x          # show each command as executed
set -e            # exit on error
set -u            # force error on unset variables
set -f            # disable file globbing
shopt -s extglob  # enable extended pattern matching
set -o pipefail   # exit status of pipe is 0 or last command failed

log() { echo " : $@"; }

API="https://api.godaddy.com/v1"
DELAY=30
TXT_KEY="_acme-challenge"

# Pre-check environment
if [[ -z "${GODADDY_KEY}" ]] || [[ -z "${GODADDY_SECRET}" ]]; then
  log "Unable to locate GoDaddy credentials in the environment!  Make sure GODADDY_KEY and GODADDY_SECRET are set"
  exit 1
fi

deploy_challenge() {
  local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

  # Determine subdomain (all but last two components):
  SUBDOMAIN="${DOMAIN%%.*.*}"
  # and "GoDaddy" domain (everything else):
  GDDOMAIN="${DOMAIN##${SUBDOMAIN}.}"
  # re-remove GDDOAMIN (handling SUBDOMAIN == GDDOAMIN case):
  SUBDOMAIN="${SUBDOMAIN%%${GDDOMAIN}}"
  # and finally, challenge record as GoDaddy wants it:
  CHALLENGE="${TXT_KEY}${SUBDOMAIN:+.${SUBDOMAIN}}"

  log "Setting TXT record with GoDaddy on '${GDDOMAIN}' for '${CHALLENGE}' = '${TOKEN_VALUE}'"
  curl -X PUT ${API}/domains/${GDDOMAIN}/records/TXT/${CHALLENGE} \
       -H "Authorization: sso-key ${GODADDY_KEY}:${GODADDY_SECRET}" \
       -H "Content-Type: application/json" \
       -d "[{\"name\": \"${CHALLENGE}\", \"ttl\": 600, \"data\": \"${TOKEN_VALUE}\"}]"

  log "Result:" \
    $(curl -s -X GET ${API}/domains/${GDDOMAIN}/records/TXT/${CHALLENGE} \
           -H "Authorization: sso-key ${GODADDY_KEY}:${GODADDY_SECRET}" )

  log "Waiting ${DELAY} seconds for DNS to propagate."
  sleep ${DELAY}
}

clean_challenge() {
  local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"
  # There is no (simple) way to remove an entry with GoDaddy's API, so let's set it to a bogus value.
  deploy_challenge "${DOMAIN}" "${TOKEN_FILENAME}" "--removed--"
}

# deploy_cert() {
#   do something
# }

unchanged_cert() {
  local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"
  #log "The $DOMAIN certificate is still valid and therefore wasn't reissued."
}

HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_challenge|clean_challenge|unchanged_cert)$ ]]; then
  "$HANDLER" "$@"
fi
