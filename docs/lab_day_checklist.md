# Lab Day Checklist (Mon Nov 23)

## 1. Get the code on the lab computer

Download the repo: **Code → Download ZIP** on GitHub, then unzip it.

## 2. Build the bitstream (about 5 min)

**Option A – Vivado GUI** (same as the labs)

1. Create Project → RTL Project.
2. Add Sources → add every file in `src/`. Do **not** add the files in `sim/`.
3. Add Constraints → `constraints/reaction_game.xdc`.
4. Part: **xc7a35tcpg236-1** (Basys 3).
5. Right-click `reaction_game_top` → **Set as Top** (if it is not already).
6. Click **Generate Bitstream**.
7. Check: no errors, and **WNS is positive** in the timing summary.

**Option B – one command** (Tcl console or terminal, inside the repo folder)

```
vivado -mode batch -source scripts/build.tcl
```

The file is `build/reaction_game.bit`.

## 3. Program the board

Open Hardware Manager → Open Target → Auto Connect → Program Device → pick the `.bit` file.

## 4. Test on the board

| # | Test | What should happen | OK? |
|---|---|---|---|
| 1 | Power on / press btnU | Display shows `----`, LEDs off | ☐ |
| 2 | Press btnC | Still `----`, LEDs off (waiting) | ☐ |
| 3 | Wait | After 1–5 s all 16 LEDs turn on, display counts up in ms | ☐ |
| 4 | Press btnC fast | LEDs off, display shows your time | ☐ |
| 5 | Play 3 more rounds | The wait time feels different each round | ☐ |
| 6 | Press btnC during the wait | Display shows `Err` | ☐ |
| 7 | Press btnC on the `Err` screen | A new round starts | ☐ |
| 8 | sw[0] up on a result | Shows best time (the smallest so far) | ☐ |
| 9 | sw[0] down | Shows last time | ☐ |
| 10 | Start a round and don't press | Stops at `9999` after 10 s | ☐ |
| 11 | Press btnU | Back to `----`, best time cleared | ☐ |
| 12 | Hold btnC down a long time | Counts as one press only | ☐ |

## 5. Before you leave

- [ ] Photo of the board showing a time
- [ ] Photo of `Err`
- [ ] Short video of one full round (for the report and the demo)
- [ ] Screenshot of the timing summary (WNS) and utilization
- [ ] Write down every bug: what you did, what you saw, what you expected
- [ ] Save the `.bit` file to a USB stick / Google Drive
