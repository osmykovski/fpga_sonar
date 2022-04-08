# create project
create_project sonar vivado -part xc7z010clg400-1

# set up project
set_property target_language verilog [current_project]

# add source code files
# * hdl sources
add_files -fileset sources_1 -quiet {sources/hdl}
# * testbench
add_files -fileset sim_1 -quiet {sources/tb}
# * constraints
add_files -fileset constrs_1 -quiet {sources/xdc}
# * non-bd ip-cores
# add_files -norecurse [glob sources/ip/*/*.xci]

# ip catalog
set_property ip_repo_paths {ip} [current_project]
update_ip_catalog

# bd deploy
add_files -fileset sources_1 -quiet {sources/bd/design_1.bd}
make_wrapper -files [get_files {sources/bd/design_1.bd}] -top
add_files -norecurse {sources/bd/hdl/design_1_wrapper.v}

# pre and post scripts
add_files -fileset utils_1 -quiet [glob sources/script/*_pre.tcl]
add_files -fileset utils_1 -quiet [glob sources/script/*_post.tcl]
# * synthesis
set_property STEPS.SYNTH_DESIGN.TCL.PRE [get_files {sources/script/synth_pre.tcl} -of [get_fileset utils_1]] [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.TCL.POST [get_files {sources/script/synth_post.tcl} -of [get_fileset utils_1]] [get_runs synth_1]
# * implementation
set_property STEPS.INIT_DESIGN.TCL.PRE [get_files {sources/script/impl_pre.tcl} -of [get_fileset utils_1]] [get_runs impl_1]
set_property STEPS.INIT_DESIGN.TCL.POST [get_files {sources/script/impl_post.tcl} -of [get_fileset utils_1]] [get_runs impl_1]
# * bitstream
set_property STEPS.WRITE_BITSTREAM.TCL.PRE [get_files {sources/script/bit_pre.tcl} -of [get_fileset utils_1]] [get_runs impl_1]
set_property STEPS.WRITE_BITSTREAM.TCL.POST [get_files {sources/script/bit_post.tcl} -of [get_fileset utils_1]] [get_runs impl_1]

# project after-deploy settings
source {sources/script/prj_set.tcl}
