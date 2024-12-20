#ifndef BRAM_HPP
#define BRAM_HPP

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <vector>
#include "def.hpp"
#include "utils.hpp"
#include <iostream>

using namespace std;

class Bram : public sc_core::sc_module
{ 
public:
	Bram(sc_core::sc_module_name name);
	~Bram();
	tlm_utils::simple_target_socket<Bram> bram_ctrl_socket;
protected:
	void b_transport(pl_t&, sc_core::sc_time&);
	std::vector<output_t> mem; //num_t
	u6_t write_transaction_cnt;
};

#endif // BRAM_HPP
