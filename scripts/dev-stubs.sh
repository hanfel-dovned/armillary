#!/usr/bin/env bash
# dev-stubs.sh up|down: the four stubs the gates want, for the fleet set
# armillary-dev (vendor ~syx on http://localhost:8124), on 3410 to 3413
# so they never meet the stubs on 3399 to 3402. Logs and pids go in
# $STUB_DIR (default /tmp/armillary-dev-stubs).
#
#   provider 3410 (key stub-key)   stripe 3411   btcpay 3412   brave 3413
set -uo pipefail
cd "$(dirname "$0")/.."
D=${STUB_DIR:-/tmp/armillary-dev-stubs}; HOST=${STUB_SHIP:-http://localhost:8124}
mkdir -p "$D"
if [[ -f $D/pids ]]; then kill $(cat "$D/pids") 2>/dev/null; rm -f "$D/pids"; sleep 1; fi
[[ ${1:-} == up ]] || exit 0
start() { nohup python3 -u "$@" > "$D/$(basename "$1" .py).log" 2>&1 & echo $! >> "$D/pids"; }
start scripts/fake-provider.py 3410 stub-key
start scripts/fake-stripe.py 3411 whsec_gate "$HOST"
start scripts/fake-btcpay.py 3412 whsec_gate "$HOST"
start scripts/fake-brave.py 3413
sleep 1
ss -ltn | grep -cE ':341[0-3] ' | grep -qx 4 || { echo "dev-stubs: not all four stubs listen; see $D" >&2; exit 1; }
