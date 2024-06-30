#ifndef INTERCONNECT_HPP_
#define INTERCONNECT_HPP_

#include <iostream>
#include <fstream>
#include <systemc>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include "def.hpp"

class Interconnect : public sc_core::sc_module
{
public:
	Interconnect(sc_core::sc_module_name name);
	~Interconnect();
	tlm_utils::simple_initiator_socket<Interconnect> hw_socket; // filterX/filterY
	tlm_utils::simple_initiator_socket<Interconnect> dram_ctrl_socket;
	//tlm_utils::simple_initiator_socket<Interconnect> mem_ic_socket; we decided to not represent memory interconnect
	tlm_utils::simple_target_socket<Interconnect> soft_socket;

protected:
	pl_t pl;
	sc_core::sc_time offset;
	void b_transport(pl_t& pl, sc_core::sc_time& offset);
};

#endif // INTERCONNECT_HPP_
