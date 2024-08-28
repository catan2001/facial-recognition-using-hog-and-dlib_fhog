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
    HW(sc_core::sc_module_name name);
	~HW();
	tlm_utils::simple_target_socket<HW> bram_ctrl_socket;
	tlm_utils::simple_initiator_socket<HW> dram_ctrl_socket;
	tlm_utils::simple_initiator_socket<HW> bramX_socket;
 	tlm_utils::simple_initiator_socket<HW> bramY_socket;

protected:
	pl_t pl;
	sc_core::sc_time offset;
	u1_t start, ready;
	void b_transport(pl_t& pl, sc_core::sc_time& offset);
	void filter_image_t(sc_core::sc_time& offset);
	void reg_to_dram(sc_dt::uint64 i, sc_dt::uint64 dram_addr, sc_core::sc_time &offset);
	void reg_to_bramY(sc_dt::uint64 i, sc_dt::uint64 bram_addr, sc_core::sc_time &offset);
	void reg_to_bramX(sc_dt::uint64 i, sc_dt::uint64 bram_addr, sc_core::sc_time &offset);
	std::vector<output_t> temp;
    std::vector<output_t> mem24, mem16;
	u6_t mem24_ptr;
	u16_t cycle_num = 0;
	u16_t pixel_batch_cnt = 0;
    u16_t row_batch_cnt = 0; // TODO: bugs for some reason
    u16_t width, height;  
};
 
#endif // HW_HPP_
