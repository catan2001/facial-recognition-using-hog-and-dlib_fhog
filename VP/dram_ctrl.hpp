#ifndef DRAM_CTRL_HPP_
#define DRAM_CTRL_HPP_

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <tlm_utils/simple_initiator_socket.h>

class DramCtrl: public sc_core::sc_module
{
public:
  DramCtrl(sc_core::sc_module_name name);
  ~DramCtrl();
  tlm_utils::simple_target_socket<DramCtrl> interconnect_socket_s1, bram_ctrl_socket_s2, bram_ctrl_socket_s3;
  tlm_utils::simple_initiator_socket<DramCtrl> dram_ctrl_socket_s1, dram_ctrl_socket_s2, dram_ctrl_socket_s3; // s1->PS, s2 and s3 -> PL

protected:
  void b_transport (pl_t &, sc_core::sc_time &);
  pl_t pl_r, pl_w;
};

#endif // DRAM_CTRL_HPP_
