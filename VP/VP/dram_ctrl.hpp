#ifndef DRAM_CTRL_HPP_
#define DRAM_CTRL_HPP_

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <tlm_utils/simple_initiator_socket.h>
#include "def.hpp"
#include "utils.hpp"

class DramCtrl: public sc_core::sc_module
{
public:
  DramCtrl(sc_core::sc_module_name name);
  ~DramCtrl();
  tlm_utils::simple_target_socket<DramCtrl> interconnect_socket;
  tlm_utils::simple_target_socket<DramCtrl> bram_ctrl_socket;
  tlm_utils::simple_initiator_socket<DramCtrl> dram_socket;
  tlm_utils::simple_target_socket<DramCtrl> hw_socket;

protected:
  void b_transport (pl_t &, sc_core::sc_time &);

  pl_t pl_dram;
};

#endif // DRAM_CTRL_HPP_
