#ifndef HW_HPP_
#define HW_HPP_

#include <systemc>
#include <math.h>
#include <tlm>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include "utils.hpp"

class HW : public sc_core::sc_module
{
public:
	//SC_HAS_PROCESS(HW);
    HW(sc_core::sc_module_name name);
	~HW();
	tlm_utils::simple_target_socket<HW> bram_ctrl_socket;
	
protected:
	pl_t pl;
	sc_core::sc_time offset;
	int start, ready;
	void b_transport(pl_t& pl, sc_core::sc_time& offset);
	void filter_image_t(void);
	num_t2 read_bram(int addr);

	std::vector<num_t2> mem33, mem18;
	std::vector<num_t2> kernel, temp;
	
};

#endif // HW_HPP_
