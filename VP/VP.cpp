#include "VP.hpp"

Vp::Vp(sc_core::sc_module_name name)
	: sc_module(name),
	interconnect("Interconnect"),
	dram("Dram"),
	dram_ctrl("DramCtrl")
	soft("Soft"),
	hard("Hard")
{
	interconnect.dram_ctrl_socket.bind(dram_ctrl.interconnect_socket);
	interconnect.hw_socket.bind(hard.interconnect_socket);
	interconnect.mem_ic_socket.bind(mem_ic.interconnect_socket);

	hard.dram_socket0.bind(dram_ctrl.hw_socket0);
	hard.dram_socket1.bind(dram_ctrl.hw_socket1);
	hard.dram_socket2.bind(dram_ctrl.hw_socket2);

	mem_ic.dram_socket0.bind(dram_ctrl.mem_ic_socket0);
	mem_ic.dram_socket1.bind(dram_ctrl.mem_ic_socket1);

	dram_ctrl.dram_socket0.bind(dram.dram_ctrl_socket0);
	dram_ctrl.dram_socket1.bind(dram.dram_ctrl_socket1);

	soft.interconnect_socket.bind(interconnect.soft_socket);
	SC_REPORT_INFO("Virtual Platform", "Constructed.");
}

Vp::~Vp()
{
	SC_REPORT_INFO("Virtual Platform", "Destroyed.");
}
