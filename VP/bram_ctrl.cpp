#include "bram_ctrl.hpp"

BramCtrl::BramCtrl(sc_core::sc_module_name name) : 
    sc_module(name), 
    offset(sc_core::SC_ZERO_TIME),
    width(0),
    height(0),
    start(0),
    ready(1)
{

    interconnect_socket.register_b_transport(this, &BramCtrl::b_transport);
    SC_REPORT_INFO("BRAM Controller", "Constructed.");
}

BramCtrl::~BramCtrl(){
     SC_REPORT_INFO("BRAM Controller", "Destroyed.");
}

void BramCtrl::b_transport(pl_t &pl, sc_core::sc_time &offset)
{
  tlm::tlm_command cmd = pl.get_command();
  sc_dt::uint64 addr = pl.get_address();
  unsigned int len = pl.get_data_length();
  unsigned char *buf = pl.get_data_ptr();

  switch(cmd)
    {
    case tlm::TLM_WRITE_COMMAND:

      switch(addr)
        {
        case ADDR_WIDTH:
          width = to_int(buf)+2;
          break;
        case ADDR_HEIGHT:
          height = to_int(buf)+2;
          break;
        case ADDR_CMD:
          start = to_int(buf);

          //TRANSFER FROM DRAM TO BRAM UNTIL BRAM IS FULL:

          for(int i=0; i<width; ++i){
            for(int j=0; j<height; ++j){
              dram_to_bram(i*(cols+2)+j, val);
            }
          }

          //WRITE INTO BRAM:


          //WRITE INTO REG36:


          //CALL FILTER:

          break;
        default:
          pl.set_response_status( tlm::TLM_ADDRESS_ERROR_RESPONSE);
        }

      if (len != 2) pl.set_response_status( tlm::TLM_BURST_ERROR_RESPONSE);
      break;

    case tlm::TLM_READ_COMMAND:
      switch(addr)
        {
        case ADDR_STATUS:
          to_uchar(buf,ready);
          break;
        default:
          pl.set_response_status( tlm::TLM_ADDRESS_ERROR_RESPONSE );
        }
      if (len != 2) pl.set_response_status( tlm::TLM_BURST_ERROR_RESPONSE );
      break;
    default:
      pl.set_response_status( tlm::TLM_COMMAND_ERROR_RESPONSE );
    }

  offset += sc_core::sc_time(10, sc_core::SC_NS);  



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

BramCtrl:: dram_to_bram(sc_dt::uint64 addr){

  pl_t pl;
  unsigned char buf[LEN_IN_BYTES];
  pl.set_address((addr * LEN_IN_BYTES) | DRAM_BASE_ADDR);
  pl.set_data_length(LEN_IN_BYTES);
  pl.set_data_ptr(buf);
  pl.set_command(tlm::TLM_READ_COMMAND);
  pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
  interconnect_socket->b_transport(pl, offset);

  val = to_fixed(buf);


}
