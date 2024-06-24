#include "hw.hpp"
//SC_HAS_PROCESS(HW);

HW::HW(sc_core::sc_module_name name)
    : sc_module(name), 
    offset(sc_core::SC_ZERO_TIME),
    start(0),
    ready(1)
{
    interconnect_socket.register_b_transport(this, &HW::b_transport);
    SC_REPORT_INFO("Hard", "Constructed.");
    //SC_THREAD(filter_image_t);
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
  SC_REPORT_INFO("Hard","ja sam konj2");
    for(int i=0; i<ROWS+2; ++i){
      for(int j=0; j<COLS+2; ++j){
      SC_REPORT_INFO("Hard","ja sam konj3");
        padded_img[i][j] = read_bram(i*(COLS+2)+j);
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
          to_uchar(buf,pom);
          cout<<pom<<" ";
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

num_t HW::read_bram(int addr){
    pl_t pl;
    unsigned char buf[3];
    cout<<"konj4"<<endl;
    //addr =& BASE
    pl.set_address((addr * 3)); //  | BRAM_BASE_ADDR
    pl.set_data_length(3);
    pl.set_data_ptr(buf);
    cout<<"konj5"<<endl;
    pl.set_command(tlm::TLM_READ_COMMAND);
    pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    cout<<"konj6"<<endl;
    bram_socket->b_transport(pl, offset);
    cout<<"konj7"<<endl;
    return to_fixed(buf); 
}
