set_property PACKAGE_PIN U20 [get_ports SCK_H]
set_property PACKAGE_PIN R19 [get_ports SCK_L]
set_property PACKAGE_PIN W20 [get_ports SD_H]
set_property PACKAGE_PIN T19 [get_ports SD_L]
set_property PACKAGE_PIN T20 [get_ports WS_H]
set_property PACKAGE_PIN N20 [get_ports WS_L]
set_property IOSTANDARD LVCMOS33 [get_ports SCK_H]
set_property IOSTANDARD LVCMOS33 [get_ports SCK_L]
set_property IOSTANDARD LVCMOS33 [get_ports SD_H]
set_property IOSTANDARD LVCMOS33 [get_ports SD_L]
set_property IOSTANDARD LVCMOS33 [get_ports WS_H]
set_property IOSTANDARD LVCMOS33 [get_ports WS_L]
set_property DRIVE 12 [get_ports SCK_H]
set_property DRIVE 12 [get_ports SCK_L]
set_property DRIVE 12 [get_ports WS_H]
set_property DRIVE 12 [get_ports WS_L]
set_property SLEW FAST [get_ports SCK_H]
set_property SLEW FAST [get_ports SCK_L]
set_property SLEW FAST [get_ports WS_H]
set_property SLEW FAST [get_ports WS_L]
set_property PULLDOWN true [get_ports SD_H]
set_property PULLDOWN true [get_ports SD_L]

set_property PACKAGE_PIN P20 [get_ports wave]
set_property IOSTANDARD LVCMOS33 [get_ports wave]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]






create_pblock interconnect_0
add_cells_to_pblock [get_pblocks interconnect_0] [get_cells -quiet [list BD/design_1_i/axi_interconnect_0]]
resize_pblock [get_pblocks interconnect_0] -add {SLICE_X0Y50:SLICE_X5Y74}
create_pblock interconnect_1
add_cells_to_pblock [get_pblocks interconnect_1] [get_cells -quiet [list BD/design_1_i/axi_interconnect_1]]
resize_pblock [get_pblocks interconnect_1] -add {SLICE_X0Y25:SLICE_X5Y49}
