#include "sw.hpp"
#include "def.hpp"

SC_HAS_PROCESS(SW);

SW::SW(sc_core::sc_module_name name)
    : sc_module(name)
    , offset(sc_core::SC_ZERO_TIME)
{
    matrix_picture_file.open("matrix_picture_file.txt");
    if (!matrix_picture_file.is_open())
        SC_REPORT_ERROR("Soft", "Cannot open file.");

    //SC_THREAD(convolve);
    SC_REPORT_INFO("Soft", "Constructed.");
}

SW::~SW()
{   matrix_picture_file.close();
    SC_REPORT_INFO("Soft", "Destroyed.");
}

void SW::process_img(){

    matrix_picture_file >> img_height >> img_width;
    num_t write_value, read_value;
    num_t img[MAX_SIZE][MAX_SIZE];
    num_t img_min, img_max;

    //write image into bram

    for (int i = 0; i < img_height; ++i) {
        for (int j = 0; j < img_width; ++j) {
            matrix_picture_file >> write_value;
            write_bram(i*img_width+j, write_value);
        }
    }

    //write dimesions of img into hard
    // 
    write_hard(ADDR_WIDTH, img_width);
    write_hard(ADDR_HEIGHT, img_height);

    img_min = img[0][0] / 255.0;
    img_max = img[0][0] / 255.0;

    for (int i = 0; i < img_height; ++i) {
        for (int j = 0; j < img_width; ++j) {
            img[i][j] = img[i][j] / 255.0;
            if(img_min > img[i][j]) img_min = img[i][j];
            if (img_max < img[i][j]) img_max = img[i][j];
        }
    }

    for (int i = 0; i < img_height; ++i) {
        for (int j = 0; j < img_width; ++j) {
            img[i][j] = (img[i][j] - img_min) / img_max;
        }
    }


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
    //jos
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

