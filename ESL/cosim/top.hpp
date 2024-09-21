#ifndef _TOP_HPP_
#define _TOP_HPP_

#include <systemc>

class top : public sc_core::sc_foreign_module
{
public:
	top(sc_core::sc_module_name name) :
		sc_core::sc_foreign_module(name),
		clk("clk"),
		reset("reset"),
		start("start"),
		width("width"),
		height("height"),
		width_2("width_2"),
		width_4("width_4"),
		bram_height("bram_height"),
		effective_row_limit("effective_row_limit"),
		rows_num("rows_num"),
		cycle_num_limit("cycle_num_limit"),
		cycle_num_out("cycle_num_out"),
		axi_hp0_ready_out("axi_hp0_ready_out"),
		axi_hp0_valid_out("axi_hp0_valid_out"),
		axi_hp0_strb_out("axi_hp0_strb_out"),
		axi_hp0_last_out("axi_hp0_last_out"),
		axi_hp0_last_in("axi_hp0_last_in"),
		axi_hp0_valid_in("axi_hp0_valid_in"),
		axi_hp0_strb_in("axi_hp0_strb_in"),
		axi_hp0_ready_in("axi_hp0_ready_in"),
		axi_hp1_ready_out("axi_hp1_ready_out"),
		axi_hp1_valid_out("axi_hp1_valid_out"),
		axi_hp1_strb_out("axi_hp1_strb_out"),
		axi_hp1_last_out("axi_hp1_last_out"),
		axi_hp1_last_in("axi_hp1_last_in"),
		axi_hp1_valid_in("axi_hp1_valid_in"),
		axi_hp1_strb_in("axi_hp1_strb_in"),
		axi_hp1_ready_in("axi_hp1_ready_in"),
		data_in1("data_in1"),
		data_in2("data_in2"),
		data_out1("data_out1"),
		data_out2("data_out2"),
		ready("ready")
	{

	}

	sc_core::sc_in< bool > clk;
	sc_core::sc_in< sc_dt::sc_logic > reset;
	sc_core::sc_in< sc_dt::sc_logic > start;

	sc_core::sc_in< sc_dt::sc_lv<10> > width;
	sc_core::sc_in< sc_dt::sc_lv<11> > height;
	sc_core::sc_in< sc_dt::sc_lv<9> > width_2;
	sc_core::sc_in< sc_dt::sc_lv<8> > width_4;
	sc_core::sc_in< sc_dt::sc_lv<5> > bram_height;
	sc_core::sc_in< sc_dt::sc_lv<12> > effective_row_limit;
	sc_core::sc_in< sc_dt::sc_lv<10> > rows_num;
	sc_core::sc_in< sc_dt::sc_lv<6> > cycle_num_limit;
	sc_core::sc_in< sc_dt::sc_lv<6> > cycle_num_out;

	sc_core::sc_in< sc_dt::sc_logic > axi_hp0_ready_out;
	sc_core::sc_out< sc_dt::sc_logic > axi_hp0_valid_out;
	sc_core::sc_out< sc_dt::sc_lv<8> > axi_hp0_strb_out;
	sc_core::sc_out< sc_dt::sc_logic > axi_hp0_last_out;
	sc_core::sc_in< sc_dt::sc_logic > axi_hp0_last_in;
	sc_core::sc_in< sc_dt::sc_logic > axi_hp0_valid_in;
	sc_core::sc_in< sc_dt::sc_lv<8> > axi_hp0_strb_in;
	sc_core::sc_out< sc_dt::sc_logic > axi_hp0_ready_in;

	sc_core::sc_in< sc_dt::sc_logic > axi_hp1_ready_out;
	sc_core::sc_out< sc_dt::sc_logic > axi_hp1_valid_out;
	sc_core::sc_out< sc_dt::sc_lv<8> > axi_hp1_strb_out;
	sc_core::sc_out< sc_dt::sc_logic > axi_hp1_last_out;
	sc_core::sc_in< sc_dt::sc_logic > axi_hp1_last_in;
	sc_core::sc_in< sc_dt::sc_logic > axi_hp1_valid_in;
	sc_core::sc_in< sc_dt::sc_lv<8> > axi_hp1_strb_in;
	sc_core::sc_out< sc_dt::sc_logic > axi_hp1_ready_in;

	sc_core::sc_in< sc_dt::sc_lv<64> > data_in1;
	sc_core::sc_in< sc_dt::sc_lv<64> > data_in2;
	sc_core::sc_out< sc_dt::sc_lv<64> > data_out1;
	sc_core::sc_out< sc_dt::sc_lv<64> > data_out2;

	sc_core::sc_out< sc_dt::sc_logic > ready;

	const char* hdl_name() const { return "top"; }
};

#endif

