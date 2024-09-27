# Get the directory of the current script - info takes all information about the script (date, path, size...) 
# file dirname pulls the path to the sript out of the info
set script_dir [file dirname [info script]]

# Change the directory to the scripts dir
cd $script_dir

puts "Running HOG DUT TCL script..."
# Set design under test folder path...
set dut_dir ../

file mkdir ../Project_HOG/

cd ../Project_HOG/
set root_dir [pwd]

# Creating new project:
puts "Creating new project..."
create_project project_hog -part xc7z010clg400-1 -force

set_property board_part digilentinc.com:zybo:part0:2.0 [current_project]
set_property target_language VHDL [current_project]

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

# Pokretanje sinteze radi provere ispravnosti IP jezgra
launch_runs synth_1 -jobs 6
wait_on_run synth_1


ipx::package_project -root_dir $root_dir/ip_repo -vendor xilinx.com -library user -taxonomy /UserIP -import_files -force
set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property  ip_repo_paths  $root_dir/ip_repo [current_project]
update_ip_catalog

# Stvaranje blok-dizajna
create_bd_design "top_axi_bd"
update_compile_order -fileset sources_1

# Ubacivanje Zynq procesorske jedinice i njena podesavanja
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]
set_property -dict [list CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1}] [get_bd_cells processing_system7_0]
set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50}] [get_bd_cells processing_system7_0]
set_property -dict [list CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_USE_M_AXI_GP1 {1} CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.PCW_USE_S_AXI_HP1 {1} ] [get_bd_cells processing_system7_0]
set_property -dict [list CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_IRQ_F2P_INTR {1}] [get_bd_cells processing_system7_0]

# Ubacivanje Hog IP jedinice
startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:top_axi:1.0 top_axi_0
endgroup

# Ubacivanje DMA jedinica
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0
endgroup
set_property -dict [list CONFIG.c_s_axis_s2mm_tdata_width.VALUE_SRC USER] [get_bd_cells axi_dma_0]
set_property -dict [list CONFIG.c_include_sg {0} CONFIG.c_m_axis_mm2s_tdata_width {64}] [get_bd_cells axi_dma_0]
set_property -dict [list CONFIG.c_s_axis_s2mm_tdata_width {64} CONFIG.c_sg_length_width {15}] [get_bd_cells axi_dma_0]

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_1
endgroup
set_property -dict [list CONFIG.c_s_axis_s2mm_tdata_width.VALUE_SRC USER] [get_bd_cells axi_dma_1]
set_property -dict [list CONFIG.c_include_sg {0} CONFIG.c_m_axis_mm2s_tdata_width {64}] [get_bd_cells axi_dma_1]
set_property -dict [list CONFIG.c_s_axis_s2mm_tdata_width {64} CONFIG.c_sg_length_width {15}]  [get_bd_cells axi_dma_1]

# Ubacivanje Concat za interrupt
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
endgroup
set_property CONFIG.NUM_PORTS {4} [get_bd_cells xlconcat_0]



# Automatsko povezivanje axi portova
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/axi_dma_0/S_AXI_LITE} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/axi_dma_1/S_AXI_LITE} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_dma_1/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/axi_dma_0/M_AXI_MM2S} Slave {/processing_system7_0/S_AXI_HP0} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/axi_dma_1/M_AXI_MM2S} Slave {/processing_system7_0/S_AXI_HP1} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins processing_system7_0/S_AXI_HP1]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP1} Slave {/top_axi_0/s00_axi} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins top_axi_0/s00_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/processing_system7_0/FCLK_CLK0 (50 MHz)} Clk_xbar {/processing_system7_0/FCLK_CLK0 (50 MHz)} Master {/axi_dma_0/M_AXI_S2MM} Slave {/processing_system7_0/S_AXI_HP0} ddr_seg {Auto} intc_ip {/axi_mem_intercon} master_apm {0}}  [get_bd_intf_pins axi_dma_0/M_AXI_S2MM]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/processing_system7_0/FCLK_CLK0 (50 MHz)} Clk_xbar {/processing_system7_0/FCLK_CLK0 (50 MHz)} Master {/axi_dma_1/M_AXI_S2MM} Slave {/processing_system7_0/S_AXI_HP1} ddr_seg {Auto} intc_ip {/axi_mem_intercon_1} master_apm {0}}  [get_bd_intf_pins axi_dma_1/M_AXI_S2MM]
endgroup

#Rucno povezivanje interrupt signala DMA blokova sa PS7
connect_bd_net [get_bd_pins axi_dma_0/mm2s_introut] [get_bd_pins xlconcat_0/In0]
connect_bd_net [get_bd_pins axi_dma_0/s2mm_introut] [get_bd_pins xlconcat_0/In1]
connect_bd_net [get_bd_pins axi_dma_1/mm2s_introut] [get_bd_pins xlconcat_0/In2]
connect_bd_net [get_bd_pins axi_dma_1/s2mm_introut] [get_bd_pins xlconcat_0/In3]
connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins processing_system7_0/IRQ_F2P]
connect_bd_intf_net [get_bd_intf_pins top_axi_0/s00_axis] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
connect_bd_intf_net [get_bd_intf_pins top_axi_0/s01_axis] [get_bd_intf_pins axi_dma_1/M_AXIS_MM2S]
connect_bd_intf_net [get_bd_intf_pins top_axi_0/m00_axis] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins top_axi_0/m01_axis] [get_bd_intf_pins axi_dma_1/S_AXIS_S2MM]
connect_bd_net [get_bd_pins top_axi_0/s00_axi_aresetn] [get_bd_pins rst_ps7_0_50M/peripheral_aresetn]


# Prostorno uredjivanje blok-dizajna
set_property location {2.5 797 257} [get_bd_cells xlconcat_0]
set_property location {1 332 226} [get_bd_cells axi_dma_0]
set_property location {1 327 478} [get_bd_cells axi_dma_1]
set_property location {3 1254 383} [get_bd_cells processing_system7_0]
set_property location {1 138 364} [get_bd_cells top_axi_0]
set_property location {5 1506 684} [get_bd_cells rst_ps7_0_50M]
set_property location {6 1871 5} [get_bd_cells axi_mem_intercon]
set_property location {6 1875 314} [get_bd_cells axi_mem_intercon_1]
set_property location {6 1876 570} [get_bd_cells ps7_0_axi_periph]
set_property location {6 1870 814} [get_bd_cells ps7_0_axi_periph_1]
regenerate_bd_layout -routing

update_compile_order -fileset sources_1

# Stvaranje HDL wrapper-a
make_wrapper -files [get_files $root_dir/project_hog.srcs/sources_1/bd/top_axi_bd/top_axi_bd.bd] -top
add_files -norecurse $root_dir/project_hog.gen/sources_1/bd/top_axi_bd/hdl/top_axi_bd_wrapper.vhd
update_compile_order -fileset sources_1

set_property top top_axi_bd_wrapper [current_fileset]
update_compile_order -fileset sources_1

reset_run synth_1
#launch_runs synth_1 -jobs 6
#launch_runs impl_1 -jobs 6

set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

launch_runs impl_1 -to_step write_bitstream -jobs 6
wait_on_run impl_1
#write_hw_platform -fixed -include_bit -force -file $root_dir/top_axi_bd_wrapper.xsa

update_compile_order -fileset sources_1
write_hw_platform -fixed -include_bit -force -file C:/Users/cata/Desktop/Project/test_script/facial-recognition-using-hog-and-dlib_fhog/RTL_axi/Project_HOG/top_axi_bd_wrapper.xsa

# Kopiranje .xsa i .bit fajlova u vitis folder
cd ../
mkdir vitis
cd Project_HOG/
file copy -force top_axi_bd_wrapper.xsa ../vitis/top_axi_bd_wrapper.xsa
file copy -force project_hog.runs/impl_1/top_axi_bd_wrapper.bit ../vitis/top_axi_bd_wrapper.bit
