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
  tlm_utils::simple_initiator_socket<BramCtrl> bram_socket0; 
  tlm_utils::simple_initiator_socket<BramCtrl> bram_socket1;
  tlm_utils::simple_initiator_socket<BramCtrl> bram_socket2; 

  //SW SOCKETS:
  tlm_utils::simple_target_socket<BramCtrl> interconnect_socket;

protected:
  void b_transport (pl_t &, sc_core::sc_time &);
  void dram_to_bram(bit1_t, sc_dt::uint64, sc_dt::uint64, sc_dt::uint64, sc_core::sc_time &);
  void bram_to_reg(bit6_t, const_t, const_t, sc_dt::uint64, sc_core::sc_time &);
  void write_filter(sc_dt::uint64 , const_t);
  void control_logic(void);
  void initialisation(bit1_t);

  sc_core::sc_time offset;
  const_t width, height;
  const_t skipped_rows;
  const_t counter_init;
  const_t dram_row_ptr;
  const_t cycle_number;
  bit6_t bram_block_ptr;
  bit1_t start, ready;
  pl_t pl_bram;
};

#endif // BRAM_CTRL_HPP_
