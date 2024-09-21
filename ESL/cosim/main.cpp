#define SC_MAIN

#include <systemc>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

#include "def.hpp"
#include "sw.hpp"
#include "interconnect.hpp"
#include "dram.hpp"
#include "dram_ctrl.hpp"
#include "ip_core.hpp"

using namespace sc_core;
using namespace tlm;
using namespace std;

int sc_main(int argc, char* argv[])
{

	SW sw("sw");
	Interconnect ic("ic");
	DRAM dram("dram");
	DramCtrl dramctrl("dram_ctrl");
	Ip_Core ip_core("ip_core");

	sw.interconnect_socket.bind(ic.soft_socket);
	ic.hw_socket.bind(ip_core.interconnect_socket);
	ic.dram_ctrl_socket.bind(dramctrl.interconnect_socket);
	dramctrl.ip_core_x_socket.bind(ip_core.dram_ctrl_x_socket);
	dramctrl.ip_core_y_socket.bind(ip_core.dram_ctrl_y_socket);
	dramctrl.dram_in1_socket.bind(dram.dram_ctrl_in1_socket);
	dramctrl.dram_in2_socket.bind(dram.dram_ctrl_in2_socket);
	dramctrl.dram_out1_socket.bind(dram.dram_ctrl_out1_socket);
	dramctrl.dram_out2_socket.bind(dram.dram_ctrl_out2_socket);
	dramctrl.ip_core_data1_socket.bind(ip_core.dram_ctrl_in1_socket);
	dramctrl.ip_core_data2_socket.bind(ip_core.dram_ctrl_in2_socket);

	
	sc_start();

	return 0;
}

