#include "bram_ctrl.hpp"

BramCtrl::BramCtrl(sc_core::sc_module_name name) : sc_module(name) {
    filter_socket_s1.register_b_transport(this, &BramCtrl::b_transport);
    SC_REPORT_INFO("BRAM Controller", "Constructed.");
}

BramCtrl::~BramCtrl(){
     SC_REPORT_INFO("BRAM Controller", "Destroyed.");
}

// b_transport for communication between BRAM_CTRL and BRAM
void BramCtrl::b_transport(pl_t &pl, sc_core::sc_time &offset)
{
  tlm::tlm_command cmd = pl.get_command();
  sc_dt::uint64 addr = pl.get_address();
  unsigned int len = pl.get_data_length();
  unsigned char *buf = pl.get_data_ptr();
    
  pl_bram.set_command(cmd);
  pl_bram.set_address(addr);
  pl_bram.set_data_length(len);
  pl_bram.set_data_ptr(buf);
  pl_bram.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

  // IF COMMAND FOR  READ DO THIS:
  bram_socket_b1->b_transport(pl_bram, offset); // TODO: change naming scheme, it's weird myb?
  //bram_socket_b2->b_transport(pl_bram, offset); // TODO: do we need all 3???
  //bram_socket_b3->b_transport(pl_bram, offset);   

  // IF BRAM IS EMPTY, LOAD FROM DRAM:
  dram_ctrl_socket_s1->b_transport(pl_bram,offset);

  if (pl_bram.is_response_error()) SC_REPORT_ERROR("Bram_Ctrl",pl_bram.get_response_string().c_str());
}

/*
// b_transport for communication between BRAM_CTRL and DRAM_CTRL
void BramCtrl::b_transport(pl_t &pl, sc_core::sc_time &offset)
{
  tlm::tlm_command cmd = pl.get_command();
  sc_dt::uint64 addr = pl.get_address();
  unsigned int len = pl.get_data_length();
  unsigned char *buf = pl.get_data_ptr();
    
  pl_bram.set_command(cmd);
  pl_bram.set_address(addr);
  pl_bram.set_data_length(len);
  pl_bram.set_data_ptr(buf);
  pl_bram.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

  dram_ctrl_socket_s1->b_transport(pl_bram, offset); // TODO: change naming scheme, it's weird myb?
  if (pl_bram.is_response_error()) SC_REPORT_ERROR("Bram_Ctrl",pl_bram.get_response_string().c_str());
}

//maybe we don't need this one
void BramCtrl::b_transport2(pl_t &pl, sc_core::sc_time &offset)
{
  tlm::tlm_command cmd = pl.get_command();
  sc_dt::uint64 addr = pl.get_address();
  unsigned int len = pl.get_data_length();
  unsigned char *buf = pl.get_data_ptr();
    
  pl_bram.set_command(cmd);
  pl_bram.set_address(addr);
  pl_bram.set_data_length(len);
  pl_bram.set_data_ptr(buf);
  pl_bram.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

  dram_ctrl_socket_s2->b_transport(pl_bram, offset); // TODO: change naming scheme, it's weird myb?
  if (pl_bram.is_response_error()) SC_REPORT_ERROR("Bram_Ctrl",pl_bram.get_response_string().c_str());
}

*/
