#!/usr/bin/tclsh
# ===============================================
# TCL Script for Coverage Analysis in Vivado UVM
# ===============================================
# This script is used to generate coverage reports from Vivado UVM simulations
# using the Xilinx Coverage Report Generator (XCRG). It sets up the required
# directories, runs the XCRG command, and saves the coverage reports in a 
# specified directory.

# Get the directory of the current script
set script_dir [file dirname [info script]]

# Change the directory to the script's directory
cd $script_dir

# Set design under test (DUT) folder path
set dut_dir "../../RTL_axi"

# Set UVM directory
set uvm_dir "../"

# Create CoverageLogs directory if it doesn't exist
file mkdir $uvm_dir/VivadoUVM/CoverageLogs

# Set path to the simulation results directory (replace this with your actual sim result path if different)
set sim_dir "$uvm_dir/VivadoUVM/hog_uvm.sim/sim_1/behav/xsim/"

# Set up the XCRG command to generate HTML coverage report
set cvrg_cmd "exec xcrg -report_format html -dir $sim_dir -report_dir $uvm_dir/VivadoUVM/CoverageLogs"

eval $cvrg_cmd

puts "Coverage report generation complete. Reports stored in $uvm_dir/VivadoUVM/CoverageLogs."
