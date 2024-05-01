#ifndef VP_HPP_
#define VP_HPP_

#include <systemc>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include "def.hpp"
#include "interconnect.hpp"
#include "bram.hpp"
#include "sw.hpp"
#include "hw.hpp"

class Vp : public sc_core::sc_module
{
public:
	Vp(sc_core::sc_module_name name);
	~Vp();

protected:
	Interconnect interconnect;
	Bram bram;
	SW soft;
	HW hard;
};

#endif // VP_HPP_
