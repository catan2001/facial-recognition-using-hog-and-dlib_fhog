#include "VP.hpp"

Vp::Vp(sc_core::sc_module_name name)
	: sc_module(name),
	interconnect("Interconnect"),
	dram("Dram"),
	dram_ctrl("Dram_Ctrl"),
    bram("Bram"),
    bram_ctrl("Bram_Ctrl"),
	soft("Soft"),
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
    bram_ctrl.bram_socket(bram.bram_ctrl_socket);   
    
    // Connecting HW with BRAM_CTRL
	hard.bram_ctrl_socket.bind(bram_ctrl.filter_socket);
    
	soft.interconnect_socket.bind(interconnect.soft_socket);
	SC_REPORT_INFO("Virtual Platform", "Constructed.");
}

Vp::~Vp()
{
	SC_REPORT_INFO("Virtual Platform", "Destroyed.");
}
