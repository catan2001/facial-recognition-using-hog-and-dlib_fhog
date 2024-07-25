#include "hw.hpp"
 
HW::HW(sc_core::sc_module_name name)
    : sc_module(name)
{
    SC_REPORT_INFO("Hard", "Constructed.");

    bram_ctrl_socket.register_b_transport(this, &HW::b_transport); // changed
    
    mem33.reserve(REG33);
    mem33_ptr = 0;

    mem18.reserve(NUM_PARALLEL_POINTS*2);
    temp.reserve(6);

    pixel_batch_cnt=0;
    row_batch_cnt=0;
    
    width = 0;
    height = 0;
}
 
HW::~HW()
{
    SC_REPORT_INFO("Hard", "Destroyed.");
}
 
void HW::filter_image_t(void){

  for (int i=0; i<NUM_PARALLEL_POINTS; ++i){ 

    //FILTER_X
    //tier 1:
    temp[0] = mem33[3+i*3]*2 + mem33[0+i*3];
    temp[1] = mem33[5+i*3]*(-2) + mem33[6+i*3];
    temp[2] = mem33[2+i*3]*(-1) - mem33[8+i*3];
    //tier 2:
    mem18[i] = temp[0]+temp[1]+temp[2];

    //FILTER_Y
    //tier 1:
    temp[3] = mem33[1+i*3]*2 + mem33[0+i*3];
    temp[4] = mem33[7+i*3]*(-2) + mem33[2+i*3];
    temp[5] = mem33[6+i*3]*(-1) - mem33[8+i*3];
    //tier 2:
    mem18[i+NUM_PARALLEL_POINTS] = temp[3]+temp[4]+temp[5];
  }  
}
 
void HW::b_transport(pl_t& pl, sc_core::sc_time& offset)
{
    sc_dt::uint64 addr = pl.get_address(); 
    tlm::tlm_command cmd = pl.get_command(); 
    unsigned char *buf = pl.get_data_ptr(); 
    unsigned int len = pl.get_data_length();
 
    num_t pom;
 
    switch(cmd)
    {
    case tlm::TLM_WRITE_COMMAND:
      switch(addr)
        {
        case ADDR_HEIGHT: // set height register
            height = to_int(buf);
            pixel_batch_cnt = 0;
            row_batch_cnt = 0;
            pl.set_response_status(tlm::TLM_OK_RESPONSE);
            break;
        case ADDR_WIDTH: // set width register
            width = to_int(buf);
            pl.set_response_status(tlm::TLM_OK_RESPONSE);
            break;
        case ADDR_INPUT_REG: //write pixels into the registers

          mem33_ptr = (mem33_ptr == 33 ? (bit6_t)0 : mem33_ptr);
          mem33[mem33_ptr++] = to_fixed(buf);

          pl.set_response_status(tlm::TLM_OK_RESPONSE); 
          break;
 
        case ADDR_CMD:

        //take REG33 pixels and filter them into REG18:
          filter_image_t();

        //write REG18 pixels to DRAM:
          for(int i=0; i<2*NUM_PARALLEL_POINTS; ++i){
            if(i<9){
                reg_to_dram(i, (height)*(width) + row_batch_cnt*NUM_PARALLEL_POINTS*2*(width-2) + i*2*(width-2) + pixel_batch_cnt, offset);

            }else{
              reg_to_dram(i, (height)*(width) + row_batch_cnt*NUM_PARALLEL_POINTS*2*(width-2) + (2*(i-9)+1)*(width-2)  + pixel_batch_cnt, offset);
            }
          }

          pixel_batch_cnt++;
          if(pixel_batch_cnt>=(width-2)) {pixel_batch_cnt=0; row_batch_cnt++;}

          pl.set_response_status(tlm::TLM_OK_RESPONSE); 
          break;
 
        default:
          pl.set_response_status( tlm::TLM_ADDRESS_ERROR_RESPONSE );
        }
      if (len != LEN_IN_BYTES) pl.set_response_status( tlm::TLM_BURST_ERROR_RESPONSE );
      break;
 
    case tlm::TLM_READ_COMMAND:
      switch(addr)
        {
        case ADDR_STATUS:
          int_to_uchar(buf,ready);
          break;
        default:
          pl.set_response_status( tlm::TLM_ADDRESS_ERROR_RESPONSE );
        }
      if (len != LEN_IN_BYTES) pl.set_response_status( tlm::TLM_BURST_ERROR_RESPONSE );
      break;
    default:
      pl.set_response_status( tlm::TLM_COMMAND_ERROR_RESPONSE );
    }
 
    offset += sc_core::sc_time(10, sc_core::SC_NS);
}


void HW:: reg_to_dram(sc_dt::uint64 i, sc_dt::uint64 dram_addr, sc_core::sc_time &offset){
  //WRITE TO DRAM:
  pl_t pl_dram;
  unsigned char buf_dram[LEN_IN_BYTES];

  to_uchar(buf_dram, mem18[i]);
  pl_dram.set_address(dram_addr);
  pl_dram.set_data_length(LEN_IN_BYTES);
  pl_dram.set_data_ptr(buf_dram);
  pl_dram.set_command(tlm::TLM_WRITE_COMMAND);
  pl_dram.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
  dram_ctrl_socket -> b_transport(pl_dram, offset);
}
 
