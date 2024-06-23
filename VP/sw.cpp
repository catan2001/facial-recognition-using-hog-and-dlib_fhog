#include "sw.hpp"

SC_HAS_PROCESS(SW);

SW::SW(sc_core::sc_module_name name)
    : sc_module(name)
    , offset(sc_core::SC_ZERO_TIME)
{
    //matrix_picture_file.open("matrix_picture_file.txt");
    //if (!matrix_picture_file.is_open())
        //SC_REPORT_ERROR("Soft", "Cannot open file.");

    SC_THREAD(process_img);
    SC_REPORT_INFO("Soft", "Constructed.");
}

SW::~SW()
{   //matrix_picture_file.close();
    SC_REPORT_INFO("Soft", "Destroyed.");
}

void SW::process_img(){

    int rows = 150;
    int cols = 150;
    int height = rows/CELL_SIZE;
    int width = cols/CELL_SIZE;
    
    double *gray = new double[rows*cols];
    
    FILE * gray_f = fopen("gray.txt", "rb");
    double tmp_gray;
      for (int i = 0; i < ROWS; ++i){
          for (int j = 0; j < COLS; ++j){
              fscanf(gray_f, "%lf", &tmp_gray);
              gray[i * COLS + j] = tmp_gray;
          }
      }
    fclose(gray_f);
    
    double im_min = *(gray + 0)/255.00000000;
    double im_max = *(gray + 0)/255.00000000;
    
    double *im_c = new double[rows*cols];
    
    for(int i = 0; i < rows; ++i){
      for(int j = 0; j < cols; ++j){
          *(im_c + i*cols + j) = *(gray + i*cols +j);
          *(im_c + i*cols + j) = *(im_c + i*cols + j)/255.0; // converting to double format
          if(im_min > *(im_c + i*cols + j)) im_min = *(im_c + i*cols + j); // find min im
          if(im_max < *(im_c + i*cols + j)) im_max = *(im_c + i*cols + j); // find max im
      }
    }
    
    delete [] gray;

    for(int i = 0; i < rows; ++i){
        for(int j = 0; j < cols; ++j){
            *(im_c + i*cols + j) = (*(im_c + i*cols + j) - im_min) / im_max; // Normalize image to [0, 1]
        }
    }
    
    orig_array_t orig_gray(rows, vector<double>(cols));
    
    for (int i=0; i<rows; ++i){
        for (int j=0; j<cols; ++j){
            orig_gray[i][j] = *(im_c + i*cols + j);
        }
    }

    delete [] im_c;
    
    matrix_t matrix_gray(rows, array_t(cols, num_t(W, I, Q, O)));
    matrix_t matrix_im_filtered_y(rows, array_t(cols, num_t(W,I,Q,O)));
    matrix_t matrix_im_filtered_x(rows, array_t(cols, num_t(W,I,Q,O)));
    matrix_t padded_img(rows+2, array_t(cols+2, num_t(W,I,Q, O)));
    cast_to_fix(rows, cols, matrix_gray, orig_gray, W, I);

    
    //pad the image on the outer edges with zeros:
    for(int i=0; i<rows+2; ++i) {
        padded_img[i][0]=0;
        padded_img[i][cols+1]=0;
    }

    for(int i=0; i<cols+2; ++i) {
        padded_img[0][i]=0;
        padded_img[rows+1][i]=0;
    }
    
    for (int i=0; i<rows; ++i){
        for (int j=0; j<cols; ++j){
            matrix_im_filtered_y[i][j] = 0;
            matrix_im_filtered_x[i][j] = 0;
            padded_img[i+1][j+1]=matrix_gray[i][j];
        }
    }
    
    for(int i=0; i<rows+2; ++i){
      for(int j=0; j<cols+2; ++j){
        write_bram(i*cols+j,padded_img[i][j]);
      }
    }
   int k;
   while(k < 1000000000) k++;
     
}


void SW::read_bram(sc_dt::uint64 addr, num_t& val)
{
    pl_t pl;
    unsigned char buf[4];
    pl.set_address((addr * 4) | BRAM_BASE_ADDR);
    pl.set_data_length(4);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_READ_COMMAND);
    pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    interconnect_socket->b_transport(pl, offset);

}

void SW::write_bram(sc_dt::uint64 addr, num_t val)
{
    pl_t pl;
    unsigned char buf[3];
    to_uchar(buf, val);
    pl.set_address((addr * 3) | BRAM_BASE_ADDR);
    pl.set_data_length(3);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_WRITE_COMMAND);
    pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    interconnect_socket->b_transport(pl, offset);
}

int SW::read_hard(sc_dt::uint64 addr)
{
    pl_t pl;
    unsigned char buf[4];
    pl.set_address(addr | HARD_BASE_ADDR);
    pl.set_data_length(4);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_READ_COMMAND);
    pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    sc_core::sc_time offset = sc_core::SC_ZERO_TIME;
    interconnect_socket->b_transport(pl, offset);
    
    return to_int(buf);
}

void SW::write_hard(sc_dt::uint64 addr, int val)
{
    pl_t pl;
    unsigned char buf[4];
    pl.set_address(addr | HARD_BASE_ADDR);
    pl.set_data_length(4);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_WRITE_COMMAND);
    pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    interconnect_socket->b_transport(pl, offset);
}

