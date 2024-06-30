#ifndef HW_HPP_
#define HW_HPP_

#include <systemc>
#include <math.h>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include "utils.hpp"

class HW : public sc_core::sc_module
{
public:
	//SC_HAS_PROCESS(HW);
    HW(sc_core::sc_module_name name);
	~HW();
	tlm_utils::simple_initiator_socket<HW> bram_ctrl_socket;
	//void filter_image_t(void);
protected:
	pl_t pl;
	sc_core::sc_time offset;
	int start, ready;
	void b_transport(pl_t& pl, sc_core::sc_time& offset);
	void filter_image_t(void);
	//void debug_read();
	num_t2 read_bram(int addr);
	//void write_bram(int addr, num_t val, char c);
};

#endif // HW_HPP_
