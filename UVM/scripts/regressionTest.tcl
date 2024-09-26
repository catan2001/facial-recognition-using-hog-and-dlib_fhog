# TCL script for running regression tests
# USAGE: run from Vivado, you can change script to run randomized set of pictures,
#        or to make it run all pictures from small to large.

# Get the directory of the current script
set script_dir [file dirname [info script]]

# Change the directory to the scripts dir
cd $script_dir

# Set design under test folder path...
set dut_dir ../../RTL_axi
set uvm_dir ../

file mkdir $uvm_dir/VivadoUVM/RegressionCoverageLogs
set reg_log_dir $uvm_dir/VivadoUVM/RegressionCoverageLogs

for {set i 1} {$i <= 1} {incr i} {
    set db_name "covdb_$i" ;
    set xsim_command "set_property -name \{xsim.simulate.xsim.more_options\} -value \{-testplusarg UVM_TESTNAME=test_hog_simple -testplusarg UVM_VERBOSITY=UVM_LOW -sv_seed random -runall -cov_db_name $db_name\} -objects \[get_filesets sim_1\]"
    set xsim_define_cmd "set_property verilog_define {IMG_NUM=$i} -objects \[get_filesets sim_1\]"
    eval $xsim_command
    eval $xsim_define_cmd
    launch_simulation
run all

    if {$i+1 <= 12} {
        close_sim
    }
}

#for {set i 1} {$i <= 1} {incr i} {
#    set db_name "covdb_$i"
#    exec xcrg -report_format html -dir $uvm_dir/VivadoUVM/hog_uvm.sim/sim_1/behav/xsim/xsim.covdb/$db_name/ -report_dir $reg_log_dir
#}

