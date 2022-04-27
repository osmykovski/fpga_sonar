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
add_files -fileset sim_1 -quiet -norecurse [glob sources/ip/*/*.xci]

# ip catalog
set_property ip_repo_paths {ip} [current_project]
update_ip_catalog

# bd deploy
add_files -fileset sources_1 -quiet {sources/bd/design_1.bd}
make_wrapper -files [get_files {sources/bd/design_1.bd}] -top
add_files -norecurse {sources/bd/hdl/design_1_wrapper.v}
