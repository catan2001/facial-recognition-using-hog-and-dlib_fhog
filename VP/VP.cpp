#include "VP.hpp"

Vp::Vp(sc_core::sc_module_name name)
	: sc_module(name),
	interconnect("Interconnect"),
	dram("Dram"),
	dram_ctrl("DramCtrl"),
    bram("Bram"),
    bram_ctrl("BramCtrl"),
	soft("Soft"),
	hard("Hard")
{
    // Connecting Interconnect with DRAM_CTRL and HW
	interconnect.dram_ctrl_socket.bind(dram_ctrl.interconnect_socket);
	interconnect.hw_socket.bind(hard.interconnect_socket);
	//interconnect.mem_ic_socket.bind(mem_ic.interconnect_socket);

    // Connecting DRAM_CTRL with DRAM
    dram_ctrl.dram_ctrl_socket_s1.bind(dram.dram_socket_s1);
    dram_ctrl.dram_ctrl_socket_s2.bind(dram.dram_socket_s2);

    // Connecting BRAM_CTRL with DRAM_CTRL
    bram_ctrl.dram_ctrl_socket_s1(dram_ctrl.dram_ctrl_socket_s1);   
    bram_ctrl.dram_ctrl_socket_s2(dram_ctrl.dram_ctrl_socket_s2);
    // Connecting BRAM_CTRL with BRAM
    bram_ctrl.bram_socket_b1(bram.bram_ctrl_socket_s1);   
    bram_ctrl.bram_socket_b2(bram.bram_ctrl_socket_s2); 
    bram_ctrl.bram_socket_b3(bram.bram_ctrl_socket_s3); 
    
    // Connecting HW with BRAM_CTRL
	hard.bram_ctrl_socket.bind(bram_ctrl.filter_socket_s1);

	//mem_ic.dram_socket0.bind(dram_ctrl.mem_ic_socket0);
	//mem_ic.dram_socket1.bind(dram_ctrl.mem_ic_socket1);
   
	soft.interconnect_socket.bind(interconnect.soft_socket);
	SC_REPORT_INFO("Virtual Platform", "Constructed.");
}

Vp::~Vp()
{
	SC_REPORT_INFO("Virtual Platform", "Destroyed.");
}
