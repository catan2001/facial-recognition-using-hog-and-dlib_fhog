#include "bram_ctrl.hpp"
 
BramCtrl::BramCtrl(sc_core::sc_module_name name) : 
    sc_module(name), 
    offset(sc_core::SC_ZERO_TIME),
    dram_row_ptr(0),
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
  unsigned char counter_init = 0;
  int bonus, skipped_rows;
  
  switch(cmd)
    {
    case tlm::TLM_WRITE_COMMAND:
 
      switch(addr)
        {
        case ADDR_WIDTH:
          width = to_int(buf);  
          dram_row_ptr = 0;
          write_filter(ADDR_WIDTH, width);
          break;

        case ADDR_HEIGHT:
          height = to_int(buf);
          write_filter(ADDR_HEIGHT, height);
          break;

        case ADDR_CMD:
          start = to_int(buf);
  
          if(width > BRAM_WIDTH) {
              pl.set_response_status(tlm::TLM_GENERIC_ERROR_RESPONSE);
              cout << "ERROR: Width of image is larger than BRAM_WIDTH[" << BRAM_WIDTH << "]" << endl;
              break;
          }
 
          initialisation(1);

          bonus = BRAM_HEIGHT - ((int)((floor(BRAM_WIDTH/width)*BRAM_HEIGHT/NUM_PARALLEL_POINTS)*NUM_PARALLEL_POINTS)%BRAM_HEIGHT);
          skipped_rows = floor(height/(BRAM_HEIGHT*floor(BRAM_WIDTH/width)))*bonus;

          for(int i = 0; i <= floor(height/NUM_PARALLEL_POINTS)*NUM_PARALLEL_POINTS + skipped_rows; i+=NUM_PARALLEL_POINTS){ ++//the number of times we will repeat a single cycle
              
              cycle_number = ((int)i/BRAM_HEIGHT)%((int)BRAM_WIDTH/width);  //i == BRAM_HEIGHT ? cycle_num++ cycle_num == floor(BRAM_WIDTH/width) ? cycle_num = 0
              bram_block_ptr = i%BRAM_HEIGHT;  // bram_block_ptr++ -> bram_block_ptr == BRAM_HEIGHT ? bram_ptr = 0

              if(cycle_number == (floor(BRAM_WIDTH/width)-1) && (bram_block_ptr >= (BRAM_HEIGHT-10) && bram_block_ptr <= (BRAM_HEIGHT-1))){
                if(dram_row_ptr<height){ //do we have more rows in DRAM?
                  
                  counter_init++; // counts how many times it's initialized, it's used to multiply dram_row_ptr
                  dram_row_ptr = (floor(BRAM_WIDTH/width)*BRAM_HEIGHT - (BRAM_HEIGHT-bram_block_ptr)) * counter_init;

                  i+=(BRAM_HEIGHT-bram_block_ptr);
                  cycle_number = ((int)i/BRAM_HEIGHT)%((int)BRAM_WIDTH/width);  //i == BRAM_HEIGHT ? cycle_num++ cycle_num == floor(BRAM_WIDTH/width) ? cycle_num = 0
                  bram_block_ptr = i%BRAM_HEIGHT;

                  initialisation(0);
                }
              }
                
              for(int j=0; j < width - 2; ++j){ 
              
              //PHASE I -> WRITE TO REG36:
                bram_to_reg(bram_block_ptr, cycle_number, j, ADDR_INPUT_REG, offset);
 
              //PHASE II -> FILTER REG36 INTO REG10:
                pl_t pl_filter;
                pl_filter.set_address(ADDR_CMD);
                pl_filter.set_command(tlm::TLM_WRITE_COMMAND);
                pl_filter.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);

                filter_socket -> b_transport(pl_filter, offset);
              }
          }

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
}

void BramCtrl:: initialisation(bool init){

  for(int i = 0; i < floor(BRAM_WIDTH/width); ++i) { //maximum number of rows that can fit in a single BRAM BLOCK
    for(int j = 0; j < BRAM_HEIGHT; ++j) {         //number of BRAM BLOCKS
        dram_row_ptr++;
        for(int k = 0; k < width; ++k) {
              dram_to_bram(init, i, j, k, offset); // load from DRAM to BRAM from 0th position
        }
        if(dram_row_ptr==height) return;
    }
  }

}
 
void BramCtrl:: dram_to_bram(int init, sc_dt::uint64 i, sc_dt::uint64 j, sc_dt::uint64 k, sc_core::sc_time &offset){
 
  //READ FROM DRAM:
  pl_t pl_dram;
  sc_dt::uint64 dram_addr;
  sc_dt::uint64 bram_addr;
  if(init){
    dram_addr = i*(BRAM_HEIGHT*(this->width)) + j*(this->width) + k;
    bram_addr = i*(this->width) + j*BRAM_WIDTH + k;
  }else{
    dram_addr = (dram_row_ptr-1)*(this->width) + k;
    bram_addr = i*(this->width) + j*BRAM_WIDTH + k;
  }
  
  unsigned char buf_dram[LEN_IN_BYTES];

  pl_dram.set_address(dram_addr);
  pl_dram.set_data_length(LEN_IN_BYTES);
  pl_dram.set_data_ptr(buf_dram);
  pl_dram.set_command(tlm::TLM_READ_COMMAND);
  pl_dram.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
  dram_ctrl_socket->b_transport(pl_dram, offset);
 
  //WRITE TO BRAM:
  pl_t pl_bram;
 
  pl_bram.set_address(bram_addr);
  pl_bram.set_data_length(LEN_IN_BYTES);
  pl_bram.set_data_ptr(buf_dram);
  pl_bram.set_command(tlm::TLM_WRITE_COMMAND);
  pl_bram.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
  bram_socket0 -> b_transport(pl_bram, offset);
}
 
void BramCtrl:: bram_to_reg(int bram_block_ptr, int cycle_num, int row_position, sc_dt::uint64 addr_filter, sc_core::sc_time &offset){
 
  //READ FROM BRAM:
  pl_t pl_bram0;
  num_t2 buf[(NUM_PARALLEL_POINTS+2)*3];
  unsigned char buf_bram[LEN_IN_BYTES*(NUM_PARALLEL_POINTS+2)*3];
  unsigned char buf_bram0[LEN_IN_BYTES];
 
  if(bram_block_ptr >= (BRAM_HEIGHT-10) && bram_block_ptr <= (BRAM_HEIGHT-1)){
 
    for(int i = 0; i < (BRAM_HEIGHT-bram_block_ptr); ++i){
 
      for(int j = 0; j < 3; ++j) {
      pl_bram0.set_address((bram_block_ptr+i)*BRAM_WIDTH + row_position + cycle_num*width + j);
      pl_bram0.set_data_length(LEN_IN_BYTES);
      pl_bram0.set_data_ptr(buf_bram0);
      pl_bram0.set_command(tlm::TLM_READ_COMMAND);
      pl_bram0.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
      bram_socket0->b_transport(pl_bram0, offset);
 
      buf[i*3 + j] = to_fixed(buf_bram0); 
      }
    }
 
    for(int i = 0; i < (NUM_PARALLEL_POINTS + 2 - (BRAM_HEIGHT-bram_block_ptr)); ++i){
 
      for(int j = 0; j < 3; ++j) {
        pl_bram0.set_address(i*BRAM_WIDTH + row_position + ((cycle_num+1)%((int)(BRAM_WIDTH/width)))*width + j);
        pl_bram0.set_data_length(LEN_IN_BYTES);
        pl_bram0.set_data_ptr(buf_bram0);
        pl_bram0.set_command(tlm::TLM_READ_COMMAND);
        pl_bram0.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
        bram_socket0->b_transport(pl_bram0, offset);
        buf[(i + (59-bram_block_ptr))*3 + j] = to_fixed(buf_bram0); 
      }
    }
 
  }else{
 
    for(int i = 0; i < (NUM_PARALLEL_POINTS+2); ++i){
      for(int j = 0; j < 3; ++j) {   
      pl_bram0.set_address(cycle_num*width + row_position + (bram_block_ptr+i)*BRAM_WIDTH + j);
      pl_bram0.set_data_length(LEN_IN_BYTES);
      pl_bram0.set_data_ptr(buf_bram0);
      pl_bram0.set_command(tlm::TLM_READ_COMMAND);
      pl_bram0.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
      bram_socket0->b_transport(pl_bram0, offset);

      buf[i*3 + j] = to_fixed(buf_bram0); 
      }
    }
  }
 
  for(int i=0; i<(NUM_PARALLEL_POINTS+2)*3; ++i){
      to_uchar(buf_bram0, buf[i]);
 
      pl_t pl_filter;
      pl_filter.set_address(addr_filter);
      pl_filter.set_data_length(LEN_IN_BYTES);
      pl_filter.set_data_ptr(buf_bram0);
      pl_filter.set_command(tlm::TLM_WRITE_COMMAND);
      pl_filter.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
      filter_socket -> b_transport(pl_filter, offset); 
 
      num_t2 t = to_fixed (buf_bram0);
  }
}

void BramCtrl::write_filter(sc_dt::uint64 addr, int val)
{
    pl_t pl;
    unsigned char buf[LEN_IN_BYTES];
    int_to_uchar(buf, val); // NOTE: only for int...
    pl.set_address(addr);
    pl.set_data_length(LEN_IN_BYTES);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_WRITE_COMMAND);
    pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    filter_socket->b_transport(pl, offset);
}

