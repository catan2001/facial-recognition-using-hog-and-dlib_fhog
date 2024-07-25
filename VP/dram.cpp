#include "dram.hpp"
#include <iomanip>

DRAM::DRAM(sc_core::sc_module_name name) : sc_module(name) {
    dram_ctrl_socket.register_b_transport(this, &DRAM::b_transport);
    dmem.reserve(DMEM_SIZE);
    SC_REPORT_INFO("DRAM", "Constructed.");
}

DRAM::~DRAM() {
    SC_REPORT_INFO("DRAM", "Destroyed");
}

void DRAM::b_transport(pl_t &pl, sc_core::sc_time &offset) {
    tlm::tlm_command cmd = pl.get_command();
    sc_dt::uint64 addr = pl.get_address();
    unsigned int len = pl.get_data_length();
    unsigned char *buf = pl.get_data_ptr(); 

    switch(cmd) {
        case tlm::TLM_WRITE_COMMAND:
            dmem[addr] = to_fixed(buf);
            pl.set_response_status(tlm::TLM_OK_RESPONSE);
            break;
        case tlm::TLM_READ_COMMAND:
            to_uchar(buf, dmem[addr]);
            pl.set_response_status(tlm::TLM_OK_RESPONSE);
            break;
        default: 
            pl.set_response_status(tlm::TLM_COMMAND_ERROR_RESPONSE);    
    }

    offset += sc_core::sc_time(DELAY, sc_core::SC_NS);
}


