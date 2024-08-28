#ifndef BRAM_CTRL_HPP_
#define BRAM_CTRL_HPP_

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <tlm_utils/simple_initiator_socket.h>
#include "def.hpp"
#include "utils.hpp"

class BramCtrl: public sc_core::sc_module
{
public:
    BramCtrl(sc_core::sc_module_name name);
    ~BramCtrl();

    // FILTER SOCKETS:
    tlm_utils::simple_initiator_socket<BramCtrl> filter_socket;

    // DRAM SOCKETS:
    tlm_utils::simple_initiator_socket<BramCtrl> dram_ctrl_socket;
    tlm_utils::simple_initiator_socket<BramCtrl> dram_ctrlX_socket;
    tlm_utils::simple_initiator_socket<BramCtrl> dram_ctrlY_socket;


    // BRAM SOCKETS:
    tlm_utils::simple_initiator_socket<BramCtrl> bram_socket;
    tlm_utils::simple_initiator_socket<BramCtrl> bramX_socket;
    tlm_utils::simple_initiator_socket<BramCtrl> bramY_socket;

    //SW SOCKETS:
    tlm_utils::simple_target_socket<BramCtrl> interconnect_socket;

    protected:
    void b_transport (pl_t &, sc_core::sc_time &);
    void dram_to_bram(sc_dt::uint64, sc_dt::uint64, sc_dt::uint64, sc_core::sc_time &);
    void bram_to_dram(sc_dt::uint64, sc_dt::uint64, sc_dt::uint64, sc_core::sc_time &);
    void bram_to_reg(u16_t, u16_t, u16_t, sc_dt::uint64, sc_core::sc_time &);
    void write_filter(sc_dt::uint64, u16_t, sc_core::sc_time &);
    void control_logic(sc_core::sc_time &);

    void Dram2BramBridge(sc_core::sc_time &);
    void Bram2DramBridge(sc_core::sc_time &);

    sc_core::sc_time offset;
    u16_t width, height;
    u16_t dram_row_ptr;
    u16_t cycle_number;
    u16_t bram_block_ptr;
    u16_t counter_init;
    u16_t effective_row_limit;
    u16_t row_capacity_bram;

    u16_t width_2;
    u16_t width_4;
    u16_t bram_height;
    u16_t cycle_num_in;
    u16_t cycle_num_out;

    u16_t base_addr_input;
    u16_t base_addr_dx;
    u16_t base_addr_dy;

    u16_t dram_row_ptr_xy;

    u1_t start, ready, reset;
    //variable used only for delay, to model the final init delay for axi BRAM->DRAM 
    u1_t finished = 0;

    pl_t pl_bram;
};

#endif // BRAM_CTRL_HPP_
