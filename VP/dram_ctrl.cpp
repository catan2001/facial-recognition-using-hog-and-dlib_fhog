#include "dram_ctrl.hpp"

DramCtrl::DramCtrl(sc_core::sc_module_name name) : sc_module(name) {
    
}

/*
void BramCtrl::b_transport(pl_t &pl, sc_core::sc_time &offset)
{
  tlm::tlm_command cmd = pl.get_command();
  sc_dt::uint64 addr = pl.get_address();
  unsigned int len = pl.get_data_length();
  unsigned char *buf = pl.get_data_ptr();

  pl_re.set_command(cmd);
  pl_re.set_address(addr);
  pl_re.set_data_length(4);
  pl_re.set_data_ptr(buf);
  pl_re.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

  pl_im.set_command(cmd);
  pl_im.set_address(addr);
  pl_im.set_data_length(4);
  pl_im.set_data_ptr(buf+4);
  pl_im.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

  bram_re_socket->b_transport(pl_re,offset);
  if (pl_re.is_response_error()) SC_REPORT_ERROR("Bram_RE",pl_re.get_response_string().c_str());

  bram_im_socket->b_transport(pl_im,offset);
  if (pl_re.is_response_error()) SC_REPORT_ERROR("Bram_IM",pl_re.get_response_string().c_str()); */
