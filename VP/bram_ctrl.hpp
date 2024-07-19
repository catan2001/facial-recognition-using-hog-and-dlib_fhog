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
  void dram_to_bram(int, sc_dt::uint64, sc_dt::uint64, sc_dt::uint64, sc_core::sc_time &); // i, j, k, sim_time
  void bram_to_reg(int, int, int, sc_dt::uint64, sc_core::sc_time &);
  void read_bram(sc_dt::uint64, sc_core::sc_time &offset);
  void initialisation(bool);

  sc_core::sc_time offset;
  int width, height, start, ready;
  int dram_row_ptr;
  int cycle_number = 0, bram_block_ptr = 0;
  int moduo_points; //the remainder of dividing width by NUM_PARALLEL_POINTS (=10)
  int pixel_cnt; //number of pixels in the picture
  pl_t pl_bram;
};

#endif // BRAM_CTRL_HPP_
