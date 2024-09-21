#ifndef _IP_CORE_H_
#define _IP_CORE_H_

#ifndef SC_INCLUDE_FX
#define SC_INCLUDE_FX
#endif

#include <systemc>
#include <sysc/datatypes/fx/sc_fixed.h>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <tlm_utils/simple_initiator_socket.h>
#include <bitset>
#include "utils.hpp"
#include "def.hpp"
#include "top.hpp"

using namespace std;

class Ip_Core :
	public sc_core::sc_module
{
public:
	Ip_Core(sc_core::sc_module_name);
	~Ip_Core();
	
	tlm_utils::simple_target_socket<Ip_Core> interconnect_socket;
	tlm_utils::simple_target_socket<Ip_Core> dram_ctrl_in1_socket;
	tlm_utils::simple_target_socket<Ip_Core> dram_ctrl_in2_socket;
	tlm_utils::simple_target_socket<Ip_Core> dram_ctrl_x_socket;
	tlm_utils::simple_target_socket<Ip_Core> dram_ctrl_y_socket;

protected:
	pl_t pl;

	sc_core::sc_time offset;

	top core;

	sc_core::sc_clock clk;
	sc_core::sc_signal< sc_dt::sc_logic > reset;
	sc_core::sc_signal< sc_dt::sc_logic > start;
	sc_core::sc_signal< sc_dt::sc_lv<10> > width;
	sc_core::sc_signal< sc_dt::sc_lv<11> > height;
	sc_core::sc_signal< sc_dt::sc_lv<9> > width_2;
	sc_core::sc_signal< sc_dt::sc_lv<8> > width_4;
	sc_core::sc_signal< sc_dt::sc_lv<5> > bram_height;
	sc_core::sc_signal< sc_dt::sc_lv<12> > effective_row_limit;
	sc_core::sc_signal< sc_dt::sc_lv<10> > rows_num;
	sc_core::sc_signal< sc_dt::sc_lv<6> > cycle_num_out;
	sc_core::sc_signal< sc_dt::sc_lv<6> > cycle_num_limit;

	sc_core::sc_signal< sc_dt::sc_logic > axi_hp0_ready_out;
	sc_core::sc_signal< sc_dt::sc_logic > axi_hp0_valid_out;
	sc_core::sc_signal< sc_dt::sc_lv<8> > axi_hp0_strb_out;
	sc_core::sc_signal< sc_dt::sc_logic > axi_hp0_last_out;
	sc_core::sc_signal< sc_dt::sc_logic > axi_hp0_last_in;
	sc_core::sc_signal< sc_dt::sc_logic > axi_hp0_valid_in;
	sc_core::sc_signal< sc_dt::sc_lv<8> > axi_hp0_strb_in;
	sc_core::sc_signal< sc_dt::sc_logic > axi_hp0_ready_in;

	sc_core::sc_signal< sc_dt::sc_logic > axi_hp1_ready_out;
	sc_core::sc_signal< sc_dt::sc_logic > axi_hp1_valid_out;
	sc_core::sc_signal< sc_dt::sc_lv<8> > axi_hp1_strb_out;
	sc_core::sc_signal< sc_dt::sc_logic > axi_hp1_last_out;
	sc_core::sc_signal< sc_dt::sc_logic > axi_hp1_last_in;
	sc_core::sc_signal< sc_dt::sc_logic > axi_hp1_valid_in;
	sc_core::sc_signal< sc_dt::sc_lv<8> > axi_hp1_strb_in;
	sc_core::sc_signal< sc_dt::sc_logic > axi_hp1_ready_in;

	sc_core::sc_signal< sc_dt::sc_lv<64> > data_in1;
	sc_core::sc_signal< sc_dt::sc_lv<64> > data_in2;
	sc_core::sc_signal< sc_dt::sc_lv<64> > data_out1;
	sc_core::sc_signal< sc_dt::sc_lv<64> > data_out2;

	sc_core::sc_signal< sc_dt::sc_logic > ready;
 
	void b_transport(pl_t&, sc_core::sc_time&);
};

#ifndef SC_MAIN
SC_MODULE_EXPORT(Ip_Core)
#endif

#endif

