# Builds the bitstream for the Basys 3 without making a Vivado project.
# Run from the repo folder:
#     vivado -mode batch -source scripts/build.tcl
# Output: build/reaction_game.bit (plus timing and utilization reports)

set part xc7a35tcpg236-1
file mkdir build

read_verilog [glob src/*.v]
read_xdc constraints/reaction_game.xdc

synth_design -top reaction_game_top -part $part
opt_design
place_design
route_design

report_timing_summary -file build/timing.rpt
report_utilization     -file build/utilization.rpt
write_bitstream -force build/reaction_game.bit

puts "Done: build/reaction_game.bit"
