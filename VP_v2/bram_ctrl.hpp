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

    // BRAM SOCKETS:
    tlm_utils::simple_initiator_socket<BramCtrl> bram_socket;

    //SW SOCKETS:
    tlm_utils::simple_target_socket<BramCtrl> interconnect_socket;

    protected:
    void b_transport (pl_t &, sc_core::sc_time &);
    void dram_to_bram(sc_dt::uint64, sc_dt::uint64, sc_dt::uint64, sc_core::sc_time &);
    void bram_to_reg(u16_t, u16_t, u16_t, sc_dt::uint64, sc_core::sc_time &);
    void write_filter(sc_dt::uint64, u16_t, sc_core::sc_time &);
    void control_logic(sc_core::sc_time &);

    void initialisation(sc_core::sc_time &);

    sc_core::sc_time offset;
    u16_t width, height;
    u16_t dram_row_ptr;
    u16_t cycle_number;
    u16_t bram_block_ptr;
    u16_t counter_init;
    u16_t accumulated_loss;

    u1_t start, ready, reset;

    pl_t pl_bram;
};

#endif // BRAM_CTRL_HPP_
