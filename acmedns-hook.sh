#!/usr/bin/env bash

_log() {
  echo >&2 "   + ${@}"
}

_error() {
  _log "ERROR: $*"
  exit 1
}

deploy_challenge() {
  # HOOK_CHAIN support: loop through arguments per 3
  for ((i=1; i<=$#; i=i+3)); do
    t=$((i + 2))
    local DOMAIN="${!i}"
    local TOKEN_VALUE="${!t}"
    _log "acme-dns: deploy_challenge: $DOMAIN"

    if [[ "${DOMAIN}" == "*."* ]]; then
      _log "Domain ${DOMAIN} is a wildcard domain, ACME challenge will be for domain apex (${DOMAIN:2})"
      DOMAIN="${DOMAIN:2}"
    fi

    if [[ -v ACMEDNS_USERNAME[@] ]] && [[ "${ACMEDNS_USERNAME["$DOMAIN"]+isset}" ]]; then
      _ACMEDNS_USERNAME=${ACMEDNS_USERNAME["$DOMAIN"]}
    fi
    if [[ -v ACMEDNS_PASSWORD[@] ]] && [[ "${ACMEDNS_PASSWORD["$DOMAIN"]+isset}" ]]; then
      _ACMEDNS_PASSWORD=${ACMEDNS_PASSWORD["$DOMAIN"]}
    fi
    if [[ -v ACMEDNS_SUBDOMAIN[@] ]] && [[ "${ACMEDNS_SUBDOMAIN["$DOMAIN"]+isset}" ]]; then
      _ACMEDNS_SUBDOMAIN=${ACMEDNS_SUBDOMAIN["$DOMAIN"]}
    fi

    [[ -n "${ACMEDNS_UPDATE_URL:-}" ]]                               || _error "ACMEDNS_UPDATE_URL is required"
    [[ -n "${_ACMEDNS_USERNAME:=${ACMEDNS_USERNAME_DEFAULT:-}}" ]]   || _error "No ACMEDNS_USERNAME for $DOMAIN and no default set"
    [[ -n "${_ACMEDNS_PASSWORD:=${ACMEDNS_PASSWORD_DEFAULT:-}}" ]]   || _error "No ACMEDNS_PASSWORD for $DOMAIN and no default set"
    [[ -n "${_ACMEDNS_SUBDOMAIN:=${ACMEDNS_SUBDOMAIN_DEFAULT:-}}" ]] || _error "No ACMEDNS_SUBDOMAIN for $DOMAIN and no default set"

    hdr_user="X-Api-User: $_ACMEDNS_USERNAME"
    hdr_key="X-Api-Key: $_ACMEDNS_PASSWORD"
    data="{\"subdomain\":\"$_ACMEDNS_SUBDOMAIN\", \"txt\": \"$TOKEN_VALUE\"}"

    #_log "curl ${CURL_OPTS:-} -Ss -X POST -H "$hdr_user" -H "$hdr_key" -d "$data" $ACMEDNS_UPDATE_URL"
    #exit 1
    response=$(curl ${CURL_OPTS:-} -Ss -X POST -H "$hdr_user" -H "$hdr_key" -d "$data" $ACMEDNS_UPDATE_URL 2>&1)
    #_log "$response"
    if ! echo "$response" | grep "\"$TOKEN_VALUE\"" >/dev/null; then
      _error "invalid response from acme-dns: \"$response\""
    fi
  done
}

HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_challenge)$ ]]; then
  if [[ -f "${CONFIG}" ]]; then
    . "${CONFIG}"
    if [[ -n "${ACMEDNS_CONFIG:-}" ]] && [[ -f "${ACMEDNS_CONFIG}" ]]; then
      # external config only to avoid declaring arrays in main config file
      declare -A ACMEDNS_USERNAME
      declare -A ACMEDNS_PASSWORD
      declare -A ACMEDNS_SUBDOMAIN
      . "${ACMEDNS_CONFIG}"
    fi
  fi
  "$HANDLER" "$@"
fi

