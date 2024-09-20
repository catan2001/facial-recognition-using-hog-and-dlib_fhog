# TCL script for Vivado UVM.
#!/usr/bin/tclsh

# Get the directory of the current script
set script_dir [file dirname [info script]]

# Change the directory to the scripts dir
cd $script_dir

puts "Running HOG UVM TCL script..."
# Set design under test folder path...
set dut_dir ../../../facial-recognition-using-hog-and-dlib_fhog/RTL_axi
set uvm_dir ../VivadoIsDumb.srcs/sources_1/imports/uvm_files

puts "Creating VivadoUvm directory..."
file mkdir ../VivadoUvm/

cd ../VivadoUvm/
set root_dir [pwd]

# Creating new project:
puts "Creating new project..."
create_project hog_uvm -part xc7z010clg400-1 

# Define the prefix for the board part (common part)
set target_prefix "digilentinc.com:zybo-z7-10"

# Get the list of available board parts
set available_boards [get_board_parts]

# Loop through the available board parts to find the one you're looking for
foreach board_part $available_boards {
    if {[string match "$target_prefix*" $board_part]} {
        set selected_board $board_part
        break
    }
}

# Print the selected board part to verify
puts "Selected Board Part: $selected_board"
set_property board_part $selected_board [current_project]

# Adding Axi Light Source Files:
puts "Adding Axi Light Source Files..."
add_files -norecurse $dut_dir/axi_light_v1_0.vhd
add_files -norecurse $dut_dir/axi_light_v1_0_S00_AXI.vhd

# Adding Control Path Source Files:
puts "Adding Control Path Source Files..."
add_files -norecurse $dut_dir/FSM.vhd
add_files -norecurse $dut_dir/bram_to_dram.vhd
add_files -norecurse $dut_dir/dram_to_bram.vhd
add_files -norecurse $dut_dir/control_logic.vhd
add_files -norecurse $dut_dir/control_path_v2.vhd

# Adding Data Path Source Files:
puts "Adding Data Path Source Files..."
add_files -norecurse $dut_dir/Dual_Port_BRAM.vhd
add_files -norecurse $dut_dir/DSP_AA.vhd
add_files -norecurse $dut_dir/DSP_MA.vhd
add_files -norecurse $dut_dir/DSP_MS.vhd
add_files -norecurse $dut_dir/DSP_addr_A0.vhd
add_files -norecurse $dut_dir/DSP_addr_AX.vhd
add_files -norecurse $dut_dir/DSP_addr_B0.vhd
add_files -norecurse $dut_dir/DSP_addr_BX.vhd
add_files -norecurse $dut_dir/demux1_4.vhd
add_files -norecurse $dut_dir/demux1_8.vhd
add_files -norecurse $dut_dir/mux2_1.vhd
add_files -norecurse $dut_dir/mux4_1.vhd
add_files -norecurse $dut_dir/mux16_1.vhd
add_files -norecurse $dut_dir/filter.vhd
add_files -norecurse $dut_dir/core_unit.vhd
add_files -norecurse $dut_dir/core_top.vhd
add_files -norecurse $dut_dir/data_path.vhd

# Adding Top Source Files:
puts "Adding Top Source Files..."
add_files -norecurse $dut_dir/top.vhd
add_files -norecurse $dut_dir/top_axi.vhd

update_compile_order -fileset sources_1

# Adding Simulation Files"
puts "Adding UVM Simulation Files"

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $uvm_dir/agents/axil_gp_agent/hog_axil_gp_agent_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $uvm_dir/agents/axis_hp0_agent/hog_axis_hp0_agent_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $uvm_dir/agents/axis_hp1_agent/hog_axis_hp1_agent_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $uvm_dir/sequence_items/hog_seq_items_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $uvm_dir/sequencers/hog_sequencers_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $uvm_dir/sequences/hog_seq_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $uvm_dir/tests/test_hog_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $uvm_dir/configuration.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $uvm_dir/golden_vector_cfg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $uvm_dir/hog_interface.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $uvm_dir/hog_top.sv

update_compile_order -fileset sim_1

set_property -name {xsim.compile.xvlog.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.xsim.more_options} -value {-testplusarg UVM_TESTNAME=hog_uvm -testplusarg UVM_VERBOSITY=UVM_LOW} -objects [get_filesets sim_1]







