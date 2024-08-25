#include "hw.hpp"
 
HW::HW(sc_core::sc_module_name name)
    : sc_module(name)
{
    SC_REPORT_INFO("Hard", "Constructed.");

    bram_ctrl_socket.register_b_transport(this, &HW::b_transport); // changed
    
    mem24.reserve(REG24);
    mem24_ptr = 0;

    mem16.reserve(PTS_PER_COL*PTS_PER_ROW*2);
    temp.reserve(6);

    pixel_batch_cnt=0;
    row_batch_cnt=0;
    cycle_num = 0;
    
    width = 0;
    height = 0;
}
 
HW::~HW()
{
    SC_REPORT_INFO("Hard", "Destroyed.");
}
 
void HW::filter_image_t(sc_core::sc_time& offset){


  for (int i=0; i<PTS_PER_COL; ++i){ 
    for(int j=0; j<PTS_PER_ROW; ++j){
      //FILTER_X
      //tier 1:
      temp[0] = mem24[4+j + i*4]*2 + mem24[0+j + i*4];
      temp[1] = mem24[6+j + i*4]*(-2) + mem24[8+j + i*4];
      temp[2] = mem24[2+j + i*4]*(-1) - mem24[10+j + i*4];
      //tier 2:
      mem16[i*PTS_PER_ROW+j] = temp[0]+temp[1]+temp[2];

      //FILTER_Y
      //tier 1:
      temp[3] = mem24[1+j + i*4]*2 + mem24[0+j + i*4];
      temp[4] = mem24[9+j + i*4]*(-2) + mem24[2+j + i*4];
      temp[5] = mem24[8+j + i*4]*(-1) - mem24[10+j + i*4];
      //tier 2:
      mem16[i*PTS_PER_ROW+j+PTS_PER_COL*PTS_PER_ROW] = temp[3]+temp[4]+temp[5];
    }
  }  

    /*for(int k=0; k<16; ++k)
    cout << mem16[k] << " ";
  cout << endl;*/
    
  //cout << "TIME BEFORE IN FILTER: " << offset << endl;
  offset += sc_core::sc_time(DELAY, sc_core::SC_NS);
  //cout << "TIME AFTER IN FILTER: " << offset << endl;
}
 
void HW::b_transport(pl_t& pl, sc_core::sc_time& offset)
{
    sc_dt::uint64 addr = pl.get_address(); 
    tlm::tlm_command cmd = pl.get_command(); 
    unsigned char *buf = pl.get_data_ptr(); 
    unsigned int len = pl.get_data_length();
 
    switch(cmd)
    {
    case tlm::TLM_WRITE_COMMAND:
      switch(addr)
        {
        case ADDR_HEIGHT: // set height register
            height = to_int(buf);
            pixel_batch_cnt = 0;
            row_batch_cnt = 0;
            cycle_num = 0;
            pl.set_response_status(tlm::TLM_OK_RESPONSE);
            break;

        case ADDR_WIDTH: // set width register
            width = to_int(buf);
            pl.set_response_status(tlm::TLM_OK_RESPONSE);
            break;

        case ADDR_CONFIG:
          cycle_num = 0;
          break;

        case ADDR_INPUT_REG: //write pixels into the registers

          mem24_ptr = (mem24_ptr == REG24 ? (u6_t)0 : mem24_ptr);
          mem24[mem24_ptr++] = to_fixed(buf);
          pl.set_response_status(tlm::TLM_OK_RESPONSE); 
          break;
 
        case ADDR_START:

        //take REG24 pixels and filter them into REG16:
          filter_image_t(offset);
        
        //write REG16 pixels to DRAM:
          for(int i=0; i<PTS_PER_COL*PTS_PER_ROW; ++i){
            if(i<4){
              //reg_to_dram(2*i, (height)*(width) + row_batch_cnt*PTS_PER_COL*2*(width-2) + i*2*(width-2) + pixel_batch_cnt, offset);
              //reg_to_dram(2*i+1, (height)*(width) + row_batch_cnt*PTS_PER_COL*2*(width-2) + i*2*(width-2) + pixel_batch_cnt+1, offset);
              reg_to_bramX(2*i, row_batch_cnt*PTS_PER_COL*BRAM_WIDTH + cycle_num*(width-2) + i*BRAM_WIDTH + pixel_batch_cnt, offset);
              reg_to_bramX(2*i+1, row_batch_cnt*PTS_PER_COL*BRAM_WIDTH + cycle_num*(width-2) + i*BRAM_WIDTH + pixel_batch_cnt+1, offset);

            }else{
              //reg_to_dram(2*i, (height)*(width) + row_batch_cnt*PTS_PER_COL*2*(width-2) + (2*(i-PTS_PER_COL)+1)*(width-2)  + pixel_batch_cnt, offset);
              //reg_to_dram(2*i+1, (height)*(width) + row_batch_cnt*PTS_PER_COL*2*(width-2) + (2*(i-PTS_PER_COL)+1)*(width-2)  + pixel_batch_cnt+1, offset);
              reg_to_bramY(2*i, row_batch_cnt*PTS_PER_COL*BRAM_WIDTH+ cycle_num*(width-2) + (i-PTS_PER_COL)*BRAM_WIDTH + pixel_batch_cnt, offset);
              reg_to_bramY(2*i+1, row_batch_cnt*PTS_PER_COL*BRAM_WIDTH + cycle_num*(width-2) + (i-PTS_PER_COL)*BRAM_WIDTH + pixel_batch_cnt+1, offset);

            }
          }
          //cout << endl;

          pixel_batch_cnt+=2;
          if(pixel_batch_cnt>=(width-2)) {pixel_batch_cnt = 0; row_batch_cnt++;}

          if(row_batch_cnt >= BRAM_HEIGHT/PTS_PER_COL) {
            cycle_num++;
            row_batch_cnt = 0;
          }


          //offset += sc_core::sc_time(3*DELAY, sc_core::SC_NS);

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
 
    //offset += sc_core::sc_time(DELAY, sc_core::SC_NS);
}


void HW:: reg_to_dram(sc_dt::uint64 i, sc_dt::uint64 dram_addr, sc_core::sc_time &offset){
  //WRITE TO DRAM:
  pl_t pl_dram;
  unsigned char buf_dram[LEN_IN_BYTES];
  //cout << mem16[i] << " "; 
  to_uchar(buf_dram, mem16[i]);
  pl_dram.set_address(dram_addr);
  pl_dram.set_data_length(LEN_IN_BYTES);
  pl_dram.set_data_ptr(buf_dram);
  pl_dram.set_command(tlm::TLM_WRITE_COMMAND);
  pl_dram.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
  dram_ctrl_socket -> b_transport(pl_dram, offset);
}

void HW:: reg_to_bramX(sc_dt::uint64 i, sc_dt::uint64 bram_addr, sc_core::sc_time &offset){
  //WRITE TO DRAM:
  pl_t pl_bram;
  unsigned char buf_bram[LEN_IN_BYTES];
  //cout << mem16[i] << " "; 
  to_uchar(buf_bram, mem16[i]);
  pl_bram.set_address(bram_addr);
  pl_bram.set_data_length(LEN_IN_BYTES);
  pl_bram.set_data_ptr(buf_bram);
  pl_bram.set_command(tlm::TLM_WRITE_COMMAND);
  pl_bram.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
  bramX_socket -> b_transport(pl_bram, offset);
}

void HW:: reg_to_bramY(sc_dt::uint64 i, sc_dt::uint64 bram_addr, sc_core::sc_time &offset){
  //WRITE TO DRAM:
  pl_t pl_bram;
  unsigned char buf_bram[LEN_IN_BYTES];
  //cout << mem16[i] << " "; 
  to_uchar(buf_bram, mem16[i]);
  pl_bram.set_address(bram_addr);
  pl_bram.set_data_length(LEN_IN_BYTES);
  pl_bram.set_data_ptr(buf_bram);
  pl_bram.set_command(tlm::TLM_WRITE_COMMAND);
  pl_bram.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
  bramY_socket -> b_transport(pl_bram, offset);
}