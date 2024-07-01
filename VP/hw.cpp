#include "hw.hpp"
//SC_HAS_PROCESS(HW);

HW::HW(sc_core::sc_module_name name)
    : sc_module(name)
{
    SC_REPORT_INFO("Hard", "Constructed.");
    //SC_THREAD(filter_image_t);
}

HW::~HW()
{
    SC_REPORT_INFO("Hard", "Destroyed.");
}


//TODO: change for implementing in HW
void HW::filter_image_t(void){
  array_t imROI(9, num_t(W, I, Q, O));
  matrix_t padded_img(ROWS+2, array_t(COLS+2, num_t(W,I,Q, O)));
  matrix_t matrix_im_filtered_y(ROWS, array_t(COLS, num_t(W,I,Q,O)));
  matrix_t matrix_im_filtered_x(ROWS, array_t(COLS, num_t(W,I,Q,O)));
  //test
    for(int i=0; i<ROWS+2; ++i){
      for(int j=0; j<COLS+2; ++j){
        padded_img[i][j] = read_bram(i*(COLS+2)+j);
      }
    }

    for (int i=0; i<ROWS; ++i){ // prone to changes
        for (int j=0; j<COLS; ++j){
            //unrolled
            imROI[0] = padded_img [i+0] [j+0];
            matrix_im_filtered_y[i][j] += imROI[0];
            matrix_im_filtered_x[i][j] += imROI[0];
            
            imROI[1] = padded_img [i+0] [j+1];
            matrix_im_filtered_y[i][j] += imROI[1] * 2;
            //matrix_im_filtered_x[i][j] += 0;
            
            imROI[2] = padded_img [i+0] [j+2];
            matrix_im_filtered_y[i][j] += imROI[2];
            matrix_im_filtered_x[i][j] += imROI[2] * (-1);
            
            imROI[3] = padded_img [i+1] [j+0];
            //matrix_im_filtered_y[i][j] += 0;
            matrix_im_filtered_x[i][j] += imROI[3] * 2;
            
            imROI[4] = padded_img [i+1] [j+1];
            //matrix_im_filtered_y[i][j] += 0;
            //matrix_im_filtered_x[i][j] += 0;
            
            imROI[5] = padded_img [i+1] [j+2];
            //matrix_im_filtered_y[i][j] += 0;
            matrix_im_filtered_x[i][j] += imROI[5] * (-2);
            
            imROI[6] = padded_img [i+2] [j+0];
            matrix_im_filtered_y[i][j] += imROI[6] * (-1);
            matrix_im_filtered_x[i][j] += imROI[6];
            
            imROI[7] = padded_img [i+2] [j+1];
            matrix_im_filtered_y[i][j] += imROI[7] * (-2);
            //matrix_im_filtered_x[i][j] += 0;
            
            imROI[8] = padded_img [i+2] [j+2];
            matrix_im_filtered_y[i][j] += imROI[8] * (-1);
            matrix_im_filtered_x[i][j] += imROI[8] * (-1);
            
            cout<<matrix_im_filtered_x[i][j] <<" ";
        }
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
        //case ADDR_WIDTH:
          //width = to_int(buf)+1;
          //break;
        //case ADDR_HEIGHT:
          //height = to_int(buf)+1;
          //break;
        case ADDR_CMD:
          start = to_int(buf);
          filter_image_t();
          break;
        default:
          pl.set_response_status( tlm::TLM_ADDRESS_ERROR_RESPONSE );
        }
      if (len != 3) pl.set_response_status( tlm::TLM_BURST_ERROR_RESPONSE );
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
      if (len != 3) pl.set_response_status( tlm::TLM_BURST_ERROR_RESPONSE );
      break;
    default:
      pl.set_response_status( tlm::TLM_COMMAND_ERROR_RESPONSE );
    }

    offset += sc_core::sc_time(10, sc_core::SC_NS);
}

num_t2 HW::read_bram(int addr){
    pl_t pl;
    unsigned char buf[3];
    pl.set_address(addr * 3); 
    pl.set_data_length(3);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_READ_COMMAND);
    pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    sc_core::sc_time offset = sc_core::SC_ZERO_TIME;
    bram_ctrl_socket->b_transport(pl, offset);
    return to_fixed(buf); 
}
