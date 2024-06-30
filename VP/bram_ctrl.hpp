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
  tlm_utils::simple_target_socket<BramCtrl> filter_socket_s1;// there's probably no need for 3 separate sockets.
  //tlm_utils::simple_target_socket<BramCtrl> filter_socket_s2;// there's probably no need for 3 separate sockets.
  //tlm_utils::simple_target_socket<BramCtrl> filter_socket_s2;// there's probably no need for 3 separate sockets.

  //tlm_utils::simple_target_socket<BramCtrl> interconnect; // this makes no sense, if BRAM_CTRL is target how to initiate HW,
                                                            // HW has to be target from interconnect so it can call BRAM_CTRL
                                                            // othrewise BRAM_CTRL has no way to call HW unless there's another
                                                            // initiator socket directed to HW. If we add another initiator then
                                                            // at some point HW will call BRAM_CTRL this could go in loop...
  // DRAM SOCKETS:
  tlm_utils::simple_initiator_socket<BramCtrl> dram_ctrl_socket_s1;
  //tlm_utils::simple_initiator_socket<BramCtrl> dram_ctrl_socket_s2; // do we need both sockets?

  // BRAM SOCKETS:
  tlm_utils::simple_initiator_socket<BramCtrl> bram_socket_b1; // BRAM Block 1 // do we need all sockets?
  //tlm_utils::simple_initiator_socket<BramCtrl> bram_socket_b2; // BRAM Block 2
  //tlm_utils::simple_initiator_socket<BramCtrl> bram_socket_b3; // BRAM Block 3

protected:
  void b_transport (pl_t &, sc_core::sc_time &); // socket1 b_transport
  //void b_transport (pl_t &, sc_core::sc_time &); // socket1 b_transport
  //void b_transport2 (pl_t &, sc_core::sc_time &); // socket2 b_transport

  pl_t pl_bram;
};

#endif // BRAM_CTRL_HPP_
