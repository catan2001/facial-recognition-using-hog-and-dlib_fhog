#include "sw.hpp"

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
    num_t img[ROWS][COLS];
    num_t img_min, img_max;
    num_t filtered_img_x[ROWS][COLS], filtered_img_y[ROWS][COLS];

    //write image into bram

    for (int i = 0; i < img_height; ++i) {
        for (int j = 0; j < img_width; ++j) {
            matrix_picture_file >> write_value;
            write_bram(i * img_width + j, write_value);
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
            if (img_min > img[i][j]) img_min = img[i][j];
            if (img_max < img[i][j]) img_max = img[i][j];
        }
    }

    for (int i = 0; i < img_height; ++i) {
        for (int j = 0; j < img_width; ++j) {
            img[i][j] = (img[i][j] - img_min) / img_max;
        }
    }

    //filter image in hw
    write_hard(ADDR_CMD, 1);

    for (int i = 0; i < img_height; ++i) { //zavisi kako cemo upisati filtriranu sliku u mem
        for (int j = 0; j < img_width; ++j)
        {
            read_bram(i * img_width + j, filtered_img_x[i][j]);
            //dodaj i za y

        }
    }

    num_t grad_mag[ROWS][COLS];
    num_t grad_angle[ROWS][COLS];
    get_gradient(filtered_img_x, filtered_img_y, grad_mag, grad_angle);

    num_t ori_histo[ROWS / CELL_SIZE][COLS / CELL_SIZE][nBINS];
    build_histogram(grad_mag, grad_angle, ori_histo);

    num_t ori_histo_normalized[HEIGHT - (BLOCK_SIZE - 1)][WIDTH - (BLOCK_SIZE - 1)][nBINS * (BLOCK_SIZE*BLOCK_SIZE)];
    get_block_descriptor(ori_histo, ori_histo_normalized);

    num_t hog[(HEIGHT - (BLOCK_SIZE - 1)) * (WIDTH - (BLOCK_SIZE - 1)) * (6 * BLOCK_SIZE * BLOCK_SIZE)];

    int l = 0;
    for (int i = 0; i < HEIGHT - (BLOCK_SIZE - 1); ++i) {
        for (int j = 0; j < WIDTH - (BLOCK_SIZE - 1); ++j) {
            for (int k = 0; k < nBINS * BLOCK_SIZE * BLOCK_SIZE; ++k) {
                hog[l++] = ori_histo_normalized[i][j][k];
            }
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

