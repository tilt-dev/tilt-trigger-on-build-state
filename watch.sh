#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PARSE_UIRESOURCE="$SCRIPT_DIR/parse_uiresource.sh"

LAST_PROCESSED_EVENT=0

process_event() {
  IFS=' ' read -r RESOURCE_NAME TIMESTAMP EVENT DURATION RESULT <<< "$1"
  CMD="$2"

  local TS_IN_MS
  TS_IN_MS="$(date '+%s%N' --date="$TIMESTAMP")"

  if (( TS_IN_MS <= LAST_PROCESSED_EVENT )); then
    return 0
  fi

  shift 1

  export RESOURCE_NAME
  export TIMESTAMP
  export EVENT
  export DURATION
  export RESULT
  eval "$CMD"

  LAST_PROCESSED_EVENT="$TS_IN_MS"
}


while read -r R; do
  while read -r EVENT; do
    process_event "$EVENT" "$@"
  done < <(echo "$R" | "$PARSE_UIRESOURCE")
done < <(tilt get uiresource -ojsonpath="{range .items[*]}{@}{'\n'}" --watch)
