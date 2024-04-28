#include "VP.hpp"

Vp::Vp(sc_core::sc_module_name name)
	: sc_module(name),
	interconnect("Interconnect"),
	bram("Bram"),
	soft("Soft"),
	hard("Hard")
{
	interconnect.bram_socket.bind(bram.interconnect_socket);
	soft.interconnect_socket.bind(interconnect.soft_socket);
	interconnect.hw_socket.bind(hard.interconnect_socket);
	hard.bram_socket.bind(bram.hw_socket);
	soft.interconnect_socket.bind(interconnect.soft_socket);

	SC_REPORT_INFO("Virtual Platform", "Constructed.");
}

Vp::~Vp()
{
	SC_REPORT_INFO("Virtual Platform", "Destroyed.");
}
