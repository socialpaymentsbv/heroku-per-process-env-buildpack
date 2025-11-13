#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
RUNTIME_SCRIPT="$ROOT_DIR/lib/per-process-env.sh"

pass=0
fail=0

run_case() {
  local name="$1"
  local script
  script="$(cat)"

  if RUNTIME_SCRIPT="$RUNTIME_SCRIPT" bash -s <<<"$script"; then
    printf '✔ %s\n' "$name"
    pass=$((pass + 1))
  else
    printf '✖ %s\n' "$name"
    fail=$((fail + 1))
  fi
}

run_case "type prefix applies" <<'BASH'
set -euo pipefail
export DYNO="web.3"
export WEB__TOKEN="shared"
unset TOKEN || true
source "$RUNTIME_SCRIPT"
[ "${TOKEN:-}" = "shared" ]
BASH

run_case "index overrides type" <<'BASH'
set -euo pipefail
export DYNO="worker.1"
export WORKER__TOKEN="base"
export WORKER_1__TOKEN="specific"
unset TOKEN || true
source "$RUNTIME_SCRIPT"
[ "${TOKEN:-}" = "specific" ]
BASH

run_case "index specific variable" <<'BASH'
set -euo pipefail
export DYNO="run.42"
export RUN_42__SECRET="special"
unset SECRET || true
source "$RUNTIME_SCRIPT"
[ "${SECRET:-}" = "special" ]
BASH

run_case "invalid dyno ignored" <<'BASH'
set -euo pipefail
export DYNO="web"
export WEB__TOKEN="noop"
unset TOKEN || true
source "$RUNTIME_SCRIPT"
[ -z "${TOKEN:-}" ]
BASH

printf '\nSummary: %d passed, %d failed\n' "$pass" "$fail"

if [ "$fail" -ne 0 ]; then
  exit 1
fi
