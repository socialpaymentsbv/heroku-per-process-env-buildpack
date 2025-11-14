#!/usr/bin/env bash

if [[ ${DYNO:-} =~ ^([A-Za-z0-9_-]+)\.([0-9]+)$ ]]; then
  DYNO_TYPE="${BASH_REMATCH[1]}"
  DYNO_INDEX="${BASH_REMATCH[2]}"
else
  return 0 2>/dev/null || exit 0
fi

PREFIX1="$(printf '%s' "$DYNO_TYPE" | tr '[:lower:]' '[:upper:]')"
PREFIX2="${PREFIX1}_$(printf '%s' "$DYNO_INDEX" | tr '[:lower:]' '[:upper:]')"

for VAR_NAME in $(compgen -v); do
  if [[ $VAR_NAME == ${PREFIX1}__* ]]; then
    TARGET="${VAR_NAME#${PREFIX1}__}"
    [[ -n $TARGET ]] || continue
    VALUE="${!VAR_NAME}"
    export "$TARGET=$VALUE"
  fi
done

for VAR_NAME in $(compgen -v); do
  if [[ $VAR_NAME == ${PREFIX2}__* ]]; then
    TARGET="${VAR_NAME#${PREFIX2}__}"
    [[ -n $TARGET ]] || continue
    VALUE="${!VAR_NAME}"
    export "$TARGET=$VALUE"
  fi
done
