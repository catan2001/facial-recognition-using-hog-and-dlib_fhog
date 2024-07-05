#ifndef VP_HPP_
#define VP_HPP_

#include <systemc>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include "def.hpp"
#include "interconnect.hpp"
#include "bram.hpp"
#include "bram_ctrl.hpp"
#include "sw.hpp"
#include "hw.hpp"
#include "dram.hpp"
#include "dram_ctrl.hpp"

class Vp : public sc_core::sc_module
{
public:
	Vp(sc_core::sc_module_name name);
	~Vp();

protected:

	SW soft;
	DramCtrl dram_ctrl;
    Bram bram;
    BramCtrl bram_ctrl;
	HW hard;
	Interconnect interconnect;
    DRAM dram;
};

#endif // VP_HPP_
