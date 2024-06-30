#ifndef BRAM_CTRL_HPP_
#define BRAM_CTRL_HPP_

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <tlm_utils/simple_initiator_socket.h>
#include "def.hpp"

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
  int width, height, start, ready;
  pl_t pl_dram;
};

#endif // BRAM_CTRL_HPP_
