#include "bram_ctrl.hpp"

BramCtrl::BramCtrl(sc_core::sc_module_name name) : 
    sc_module(name), 
    offset(sc_core::SC_ZERO_TIME),
    ii(0),
    jj(0),
    pixel_cnt(0),
    moduo_points(0),
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
          cout << "width: " << width <<endl;
          cout << "len: " << len << endl;
          break;
        case ADDR_HEIGHT:
          height = to_int(buf);
          cout << "height: " << height << endl;
          break;
        case ADDR_CMD:
          start = to_int(buf);

          if(width > BRAM_WIDTH) cout << "ERROR" << endl;

          //INIT:
          //place as many rows of the picture into BRAM as you can:        
          cout << BRAM_HEIGHT << endl;
          for(int i=0; i<BRAM_HEIGHT; ++i){
            for(int j=0; j<width; ++j){
        //      cout << "dram_to_bram" << endl;
              dram_to_bram(i*width + j, offset);
            }
          }
        cout << "height : " << height << endl;
        cout << "dram_to_bram" << endl;
          //START:
          for(int i=0; i<BRAM_HEIGHT; ++i){ // da li ovjde umjesto height treba BRAM_HEIGHT
            for(int j=0; j<floor(width*0.1)+2; ++j){
            cout << i << " , " << j << endl; 
            //PHASE I -> WRITE TO REG36:
              if(i == BRAM_HEIGHT-2){ //processing the row before the last one
                //processing a single row:
                if(j==floor(width*0.1)+1){ //if we're at the last pixels of a row
                  bram_to_reg(moduo_points, i, i+1, 0, ADDR_INPUT_REG, offset);
                }else{                     //if we're not at the end of a row
                  bram_to_reg(NUM_PARALLEL_POINTS+2, i, i+1, 0, ADDR_INPUT_REG, offset);
                }

              }else if(i == BRAM_HEIGHT-1){ //processing the last row
                //processing a single row:
                if(j==floor(width*0.1)+1){ //if we're at the last pixels of a row
                  bram_to_reg(moduo_points, i, 0, 1, ADDR_INPUT_REG, offset);
                }else{                     //if we're not at the end of a row
                  bram_to_reg(NUM_PARALLEL_POINTS+2, i, 0, 1, ADDR_INPUT_REG, offset);
                }

              }else{                       //processing all other rows
                //processing a single row:
                if(j==floor(width*0.1)+1){ //if we're at the last pixels of a row
                  bram_to_reg(moduo_points, i, i+1, i+2, ADDR_INPUT_REG, offset);
                }else{                     //if we're not at the end of a row
                  bram_to_reg(NUM_PARALLEL_POINTS+2, i, i+1, i+2, ADDR_INPUT_REG, offset);
                }
              }
    
            //PHASE II -> FILTER REG36 INTO REG10:
             x`pl_t pl_filter;

              pl_filter.set_address(ADDR_CMD);
              pl_filter.set_command(tlm::TLM_WRITE_COMMAND);
              pl_filter.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
              
              filter_socket -> b_transport(pl_filter, offset);
            
            //PHASE III -> WRITE REG10 INTO DRAM:



            //PHASE IV -> READ FROM DRAM AND WRITE INTO BRAM:

            }
          }
          cout << "finished " << endl;
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
  bram_socket0->b_transport(pl_bram, offset); // TODO: change naming scheme, it's weird myb?
  //bram_socket_b2->b_transport(pl_bram, offset); // TODO: do we need all 3???
  //bram_socket_b3->b_transport(pl_bram, offset);   

  // IF BRAM IS EMPTY, LOAD FROM DRAM:
  dram_ctrl_socket->b_transport(pl_bram,offset);

  if (pl_bram.is_response_error()) SC_REPORT_ERROR("Bram_Ctrl",pl_bram.get_response_string().c_str());
}

void BramCtrl:: dram_to_bram(sc_dt::uint64 addr, sc_core::sc_time &offset){

  //READ FROM DRAM:
  pl_t pl_dram;
  unsigned char buf_dram[LEN_IN_BYTES];

  pl_dram.set_address(addr * LEN_IN_BYTES);
  pl_dram.set_data_length(LEN_IN_BYTES);
  pl_dram.set_data_ptr(buf_dram);
  pl_dram.set_command(tlm::TLM_READ_COMMAND);
  pl_dram.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
  
  dram_ctrl_socket->b_transport(pl_dram, offset);

  //WRITE TO BRAM:
  pl_t pl_bram;

  pl_bram.set_address(addr * LEN_IN_BYTES);
  pl_bram.set_data_length(LEN_IN_BYTES);
  pl_bram.set_data_ptr(buf_dram);
  pl_bram.set_command(tlm::TLM_WRITE_COMMAND);
  pl_bram.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
  
  bram_socket0 -> b_transport(pl_bram, offset);

}

void BramCtrl:: bram_to_reg(int num_parallel_pts, sc_dt::uint64 addr_bram0, sc_dt::uint64 addr_bram1, sc_dt::uint64 addr_bram2, sc_dt::uint64 addr_filter, sc_core::sc_time &offset){

  //READ FROM BRAM:
  pl_t pl_bram0, pl_bram1, pl_bram2;
  unsigned char buf_bram[LEN_IN_BYTES*num_parallel_pts*3];
  unsigned char buf_bram0[LEN_IN_BYTES*num_parallel_pts];
  unsigned char buf_bram1[LEN_IN_BYTES*num_parallel_pts];
  unsigned char buf_bram2[LEN_IN_BYTES*num_parallel_pts];

  pl_bram0.set_address(addr_bram0 * LEN_IN_BYTES);
  pl_bram0.set_data_length(LEN_IN_BYTES*num_parallel_pts);
  pl_bram0.set_data_ptr(buf_bram0);
  pl_bram0.set_command(tlm::TLM_READ_COMMAND);
  pl_bram0.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);

  pl_bram1.set_address(addr_bram1 * LEN_IN_BYTES);
  pl_bram1.set_data_length(LEN_IN_BYTES*num_parallel_pts);
  pl_bram1.set_data_ptr(buf_bram1);
  pl_bram1.set_command(tlm::TLM_READ_COMMAND);
  pl_bram1.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);

  pl_bram2.set_address(addr_bram2 * LEN_IN_BYTES);
  pl_bram2.set_data_length(LEN_IN_BYTES*num_parallel_pts);
  pl_bram2.set_data_ptr(buf_bram2);
  pl_bram2.set_command(tlm::TLM_READ_COMMAND);
  pl_bram2.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
  
  //bram_socket0->b_transport(pl_bram0, offset);
  bram_socket1->b_transport(pl_bram1, offset);
  bram_socket2->b_transport(pl_bram2, offset);

  for(int i=0; i<num_parallel_pts; ++i){
    for(int j=0; j<LEN_IN_BYTES; ++j){
      buf_bram[i*LEN_IN_BYTES*KERNEL_SIZE + j] = buf_bram0[i*LEN_IN_BYTES+j]; //0 1 <= 0 1 
      buf_bram[i*LEN_IN_BYTES*KERNEL_SIZE + j + LEN_IN_BYTES] = buf_bram1[i*LEN_IN_BYTES+j]; //2 3 <= 0 1
      buf_bram[i*LEN_IN_BYTES*KERNEL_SIZE + j + LEN_IN_BYTES*2] = buf_bram2[i*LEN_IN_BYTES+j]; //4 5 <= 0 1
    }
  }

  //WRITE TO REG36:
  pl_t pl_filter;

  pl_filter.set_address(addr_filter);
  pl_filter.set_data_length(LEN_IN_BYTES*num_parallel_pts*3);
  pl_filter.set_data_ptr(buf_bram);
  pl_filter.set_command(tlm::TLM_WRITE_COMMAND);
  pl_filter.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
  
  filter_socket -> b_transport(pl_filter, offset);

}
