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

    //cout << "f_x["<<i<<"]: " << mem18[i] << " ";
 
    //FILTER_Y
    //tier 1:
    temp[3] = mem33[1+i*3]*2 + mem33[0+i*3];
    temp[4] = mem33[7+i*3]*(-2) + mem33[2+i*3];
    temp[5] = mem33[6+i*3]*(-1) - mem33[8+i*3];
    //tier 2:
    mem18[i+NUM_PARALLEL_POINTS] = temp[3]+temp[4]+temp[5];

    //cout << "f_y["<<i<<"]: " << mem18[i+NUM_PARALLEL_POINTS] << " ";
 
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

          mem33_ptr = (mem33_ptr == 33 ? 0 : mem33_ptr);
          mem33[mem33_ptr++] = to_fixed(buf);

          pl.set_response_status(tlm::TLM_OK_RESPONSE); 
          break;
 
        case ADDR_CMD:

        //take REG33 pixels and filter them into REG18:
          filter_image_t();

        //write REG18 pixels to DRAM:
          for(int i=0; i<2*NUM_PARALLEL_POINTS; ++i){

            if(i<9){
              //(ROWS+2)*(COLS+2) -> offset start of filtered img in DRAM by the biggest allowed size of the original picture
              //row_batch_cnt*NUM_PARALLEL_POINTS*2*COLS -> offset by rows when the first batch of 18 rows has been filtered
              //i*COLS*2 -> place the first 9 pixels in the even rows
              //pixel_batch_cnt -> starting point within row for each new batch of parallel points
              reg_to_dram(i, (ROWS+2)*(COLS+2) + row_batch_cnt*NUM_PARALLEL_POINTS*2*COLS + i*2*COLS + pixel_batch_cnt, offset);

            }else{
              //(2*(i-9)+1)*COLS -> place the first 9 pixels in the odd rows
              reg_to_dram(i, (ROWS+2)*(COLS+2) + row_batch_cnt*NUM_PARALLEL_POINTS*2*COLS + (2*(i-9)+1)*COLS  + pixel_batch_cnt, offset);

            }
      
          }

          pixel_batch_cnt++;
          if(pixel_batch_cnt>=ROWS) {pixel_batch_cnt=0; row_batch_cnt++;}

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
        //case ADDR_OUTPUT_REG:
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


void HW:: reg_to_dram(sc_dt::uint64 i, int dram_addr, sc_core::sc_time &offset){
 
  //WRITE TO DRAM:
  pl_t pl_dram;
  unsigned char buf_dram[LEN_IN_BYTES];

  to_uchar(buf_dram, mem18[i]);

  //cout << "mem: " << mem18[i] << endl;
  //cout << to_fixed(buf_dram) << endl;
 
  pl_dram.set_address(dram_addr);
  pl_dram.set_data_length(LEN_IN_BYTES);
  pl_dram.set_data_ptr(buf_dram);
  pl_dram.set_command(tlm::TLM_WRITE_COMMAND);
  pl_dram.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
  dram_ctrl_socket -> b_transport(pl_dram, offset);
  //if (pl_bram.is_response_error()) SC_REPORT_ERROR("Bram CTRL",pl_bram.get_response_string().c_str());
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
