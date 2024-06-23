#include "hw.hpp"

HW::HW(sc_core::sc_module_name name)
    : sc_module(name)
    , offset(sc_core::SC_ZERO_TIME)
{
    interconnect_socket.register_b_transport(this, &HW::b_transport);
    SC_REPORT_INFO("Hard", "Constructed.");
}

HW::~HW()
{
    SC_REPORT_INFO("Hard", "Destroyed.");
}
//TODO: change for implementing in HW
void HW::filter_image_t(void){
  SC_REPORT_INFO("Hard","ja sam konj");
  array_t imROI(9, num_t(W, I, Q, O));
  matrix_t padded_img(ROWS+2, array_t(COLS+2, num_t(W,I,Q, O)));
  //test
    for(int i=0; i<ROWS+2; ++i){
      for(int j=0; j<COLS+2; ++j){
        read_bram(i*COLS+j,padded_img[i][j]);
        cout << "Padded image inside HW::filter: " << padded_img[i][j];
      }
      cout << endl;
    }
    /*
    for (int i=0; i<ROWS; ++i){ // prone to changes
        for (int j=0; j<COLS; ++j){
            for(int k=0; k<9; ++k){
                imROI[k] = padded_img [i+(int)(k/3)] [j+(k%3)];
                matrix_im_filtered_y[i][j] += imROI[k] * filter_y[k];
                matrix_im_filtered_x[i][j] += imROI[k] * filter_x[k];
            }
        }
    }
  */
}

void HW::b_transport(pl_t& pl, sc_core::sc_time& offset)
{
    sc_dt::uint64 addr = pl.get_address(); 
    tlm::tlm_command cmd = pl.get_command(); 
    unsigned char *data = pl.get_data_ptr(); 
    unsigned int len = pl.get_data_length();
    filter_image_t();
    /*switch(cmd)
    {
    case tlm::TLM_WRITE_COMMAND:
      switch(addr)
        {
        case ADDR_WIDTH:
          width = to_int(buf)+1;
          break;
        case ADDR_LOG2W:
          log2w = to_int(buf)+1;
          break;
        case ADDR_HEIGHT:
          height = to_int(buf)+1;
          break;
        case ADDR_LOG2H:
          log2h = to_int(buf)+1;
          break;
        case ADDR_CMD:
          start = to_int(buf);
          fft2(offset);
          break;
        default:
          pl.set_response_status( tlm::TLM_ADDRESS_ERROR_RESPONSE );
        }
      if (len != 4) pl.set_response_status( tlm::TLM_BURST_ERROR_RESPONSE );
      break;
    case tlm::TLM_READ_COMMAND:
      switch(addr)
        {
        case ADDR_STATUS:
          to_uchar(buf, ready);
          break;
        default:
          pl.set_response_status( tlm::TLM_ADDRESS_ERROR_RESPONSE );
        }
      if (len != 3) pl.set_response_status( tlm::TLM_BURST_ERROR_RESPONSE );
      break;
    default:
      pl.set_response_status( tlm::TLM_COMMAND_ERROR_RESPONSE );
    }*/

    offset += sc_core::sc_time(10, sc_core::SC_NS);
}

num_t HW::read_bram(int addr, char value){
    pl_t pl;
    unsigned char buf[3];
    pl.set_address((addr * 3) | BRAM_BASE_ADDR);
    pl.set_data_length(3);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_READ_COMMAND);
    pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    bram_socket->b_transport(pl, offset);
    
    return to_fixed(buf); 
}
