#include "dram_ctrl.hpp"

DramCtrl::DramCtrl(sc_core::sc_module_name name) : sc_module(name) {
    interconnect_socket.register_b_transport(this, &DramCtrl::b_transport);  
    bram_ctrl_socket.register_b_transport(this, &DramCtrl::b_transport); 
    hw_socket.register_b_transport(this, &DramCtrl::b_transport); 
    SC_REPORT_INFO("DRAM Controller", "Constructed.");
}

DramCtrl::~DramCtrl(){
     SC_REPORT_INFO("DRAM Controller", "Destroyed.");
}

void DramCtrl::b_transport(pl_t &pl, sc_core::sc_time &offset)
{
  tlm::tlm_command cmd = pl.get_command();
  sc_dt::uint64 addr = pl.get_address();
  unsigned int len = pl.get_data_length();
  unsigned char *buf = pl.get_data_ptr();

  num_t2 temp = to_fixed(buf);

  //cout << "DRAM_CTRL_BUF: " << temp << endl;
    
  pl_dram.set_command(cmd);
  pl_dram.set_address(addr);
  pl_dram.set_data_length(len);
  pl_dram.set_data_ptr(buf);
  pl_dram.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

  dram_socket->b_transport(pl_dram, offset);
  if (pl_dram.is_response_error()) SC_REPORT_ERROR("Bram_RE",pl_dram.get_response_string().c_str());
}

