#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
WATCH_SH="$SCRIPT_DIR/../watch.sh"

exec 3< <(tilt up --stream)
# block until tilt has started, so we know we can get to the api
# https://stackoverflow.com/a/21002153
sed '/Successfully loaded Tiltfile/q' <&3 ; cat <&3 &

while read -r RESOURCE_NAME EVENT RESULT DURATION; do
  if [[ $RESOURCE_NAME == '(Tiltfile)' ]] && [[ $EVENT == 'finish' ]]; then
    tilt trigger init
  fi
  echo "$RESOURCE_NAME $EVENT $RESULT"
done < <("$WATCH_SH" 'bash -c '"'"'echo "$RESOURCE_NAME" "$EVENT" "$RESULT" "$DURATION"'"'"'')
