open_project -reset sound_dma
set_top sound_dma
add_files ./sound_dma/main.cpp
add_files -tb ./sound_dma/tb.cpp -cflags "-Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"

open_solution -reset "solution1"
set_part {xc7z010-clg400-1} -tool vivado
create_clock -period 10 -name default
config_export -format ip_catalog -rtl verilog

set_directive_interface -mode axis -register -register_mode both "sound_dma" din
set_directive_interface -mode m_axi -depth 2048 -offset slave -bundle ctrl "sound_dma" mem
set_directive_interface -mode s_axilite -bundle ctrl "sound_dma"
set_directive_dataflow "sound_dma"

csynth_design
export_design
