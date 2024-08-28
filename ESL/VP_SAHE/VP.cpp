#include "VP.hpp"

Vp::Vp(sc_core::sc_module_name name)
	: sc_module(name),
	soft("Soft"),
	interconnect("Interconnect"),
	dram_ctrl("Dram_Ctrl"),
	dram("Dram"),
    bram("Bram"),
	bramX("BramOutX"),
    bramY("BramOutY"),
    bram_ctrl("Bram_Ctrl"),
	hard("Hard")
{
    
    // Connecting Interconnect with DRAM_CTRL and HW
	interconnect.dram_ctrl_socket.bind(dram_ctrl.interconnect_socket);
	interconnect.hw_socket.bind(bram_ctrl.interconnect_socket);

    // Connecting DRAM_CTRL with DRAM
    dram_ctrl.dram_socket.bind(dram.dram_ctrl_socket);

    // Connecting BRAM_CTRL with DRAM_CTRL
    bram_ctrl.dram_ctrl_socket.bind(dram_ctrl.bram_ctrl_socket);  
	// Connecting BRAM_CTRL X with DRAM_CTRL X 
	bram_ctrl.dram_ctrlX_socket.bind(dram_ctrl.bram_ctrlX_socket);  
	// Connecting BRAM_CTRL Y with DRAM_CTRL Y 
    bram_ctrl.dram_ctrlY_socket.bind(dram_ctrl.bram_ctrlY_socket);  

    // Connecting BRAM_CTRL with BRAM
    bram_ctrl.bram_socket.bind(bram.bram_ctrl_socket); 
	// Connecting BRAM_CTRL with BRAMX
    bram_ctrl.bramX_socket.bind(bramX.bram_ctrl_socket); 
	// Connecting BRAM_CTRL with BRAMY
    bram_ctrl.bramY_socket.bind(bramY.bram_ctrl_socket); 
    
    // Connecting HW with BRAM_CTRL
	hard.bram_ctrl_socket.bind(bram_ctrl.filter_socket);
	// Connecting HW with DRAM direct connection
	hard.dram_ctrl_socket.bind(dram_ctrl.hw_socket);
	// Connecting HW with BRAMX
	hard.bramX_socket.bind(bramX.hard_socket);
	// Connecting HW with BRAMY
	hard.bramY_socket.bind(bramY.hard_socket);

	soft.interconnect_socket.bind(interconnect.soft_socket);
	SC_REPORT_INFO("Virtual Platform", "Constructed.");
}

Vp::~Vp()
{
	SC_REPORT_INFO("Virtual Platform", "Destroyed.");
}
