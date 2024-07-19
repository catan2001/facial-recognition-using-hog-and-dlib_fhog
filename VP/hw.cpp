#include "hw.hpp"
//SC_HAS_PROCESS(HW);

HW::HW(sc_core::sc_module_name name)
    : sc_module(name)
{
    SC_REPORT_INFO("Hard", "Constructed.");
    //SC_THREAD(filter_image_t);
    bram_ctrl_socket.register_b_transport(this, &HW::b_transport); // changed
    mem33.reserve(REG33);
    mem18.reserve(NUM_PARALLEL_POINTS*2);
    kernel.reserve(KERNEL_SIZE);
    temp.reserve(6);
    
    kernel[0] = -1;
    kernel[1] = -2;
    kernel[2] = 2;

}

HW::~HW()
{
    SC_REPORT_INFO("Hard", "Destroyed.");
}

void HW::filter_image_t(void){
  for (int i=0; i<NUM_PARALLEL_POINTS; ++i){ 

    //FILTER_X
    //tier 1:
    temp[0] = mem33[1+i*3]*2 + mem33[0+i*3];
    temp[1] = mem33[7+i*3]*(-2) + mem33[2+i*3];
    temp[2] = mem33[6+i*3]*(-1) - mem33[8+i*3];
    //tier 2:
    mem18[i] = temp[0]+temp[1]+temp[2];

    //FILTER_Y
    //tier 1:
    temp[3] = mem33[3+i*3]*2 + mem33[0+i*3];
    temp[4] = mem33[5+i*3]*(-2) + mem33[6+i*3];
    temp[5] = mem33[2+i*3]*(-1) - mem33[8+i*3];
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
        case ADDR_INPUT_REG: //write pixels into the registers
          for (int i = 0; i < len/LEN_IN_BYTES; ++i){
            mem33[addr++] = concat(buf[i*LEN_IN_BYTES], buf[i*LEN_IN_BYTES+1]); // TODO: change to_fixed
            //cout << concat(buf[i*LEN_IN_BYTES], buf[i*LEN_IN_BYTES+1]) << " ";    
          }
          //cout << endl;
          pl.set_response_status(tlm::TLM_OK_RESPONSE); 
          break;
        
        case ADDR_CMD:
          filter_image_t();
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
          to_uchar(buf,ready);
          break;
        case ADDR_OUTPUT_REG:
          //TODO: finish reading from output registers
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

/*
num_t2 HW::read_bram(int addr){
    pl_t pl;
    unsigned char buf[LEN_IN_BYTES];
    pl.set_address(addr * LEN_IN_BYTES); 
    pl.set_data_length(LEN_IN_BYTES);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_READ_COMMAND);
    pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    sc_core::sc_time offset = sc_core::SC_ZERO_TIME;
    bram_ctrl_socket->b_transport(pl, offset);
    return to_fixed(buf); 
} */
