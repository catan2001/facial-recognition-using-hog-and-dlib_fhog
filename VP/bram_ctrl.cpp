#include "bram_ctrl.hpp"
 
BramCtrl::BramCtrl(sc_core::sc_module_name name) : 
    sc_module(name), 
    dram_row_ptr(0),
    cycle_number(0),
    cycle_num_in(0),
    cycle_num_out(0),
    bram_block_ptr(0),
    counter_init(0),
    effective_row_limit(0),
    dram_row_ptr_xy(0),
    width(0),
    height(0),
    start(0),
    reset(0),
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
    counter_init = 0;

  switch(cmd)
    {
    case tlm::TLM_WRITE_COMMAND:
 
      switch(addr)
        {
        case ADDR_WIDTH:
          width = to_int(buf);  
          dram_row_ptr = 0;
          dram_row_ptr_xy = 0;
          write_filter(ADDR_WIDTH, width, offset);
          break;

        case ADDR_WIDTH_2:
          width_2 = to_int(buf);
          break;

        case ADDR_WIDTH_4:
          width_4 = to_int(buf);
          break;

        case ADDR_HEIGHT:
          height = to_int(buf);
          write_filter(ADDR_HEIGHT, height, offset);
          break;

        case ADDR_BRAM_HEIGHT:
          bram_height = to_int(buf);
          break;

        case ADDR_EFFECTIVE_ROW_LIMIT:
          effective_row_limit = to_int(buf);
          break;

        case ADDR_ROWS_IN_BRAM:
          row_capacity_bram = to_int(buf);
          break;

        case ADDR_CYCLE_NUM_IN:
          cycle_num_in = to_int(buf);
          break;

        case ADDR_CYCLE_NUM_OUT:
          cycle_num_out = to_int(buf);
          break;

        case ADDR_DRAM_IN:
          base_addr_input = to_int(buf);
          break;

        case ADDR_DRAM_X:
          base_addr_dx = to_int(buf);
          break;

        case ADDR_DRAM_Y:
          base_addr_dy = to_int(buf);
          break;

        case ADDR_RESET:
          reset = to_int(buf);

          if(reset) ready = 1;
          break;

        case ADDR_START:
          start = to_int(buf);
  
          if(width > BRAM_WIDTH) {
              pl.set_response_status(tlm::TLM_GENERIC_ERROR_RESPONSE);
              cout << "ERROR: Width of image is larger than BRAM_WIDTH[" << BRAM_WIDTH << "]" << endl;
              break;
          }
        
          //cout << "Time before control logic " << offset << endl;
          control_logic(offset);
          //cout << "Time after control logic " << offset << endl;
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
          int_to_uchar(buf,ready);
          break;
        default:
          pl.set_response_status( tlm::TLM_ADDRESS_ERROR_RESPONSE );
        }

      if (len != 2) pl.set_response_status( tlm::TLM_BURST_ERROR_RESPONSE );
      break;

    default:
      pl.set_response_status( tlm::TLM_COMMAND_ERROR_RESPONSE );
    
    }
  offset += sc_core::sc_time(DELAY, sc_core::SC_NS);  
}

void BramCtrl::Dram2BramBridge(sc_core::sc_time &offset){

    //initial time lag for 
    //FILTER_BLOCKS 4 clk
    offset += sc_core::sc_time(4*DELAY, sc_core::SC_NS);

    for(int i = 0; i < cycle_num_in; ++i) { 
        for(int j = 0; j < BRAM_HEIGHT; ++j) {
            //cout << dram_row_ptr << endl;

            dram_row_ptr++;
            for(int k = 0; k < width; ++k) {
                dram_to_bram(i, j, k, offset);
            }
            if(dram_row_ptr==height) return;
        }
    }
        //cout << endl;
}

void BramCtrl::Bram2DramBridge(sc_core::sc_time &offset){

    for(int i = 0; i < cycle_num_out; ++i) { 
        for(int j = 0; j < BRAM_HEIGHT; ++j) {    
            //exists only for delay:
            if(finished){
              offset += sc_core::sc_time(11*DELAY, sc_core::SC_NS);
            }
            
            for(int k = 0; k < width-2; ++k) {
                bram_to_dram(i, j, k, offset);
            }
        
            dram_row_ptr_xy+=2;
            if(dram_row_ptr_xy==(height-2)*2) return;
        }
    }
}

void BramCtrl::control_logic(sc_core::sc_time &offset){

  if (start == 1 && ready == 1){
    
    ready = 0;
		offset += sc_core::sc_time(10, sc_core::SC_NS);

	}else if(start == 0 && ready == 0){
   
    Dram2BramBridge(offset);

    for(int i = 0; i <= effective_row_limit; i+=PTS_PER_COL){ //the number of times we will repeat a single cycle
        
      cycle_number = ((int)i/BRAM_HEIGHT)%cycle_num_in; 
      bram_block_ptr = i%BRAM_HEIGHT;

      if(cycle_number == (cycle_num_in-1) && (bram_block_ptr == 12)){
        if(dram_row_ptr<height){ 
          
          counter_init++; 
          dram_row_ptr = (row_capacity_bram - (BRAM_HEIGHT-bram_block_ptr)) * counter_init;
          
          //row_capacity_bram - 1 -> the number of rows that will fit into BRAM
          // divide by four and floor before multiplying by four to get the last divisible int number by 4 until 127
          //multiply by two because of x and y
          dram_row_ptr_xy = (floor((row_capacity_bram - 1)/4))*8*(counter_init-1);

          i+=(BRAM_HEIGHT-bram_block_ptr);
         
          cycle_number = 0;
          bram_block_ptr = 0;

          // RESETS cycle_num inside HW
          pl_t pl_filter_config;
          pl_filter_config.set_address(ADDR_CONFIG);
          pl_filter_config.set_command(tlm::TLM_WRITE_COMMAND);
          pl_filter_config.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);

          filter_socket -> b_transport(pl_filter_config, offset);

          Bram2DramBridge(offset);
          Dram2BramBridge(offset);
        }
      }
        
      for(int j=0; j < width - 2; j+=2){ 
      
      //PHASE I -> WRITE TO REG24:
        bram_to_reg(bram_block_ptr, cycle_number, j, ADDR_INPUT_REG, offset);

      //PHASE II -> FILTER REG24 INTO REG16:
        pl_t pl_filter;
        pl_filter.set_address(ADDR_START);
        pl_filter.set_command(tlm::TLM_WRITE_COMMAND);
        pl_filter.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);

        filter_socket -> b_transport(pl_filter, offset);
      }
    }
    finished = 1;
    dram_row_ptr_xy = (floor((row_capacity_bram - 1)/4))*4*2*(counter_init);
    Bram2DramBridge(offset);
    ready = 1;
  }
}
 
void BramCtrl:: dram_to_bram(sc_dt::uint64 i, sc_dt::uint64 j, sc_dt::uint64 k, sc_core::sc_time &offset){
 
  //READ FROM DRAM:
  pl_t pl_dram;
  sc_dt::uint64 dram_addr;
  sc_dt::uint64 bram_addr;

  dram_addr = base_addr_input + (dram_row_ptr-1)*(this->width) + k;
  bram_addr = i*(this->width) + j*BRAM_WIDTH + k;
      
  
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
 
  bram_socket -> b_transport(pl_bram, offset);
}
 
void BramCtrl:: bram_to_reg(u16_t bram_block_ptr, u16_t cycle_num, u16_t row_position, sc_dt::uint64 addr_filter, sc_core::sc_time &offset){
 
  //READ FROM BRAM:
  pl_t pl_bram;
  output_t buf[(PTS_PER_COL+2)*4];
  unsigned char buf_bram[LEN_IN_BYTES*(PTS_PER_COL+2)*4];
  unsigned char buf_bram0[LEN_IN_BYTES];
 
 
  if(bram_block_ptr == 12){
 
    for(int i = 0; i < (BRAM_HEIGHT-bram_block_ptr); ++i){
 
      for(int j = 0; j < 4; ++j) {
      pl_bram.set_address((bram_block_ptr+i)*BRAM_WIDTH + row_position + cycle_num*width + j);
      pl_bram.set_data_length(LEN_IN_BYTES);
      pl_bram.set_data_ptr(buf_bram0);
      pl_bram.set_command(tlm::TLM_READ_COMMAND);
      pl_bram.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
      bram_socket->b_transport(pl_bram, offset);
 
      buf[i*4 + j] = to_fixed(buf_bram0); 
      }
    }
 
    for(int i = 0; i < (PTS_PER_COL + 2 - (BRAM_HEIGHT-bram_block_ptr)); ++i){
 
      for(int j = 0; j < 4; ++j) {
        pl_bram.set_address(i*BRAM_WIDTH + row_position + ((cycle_num+1)%((int)(BRAM_WIDTH/width)))*width + j);
        pl_bram.set_data_length(LEN_IN_BYTES);
        pl_bram.set_data_ptr(buf_bram0);
        pl_bram.set_command(tlm::TLM_READ_COMMAND);
        pl_bram.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
        bram_socket->b_transport(pl_bram, offset);
        buf[(i + (BRAM_HEIGHT-bram_block_ptr))*4 + j] = to_fixed(buf_bram0); 
      }
    }
 
  }else{
 
    for(int i = 0; i < (PTS_PER_COL+2); ++i){
      for(int j = 0; j < 4; ++j) {   
      pl_bram.set_address(cycle_num*width + row_position + (bram_block_ptr+i)*BRAM_WIDTH + j);
      pl_bram.set_data_length(LEN_IN_BYTES);
      pl_bram.set_data_ptr(buf_bram0);
      pl_bram.set_command(tlm::TLM_READ_COMMAND);
      pl_bram.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
      bram_socket->b_transport(pl_bram, offset);

      buf[i*4 + j] = to_fixed(buf_bram0); 
      }
    }
  }
 
  for(int i=0; i<(PTS_PER_COL+2)*4; ++i){
      to_uchar(buf_bram0, buf[i]); 
      pl_t pl_filter;
      pl_filter.set_address(addr_filter);
      pl_filter.set_data_length(LEN_IN_BYTES);
      pl_filter.set_data_ptr(buf_bram0);
      pl_filter.set_command(tlm::TLM_WRITE_COMMAND);
      pl_filter.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
      filter_socket -> b_transport(pl_filter, offset); 
  }
}

void BramCtrl::write_filter(sc_dt::uint64 addr, u16_t val, sc_core::sc_time &offset)
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

void BramCtrl:: bram_to_dram(sc_dt::uint64 i, sc_dt::uint64 j, sc_dt::uint64 k, sc_core::sc_time &offset){
 
  //READ FROM DRAM:
  pl_t pl_bram_x, pl_bram_y;
  sc_dt::uint64 dram_addr_x;
  sc_dt::uint64 dram_addr_y;
  sc_dt::uint64 bram_addr_x;
  sc_dt::uint64 bram_addr_y;

  dram_addr_x = (dram_row_ptr_xy)*(this->width-2) + k + base_addr_dx;
  dram_addr_y = (dram_row_ptr_xy + 1)*(this->width-2) + k + base_addr_dy;
  bram_addr_x = i*(this->width-2) + j*BRAM_WIDTH + k;
  bram_addr_y = i*(this->width-2) + j*BRAM_WIDTH + k;
      
  
  unsigned char buf_bram_x[LEN_IN_BYTES];
  unsigned char buf_bram_y[LEN_IN_BYTES];

  //READ FROM BRAMX:
  pl_bram_x.set_address(bram_addr_x);
  pl_bram_x.set_data_length(LEN_IN_BYTES);
  pl_bram_x.set_data_ptr(buf_bram_x);
  pl_bram_x.set_command(tlm::TLM_READ_COMMAND);
  pl_bram_x.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
  bramX_socket->b_transport(pl_bram_x, offset);
 
  //WRITE TO DRAM:
  pl_t pl_dram_xy_ctrl;
 
  pl_dram_xy_ctrl.set_address(dram_addr_x);
  pl_dram_xy_ctrl.set_data_length(LEN_IN_BYTES);
  pl_dram_xy_ctrl.set_data_ptr(buf_bram_x);
  pl_dram_xy_ctrl.set_command(tlm::TLM_WRITE_COMMAND);
  pl_dram_xy_ctrl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
  dram_ctrlX_socket -> b_transport(pl_dram_xy_ctrl, offset);

  //READ FROM BRAMY:
  pl_bram_y.set_address(bram_addr_y);
  pl_bram_y.set_data_length(LEN_IN_BYTES);
  pl_bram_y.set_data_ptr(buf_bram_y);
  pl_bram_y.set_command(tlm::TLM_READ_COMMAND);
  pl_bram_y.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
  bramY_socket->b_transport(pl_bram_y, offset);
 
  //WRITE TO DRAM:
  pl_dram_xy_ctrl.set_address(dram_addr_y);
  pl_dram_xy_ctrl.set_data_length(LEN_IN_BYTES);
  pl_dram_xy_ctrl.set_data_ptr(buf_bram_y);
  pl_dram_xy_ctrl.set_command(tlm::TLM_WRITE_COMMAND);
  pl_dram_xy_ctrl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
 
  dram_ctrlY_socket -> b_transport(pl_dram_xy_ctrl, offset);
}

