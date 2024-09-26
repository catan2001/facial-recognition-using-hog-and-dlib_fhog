# ===============================================
# TCL Script for Running a Single Test in Vivado UVM
# ===============================================
# This script is used to run a single test in a Vivado UVM environment.
# It can specify the verilog_define macro for controlling the number of input 
# files (IMG_NUM). The IMG_NUM macro allows the user to specify which golden 
# vector is used for testing. If this macro is not set, the UVM will randomly 
# choose input and output files for the simulation.
#
# Key Features:
# - Allows setting the golden vector number via the IMG_NUM macro.
# - If IMG_NUM is not specified, the simulation randomly selects test vectors.
# - Automatically prepares the necessary directories and launches the simulation.
# - Uses random seed values for simulation (for varying test runs).
#
# How to Use:
# - Modify the value of `golden_vector_number` to set a specific test vector.
# - Launch the script to start the simulation.
#
# Arguments:
# - verilog_define IMG_NUM=value: Defines the number of input files for the test.
# - If not provided, a default value of 11 is used for `golden_vector_number`.
#
# Example:
# - To run the simulation with IMG_NUM set to 5:
#   set golden_vector_number 5
# ===============================================

# This number sets desired input-output file
set golden_vector_number 11

# Get the directory of the current script
set script_dir [file dirname [info script]]

# Change the directory to the scripts dir
cd $script_dir

# Set design under test folder path...
set dut_dir ../../RTL_axi
set uvm_dir ../

# Define the command for running the simulation
# This sets test name, verbosity, random seed, and run command
set xsim_command "set_property -name \{xsim.simulate.xsim.more_options\} -value \{-testplusarg UVM_TESTNAME=test_hog_simple -testplusarg UVM_VERBOSITY=UVM_LOW -sv_seed random -runall } -objects \[get_filesets sim_1\]"

# Define the command for setting the IMG_NUM macro
set xsim_define_cmd "set_property verilog_define {IMG_NUM=$golden_vector_number} -objects \[get_filesets sim_1\]"

eval $xsim_command
eval $xsim_define_cmd

launch_simulation
run all
