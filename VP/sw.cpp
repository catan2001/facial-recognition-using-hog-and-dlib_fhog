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
{   matrix_picture_file.close();
    SC_REPORT_INFO("Soft", "Destroyed.");
}

void SW::process_img(){

    int rows = 150;
    int cols = 150;
    int height = rows/CELL_SIZE;
    int width = cols/CELL_SIZE;
    
    
    double *grad_mag = new double[rows * cols];
    double *grad_angle = new double[rows * cols];
    double *ori_histo = new double[(int)height * (int)width * nBINS];
    double *ori_histo_normalized = new double[(height-(BLOCK_SIZE-1)) * (width-(BLOCK_SIZE-1)) * nBINS*(BLOCK_SIZE*BLOCK_SIZE)];  
    double *hog = new double[((int)height-1) * ((int)width-1) * (nBINS*BLOCK_SIZE*BLOCK_SIZE)];
  
  
  
    FILE * grad_mag_f = fopen("grad_mag_norm.txt", "rb");
    double tmp_mag;
      for (int i = 0; i < ROWS; ++i){
          for (int j = 0; j < COLS; ++j){
              fscanf(grad_mag_f, "%lf", &tmp_mag);
              grad_mag[i * COLS + j] = tmp_mag;
          }
      }
    fclose(grad_mag_f);
    
    FILE * grad_angle_f = fopen("grad_angle_norm.txt", "rb");
    double tmp_angle;
      for (int i = 0; i < ROWS; ++i){
          for (int j = 0; j < COLS; ++j){
              fscanf(grad_angle_f, "%lf", &tmp_angle);
              grad_angle[i * COLS + j] = tmp_angle;
          }
      }
    fclose(grad_angle_f);
  
    
    build_histogram(rows, cols, &grad_mag[0], &grad_angle[0], &ori_histo[0]);
    get_block_descriptor(rows, cols, &ori_histo[0], &ori_histo_normalized[0]);
    
    int HOG_LEN = (height-1) * (width-1) * (nBINS*BLOCK_SIZE*BLOCK_SIZE);
    int i = nBINS*BLOCK_SIZE*BLOCK_SIZE*(width-1);

    for(int l = 0; l < HOG_LEN; ++l)
        hog[l] = ori_histo_normalized[(int)(l/i)*(width-(BLOCK_SIZE-1))*nBINS*(BLOCK_SIZE*BLOCK_SIZE) + (int)((l/24)%(width-1))*nBINS*(BLOCK_SIZE*BLOCK_SIZE) + l%24]; 
    
    delete [] grad_mag;
    delete [] grad_angle;
    delete [] ori_histo;
    delete [] ori_histo_normalized;
    delete [] hog;

 //matrix_picture_file >> img_height >> img_width;
    //num_t write_value, read_value;
    //num_t img[ROWS][COLS];
    //num_t img_min, img_max;
    //num_t filtered_img_x[ROWS][COLS], filtered_img_y[ROWS][COLS];

    //write image into bram

    //for (int i = 0; i < img_height; ++i) {
        //for (int j = 0; j < img_width; ++j) {
            //matrix_picture_file >> write_value;
            //write_bram(i * img_width + j, write_value);
        //}
    //}

    //write dimesions of img into hard
    // 
    //write_hard(ADDR_WIDTH, img_width);
    //write_hard(ADDR_HEIGHT, img_height);

    //img_min = img[0][0] / 255.0;
    //img_max = img[0][0] / 255.0;

    //for (int i = 0; i < img_height; ++i) {
        //for (int j = 0; j < img_width; ++j) {
            //img[i][j] = img[i][j] / 255.0;
            //if (img_min > img[i][j]) img_min = img[i][j];
            //if (img_max < img[i][j]) img_max = img[i][j];
        //}
    //}

    /*for (int i = 0; i < img_height; ++i) {
        for (int j = 0; j < img_width; ++j) {
            img[i][j] = (img[i][j] - img_min) / img_max;
        }
    }*/

    //filter image in hw
    //write_hard(ADDR_CMD, 1);

    /*for (int i = 0; i < img_height; ++i) { //zavisi kako cemo upisati filtriranu sliku u mem
        for (int j = 0; j < img_width; ++j)
        {
            read_bram(i * img_width + j, filtered_img_x[i][j]);
            //dodaj i za y

        }
    }*/


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
    unsigned char buf[4];
    pl.set_address((addr * 4) | BRAM_BASE_ADDR);
    pl.set_data_length(4);
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

