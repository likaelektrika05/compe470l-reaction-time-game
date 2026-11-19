#!/usr/bin/env bash
# Runs every testbench with Icarus Verilog. Exits with an error if any test fails.
# Usage: cd sim && ./run_all.sh
set -u
cd "$(dirname "$0")"
fail=0
for tb in tb_*.v; do
    name="${tb%.v}"
    if [ "$name" = "tb_reaction_game_top" ]; then
        srcs=(../src/*.v)
    else
        srcs=("../src/${name#tb_}.v")
    fi
    if ! iverilog -g2012 -o "/tmp/$name" "${srcs[@]}" "$tb"; then
        echo "FAIL: $name did not compile"; fail=1; continue
    fi
    out=$(vvp -n "/tmp/$name")
    echo "$out" | grep -E "PASS|FAIL|Round|Reset|sw\[0\]"
    echo "$out" | grep -q "^PASS" || fail=1
done
rm -f *.vcd
if [ $fail -eq 0 ]; then echo "ALL TESTS PASSED"; else echo "SOME TESTS FAILED"; fi
exit $fail
