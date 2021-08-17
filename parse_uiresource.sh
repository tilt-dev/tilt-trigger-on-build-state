#!/bin/bash

# input: uiresource json
# output: build starts and finishes as space-delimited lines:
# 1. <build name>
# 2. <timestamp> (format: 2021-07-22T18:23:18.401460Z)
# 3. ["start" | "finish"]
# 4. <duration in ms> (only on "finish")
# 5. ["success" | "failure"] (only on "finish")
# example:
# foo 2021-07-22T18:24:15.982925Z start
# foo 2021-07-22T18:24:16.026010Z finish 43 failure

set -euo pipefail

iso8601_to_ns() {
  date '+%s%N' --date="$1"
}

build_events() {
  R=$1
  NAME="$(echo "$R" | jq -r '.metadata.name')"
  CURRENT_BUILD_START="$(echo "$R" | jq -r '.status.currentBuild.startTime')"
  if [[ $CURRENT_BUILD_START != "null" ]]; then
    echo "$NAME $CURRENT_BUILD_START start"
  fi
  while read -r BUILD; do
    IFS=' ' read -r START_TIME FINISH_TIME ERROR < <(echo "$BUILD")
    echo "$NAME $START_TIME start"
    if [[ $FINISH_TIME != null ]]; then
      START_TIME_NS="$(iso8601_to_ns "$START_TIME")"
      FINISH_TIME_NS="$(iso8601_to_ns "$FINISH_TIME")"
      DURATION_MS=$(((FINISH_TIME_NS - START_TIME_NS) / 1000 / 1000))
      RESULT=success
      if [[ $ERROR != null ]]; then
        RESULT=failure
      fi
      echo "$NAME $FINISH_TIME finish $DURATION_MS $RESULT"
    fi
  done < <(echo "$R" | jq -r '.status.buildHistory[]? | "\(.startTime) \(.finishTime) \(.error)"')
}

build_events "$(cat)"
