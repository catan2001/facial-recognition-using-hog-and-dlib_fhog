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
{
    matrix_picture_file.close();
    SC_REPORT_INFO("Soft", "Destroyed.");
}

void SW::process_img(){
    
    num_t write_value, read_value;

    matrix_picture_file >> img_height >> img_width;

    for (int i = 0; i < img_height; ++i) {
        for (int j = 0; j < img_height; ++j) {
            
        
        }
    }


}


void SW::read_bram(sc_dt::uint64 addr, num_t& val)
{
    pl_t pl;
    unsigned char buf[8];
    pl.set_address((addr * 4) | BRAM_BASE_ADDR);
    pl.set_data_length(8);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_READ_COMMAND);
    pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    interconnect_socket->b_transport(pl, offset);

}

void SW::write_bram(sc_dt::uint64 addr, num_t val)
{
    pl_t pl;
    unsigned char buf[8];
    pl.set_address((addr * 4) | BRAM_BASE_ADDR);
    pl.set_data_length(8);
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
    //jos
}

