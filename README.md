# Reaction-Time Game (Basys 3, Verilog)

**COMPE 470L – Digital Logic Laboratory · SDSU · Fall 2026 · Final Project**

A reaction-time game on the Digilent Basys 3 FPGA board.
Press the button to start. After a random wait of 1–5 seconds, the LEDs light up.
Press again as fast as you can. Your time in milliseconds shows on the seven-segment display.
Press too early and you get an error. The board keeps your best time.

## Controls

| Input | Use |
|---|---|
| `btnC` | Start / react |
| `btnU` | Reset |
| `sw[0]` | Show last time or best time |
| `led[15:0]` | "GO" signal |
| 7-segment | `----` ready / waiting, live ms during GO, your time after, `Err` on a false start |

## Modules

| Module | What it does | Status |
|---|---|---|
| `tick_gen` | 1 ms tick from the 100 MHz clock | ✅ done, tested |
| `ms_counter` | Counts 0000–9999 ms in BCD, stops at 9999 | ✅ done, tested |
| `lfsr_random` | 16-bit LFSR, random wait of 1000–5095 ms | ✅ done, tested |
| `button_pulse` | Debounce + one-clock pulse (from Lab 6) | ✅ done, tested |
| `display_mux`, `bcd_to_7seg` | Drive the display (from Lab 6) | ✅ done, tested |
| `game_fsm` | READY → WAIT → GO → RESULT / EARLY | ✅ done, tested |
| `best_score` | Saves the fastest time | ✅ done, tested |
| `reaction_game_top` | Top module | ✅ done, full-game test passes |

## Folders

```
src/          Verilog source
sim/          Self-checking testbenches
constraints/  Basys 3 XDC file (reaction_game.xdc)
docs/         Diagrams and report
scripts/      Vivado build script
```

## Build the bitstream

```bash
vivado -mode batch -source scripts/build.tcl
```

This makes `build/reaction_game.bit`. Or, in the Vivado GUI, add everything in `src/` and `constraints/`, set `reaction_game_top` as top, and click Generate Bitstream. Part: `xc7a35tcpg236-1`.

## Run the tests

With [Icarus Verilog](https://steveicarus.github.io/iverilog/):

```bash
cd sim
iverilog -g2012 -o tb ../src/ms_counter.v tb_ms_counter.v && vvp tb
```

Each testbench prints `PASS` or `FAIL`. The full game test (`tb_reaction_game_top`) needs all of `src/`:

```bash
iverilog -g2012 -o tb ../src/*.v tb_reaction_game_top.v && vvp tb
```

It plays a normal round, a false start, a slower round, a new best, a no-press timeout, and a reset. They also run in the Vivado simulator.

## Progress

- **Nov 16, 2026** – Proposal approved. Added `tick_gen`, `ms_counter`, `lfsr_random` with testbenches.
- **Nov 16, 2026** – Added `button_pulse`, `bcd_to_7seg` (from Lab 6), `display_mux` (taken out of the Lab 6 clock), testbenches, and the Basys 3 XDC.
- **Nov 16, 2026** – Added `game_fsm`, `best_score`, `reaction_game_top`, "Err" and "-" on the display, a full-game testbench, and a Vivado build script.

## Reference

Idea based on [Reaction timer / reflex tester in Verilog](https://simplefpga.blogspot.com/2013/03/reaction-timer-reflex-tester-in-verilog.html) (simplefpga.blogspot.com).
