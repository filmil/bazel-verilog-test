#! /bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Structural checks on the synthesized netlist. The behavioural check is
# counter_netlist_test, which simulates this same netlist.

set -euo pipefail

readonly _netlist="${1}"
readonly _stat="${2}"

# counter_tmp is 128 bits wide, so the design needs 128 flip flops.
readonly _want_flops=128

if ! grep -q '^module counter' "${_netlist}"; then
  echo "netlist ${_netlist} declares no module counter"
  exit 1
fi

# The source adds with `counter_tmp + 1`. Synthesis has to turn that into
# gates, so an arithmetic operator surviving into the netlist means the adder
# was never mapped.
if grep -qE '[^/]\+[^+]' "${_netlist}"; then
  echo "netlist ${_netlist} still contains an arithmetic operator"
  grep -nE '[^/]\+[^+]' "${_netlist}" | head -5
  exit 1
fi

# Gate level logic shows up as continuous assignments of bitwise operators.
if ! grep -qE '^\s+assign .* [&^|~]' "${_netlist}"; then
  echo "netlist ${_netlist} has no gate level assignments"
  exit 1
fi

# In the stat report the count comes first and the cell name second.
got_flops="$(awk '$2 ~ /^\$_.*DFF.*_$/ { sum += $1 } END { print sum+0 }' \
  "${_stat}")"
readonly got_flops

if [[ "${got_flops}" != "${_want_flops}" ]]; then
  echo "netlist has ${got_flops} flip flops; wanted ${_want_flops}"
  echo "--- cell counts ---"
  grep -E '\$_' "${_stat}" || true
  exit 1
fi
