#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PARSE_UIRESOURCE="$SCRIPT_DIR/../parse_uiresource.sh"

carp() {
  echo "$@" >&2
}

die() {
  carp "$@"
  exit 1
}

assertEqual() {
  EXPECTED="$1"
  ACTUAL="$2"
  MESSAGE="$3"
  if [[ "$EXPECTED" != "$ACTUAL" ]]; then
    carp "expected:"
    carp ""
    carp "$EXPECTED"
    carp ""
    carp "actual:"
    carp ""
    carp "$ACTUAL"
    carp ""
    die "$MESSAGE"
  fi
}

test() {
  INPUT="$1"
  EXPECTED_OUTPUT="$(<$2)"
  MESSAGE="$3"
  ACTUAL_OUTPUT="$($PARSE_UIRESOURCE <$INPUT)"
  assertEqual "$EXPECTED_OUTPUT" "$ACTUAL_OUTPUT" "failure on $INPUT: $MESSAGE"
}

test uiresource1.json uiresource1.out "resource w/ success, failure, and current build"
test uiresource2.json uiresource2.out "resource w/ success, failure, and no current build"
test uiresource3.json uiresource3.out "resource w/ no builds"
