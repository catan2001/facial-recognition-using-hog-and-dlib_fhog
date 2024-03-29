#ifndef HW_HPP_
#define HW_HPP_

#include "systemc.h"
#include <math.h>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;

class HW : public sc_core::sc_module
{
public:
	// SC_HAS_PROCESS(Hard);
	HW(sc_core::sc_module_name name);
	~HW();
	//tlm_utils::simple_initiator_socket<HW> bram_re_socket;
	//tlm_utils::simple_initiator_socket<HW> bram_im_socket;
	//tlm_utils::simple_target_socket<HW> soft_socket;

protected:
	pl_t pl;
	sc_core::sc_time offset;
	void b_transport(pl_t& pl, sc_core::sc_time& offset);
	//void debug_read();
	//num_t read_bram(int addr, char c);
	//void write_bram(int addr, num_t val, char c);
};

#endif // HW_HPP_
