#include "bram_ctrl.hpp"
 
BramCtrl::BramCtrl(sc_core::sc_module_name name) : 
    sc_module(name), 
    offset(sc_core::SC_ZERO_TIME),
    pixel_cnt(0),
    moduo_points(0),
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
  
  switch(cmd)
    {
    case tlm::TLM_WRITE_COMMAND:
 
      switch(addr)
        {

        case ADDR_WIDTH:
          width = to_int(buf);
          moduo_points = (width - floor(width*0.1) + 1)*LEN_IN_BYTES;
          //cout << "ADDR_WIDTH" << endl;
          break;

        case ADDR_HEIGHT:
          height = to_int(buf);
          //cout << "ADDR_HEIGHT" << endl;
          break;
        case ADDR_CMD:
          start = to_int(buf);
          //cout << "ADDR_CMD" << endl;
          if(width > BRAM_WIDTH) {
              pl.set_response_status(tlm::TLM_GENERIC_ERROR_RESPONSE);
              cout << "ERROR: Width of image is larger than BRAM_WIDTH[" << BRAM_WIDTH << "]" << endl;
              break;
          }
 
          initialisation(1);

          //if there is more of the picture in DRAM  we should write those rows into BRAM overwritting from the beginning of BRAM
          //the cycle number for a picture of 350x350 gives us 5 cycles since each BRAM block can fit 5 rows 
          //cycle num = 0 1 2 3 4
          //we need to reset this cycle num to 0 again when the bram_pointer reaches [49,58] with the cycle_num at 4
          //so if cycle_num == floor(BRAM_WIDTH/width) and bram_ptr = [BRAM_HEIGHT-10, BRAM_HEIGHT-1] -> cycle_num = 0
          //this if should also check if we need to do a new initialisation before continuing 
          //so after another possible init and reseting of the cycle_num we should continue with the for loop

          for(int i = 0; i <= floor(height/NUM_PARALLEL_POINTS)*NUM_PARALLEL_POINTS; i+=NUM_PARALLEL_POINTS){ //the number of times we will repeat a single cycle
              
              //(int)i/BRAM_HEIGHT -> change cycles every time i has gone through all 59 BRAM BLOCKS
              //floor(BRAM_WIDTH/width) -> keep the maximum number of cycles within what is possible
              cycle_number = ((int)i/BRAM_HEIGHT)%((int)BRAM_WIDTH/width);
              bram_block_ptr = i%BRAM_HEIGHT;

              cout << "cycle_number: " << cycle_number;
              cout << " bram_block_ptr: " << bram_block_ptr << endl;

              //if we're on the last cycle and the bram_block_ptr is on the rows which will need supplementation rows from the next cycle
              //which currently doesn't exist -> check if we have more rows in DRAM that need to be stored and transfer them

              if(cycle_number == (floor(BRAM_WIDTH/width)-1) && (bram_block_ptr >= (BRAM_HEIGHT-10) && bram_block_ptr <= (BRAM_HEIGHT-1))){
                if(dram_row_ptr<height){ //do we have more rows in DRAM?
                  cout << endl << endl << "INITIALIZATION AGAIN!!!!!!!!!!!!!!!!!" << endl << endl << endl;
                  initialisation(0);
                }
              }


              for(int j=0; j < width - 2; ++j){
                //cout << i << " , " << j << endl; 
 
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
 
  //if (pl_bram.is_response_error()) SC_REPORT_ERROR("Bram_Ctrl",pl_bram.get_response_string().c_str());*/
}

void BramCtrl:: initialisation(bool init){

  for(int i = 0; i < floor(BRAM_WIDTH/width); ++i) { //maximum number of rows that can fit in a single BRAM BLOCK
    for(int j = 0; j < BRAM_HEIGHT; ++j) {         //number of BRAM BLOCKS
        dram_row_ptr++;
        cout<< "dram_row_ptr: " << dram_row_ptr << endl;
        //placing a single row on the i-th position within the j-th BRAM BLOCK:
        for(int k = 0; k < width; ++k) {
              dram_to_bram(init, i, j, k, offset); // load from DRAM to BRAM from 0th position
        }

        //if all the rows of our picture have been loaded into the BRAM exit the loop:
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
    dram_addr = i*(BRAM_HEIGHT*(this->width)) + (dram_row_ptr-1)*(this->width) + k; // h is replacing j for rows 
    bram_addr = i*(this->width) + j*BRAM_WIDTH + k;
  }
  
  cout << "DRAM ADDR: " << dram_addr << endl;
  //cout << "BRAM ADDR: " << bram_addr << endl;
  unsigned char buf_dram[LEN_IN_BYTES];
  // we don't need address of DRAM, it's connected directly BRAM_CTRL -> DRAM_CTRL
  pl_dram.set_address(dram_addr);
  pl_dram.set_data_length(LEN_IN_BYTES);
  pl_dram.set_data_ptr(buf_dram);
  pl_dram.set_command(tlm::TLM_READ_COMMAND);
  pl_dram.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
  dram_ctrl_socket->b_transport(pl_dram, offset);
  //if (pl_dram.is_response_error()) SC_REPORT_ERROR("Dram CTRL",pl_dram.get_response_string().c_str());
 
  //WRITE TO BRAM:
  pl_t pl_bram;
 
  pl_bram.set_address(bram_addr);
  pl_bram.set_data_length(LEN_IN_BYTES);
  pl_bram.set_data_ptr(buf_dram);
  pl_bram.set_command(tlm::TLM_WRITE_COMMAND);
  pl_bram.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
  bram_socket0 -> b_transport(pl_bram, offset);
  //if (pl_bram.is_response_error()) SC_REPORT_ERROR("Bram CTRL",pl_bram.get_response_string().c_str());
}
 
void BramCtrl:: bram_to_reg(int bram_block_ptr, int cycle_num, int row_position, sc_dt::uint64 addr_filter, sc_core::sc_time &offset){
 
  //READ FROM BRAM:
  pl_t pl_bram0;
  num_t2 buf[(NUM_PARALLEL_POINTS+2)*3];
  unsigned char buf_bram[LEN_IN_BYTES*(NUM_PARALLEL_POINTS+2)*3];
  unsigned char buf_bram0[LEN_IN_BYTES];
 
                        //49                                  //58
  if(bram_block_ptr >= (BRAM_HEIGHT-10) && bram_block_ptr <= (BRAM_HEIGHT-1)){
 
    for(int i = 0; i < (BRAM_HEIGHT-bram_block_ptr); ++i){
 
      /*cout << "CORNER CASE: [49, 58] " << i << endl;
 
      cout << "address regular:" << (bram_block_ptr)*BRAM_WIDTH + cycle_num*width + i << endl;
      cout << "bram_block_ptr:" << bram_block_ptr << endl;
      cout << "cycle_num*width:" << cycle_num*width << endl;
      cout << "i:" << i << endl;*/
 
      for(int j = 0; j < 3; ++j) {
      pl_bram0.set_address((bram_block_ptr+i)*BRAM_WIDTH + row_position + cycle_num*width + j);
      pl_bram0.set_data_length(LEN_IN_BYTES);
      pl_bram0.set_data_ptr(buf_bram0);
      pl_bram0.set_command(tlm::TLM_READ_COMMAND);
      pl_bram0.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
      bram_socket0->b_transport(pl_bram0, offset);
 
      buf[i*3 + j] = to_fixed(buf_bram0); 
      
      //cout << to_fixed(buf_bram0) << " ";
      }

      //cout << endl;
    }
 
 
    for(int i = 0; i < (NUM_PARALLEL_POINTS + 2 - (BRAM_HEIGHT-bram_block_ptr)); ++i){
 
      /*cout << "CORNER CASE: [0, 9]" << (bram_block_ptr+i)*BRAM_WIDTH + (59-bram_block_ptr) + (cycle_num+1)*width << endl;
      cout << "bram_block_ptr:" << bram_block_ptr << endl;
      cout << "(59-bram_block_ptr):" << (59-bram_block_ptr) << endl;
      cout << "cycle_num*width:" << (cycle_num+1)*width << endl;
      cout << "i:" << i << endl;*/
 
      for(int j = 0; j < 3; ++j) {
        pl_bram0.set_address(i*BRAM_WIDTH + row_position + ((cycle_num+1)%((int)(BRAM_WIDTH/width)))*width + j);
        pl_bram0.set_data_length(LEN_IN_BYTES);
        pl_bram0.set_data_ptr(buf_bram0);
        pl_bram0.set_command(tlm::TLM_READ_COMMAND);
        pl_bram0.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
        bram_socket0->b_transport(pl_bram0, offset);
        buf[(i + (59-bram_block_ptr))*3 + j] = to_fixed(buf_bram0); 
 
        //cout << to_fixed(buf_bram0) << " ";
      }

      //cout << endl;
    }
 
  }else{
 
    for(int i = 0; i < (NUM_PARALLEL_POINTS+2); ++i){
 
      /*cout << "redovna adresa: " << cycle_num*width + row_position + (bram_block_ptr+i)*BRAM_WIDTH << endl;
      cout << "br bram bloka: " << bram_block_ptr << endl;
      cout << "pozicija u redu: " << row_position << endl;
      cout << "br ciklusa: " << cycle_num << endl;*/
 
      for(int j = 0; j < 3; ++j) {   
      //bram_block_ptr*BRAM_WIDTH - koji je pocetni BRAM BLOK
      //cycle_num*width - koji red unutar BRAM BLOKA citamo
      //row_position - pocetni pixel unutar tog reda
      // i - trenutni BRAM BLOK od pocetnog
      pl_bram0.set_address(cycle_num*width + row_position + (bram_block_ptr+i)*BRAM_WIDTH + j);
      pl_bram0.set_data_length(LEN_IN_BYTES);
      pl_bram0.set_data_ptr(buf_bram0);
      pl_bram0.set_command(tlm::TLM_READ_COMMAND);
      pl_bram0.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
      bram_socket0->b_transport(pl_bram0, offset);
      //cout << "address: " << cycle_num*width + row_position + (bram_block_ptr+i)*BRAM_WIDTH + j << endl;
      //cout << to_fixed(buf_bram00) << endl; 
 
      buf[i*3 + j] = to_fixed(buf_bram0); 
 
      //cout << " buf : " << buf[i*3 + j] << endl;
      unsigned char test[LEN_IN_BYTES];
      to_uchar(test, buf[i*3 + j]);
      //cout << "uchar buf: " << *test << endl;
 
      }
    }
  }
 
  //cout << "CITAV BUF: " << endl << endl << endl;
 
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
    //cout << "bram: " << t << " ";

  }
  //cout << endl; 
 
}
 
void BramCtrl::read_bram(sc_dt::uint64 addr_bram, sc_core::sc_time &offset) {
 
  pl_t pl_filter;
 
  unsigned char buf[LEN_IN_BYTES];
 
  pl_filter.set_address(addr_bram);
  pl_filter.set_data_length(LEN_IN_BYTES);
  pl_filter.set_data_ptr(buf);
  pl_filter.set_command(tlm::TLM_READ_COMMAND);
  pl_filter.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
  bram_socket0 -> b_transport(pl_filter, offset); // TODO: change 0 
 
  //cout << to_fixed(buf) << " ";
}
