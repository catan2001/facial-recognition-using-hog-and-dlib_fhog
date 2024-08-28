#ifndef BRAM_OUT_HPP
#define BRAM_OUT_HPP

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <vector>
#include "def.hpp"
#include "utils.hpp"
#include <iostream>

using namespace std;

class BramOut : public sc_core::sc_module
{ 
public:
	BramOut(sc_core::sc_module_name name);
	~BramOut();
	tlm_utils::simple_target_socket<BramOut> bram_ctrl_socket;
	tlm_utils::simple_target_socket<BramOut> hard_socket;
protected:
	void b_transport(pl_t&, sc_core::sc_time&);
	std::vector<output_t> mem; //num_t
	u6_t write_transaction_cnt;
};

#endif // BRAM_OUT_HPP
