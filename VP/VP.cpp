#include "VP.hpp"

Vp::Vp(sc_core::sc_module_name name)
	: sc_module(name),
	soft("Soft"),
	interconnect("Interconnect"),
	dram_ctrl("Dram_Ctrl"),
	dram("Dram"),
    bram("Bram"),
    bram_ctrl("Bram_Ctrl"),
	hard("Hard")
{
    
    // Connecting Interconnect with DRAM_CTRL and HW
	interconnect.dram_ctrl_socket.bind(dram_ctrl.interconnect_socket);
	interconnect.hw_socket.bind(bram_ctrl.interconnect_socket);

    // Connecting DRAM_CTRL with DRAM
    dram_ctrl.dram_socket.bind(dram.dram_ctrl_socket);

    // Connecting BRAM_CTRL with DRAM_CTRL
    bram_ctrl.dram_ctrl_socket(dram_ctrl.bram_ctrl_socket);   
    // Connecting BRAM_CTRL with BRAM
    bram_ctrl.bram_socket0(bram.bram_ctrl_socket0);
	bram_ctrl.bram_socket1(bram.bram_ctrl_socket1);  
	bram_ctrl.bram_socket2(bram.bram_ctrl_socket2);     
    
    // Connecting HW with BRAM_CTRL
	hard.bram_ctrl_socket.bind(bram_ctrl.filter_socket);
	// Connecting HW with DRAM_CTRL
	dram_ctrl.hw_socket.bind(hard.dram_ctrl_socket);
    
	soft.interconnect_socket.bind(interconnect.soft_socket);
	SC_REPORT_INFO("Virtual Platform", "Constructed.");
}

Vp::~Vp()
{
	SC_REPORT_INFO("Virtual Platform", "Destroyed.");
}
