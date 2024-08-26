#include "dram.hpp"
#include <iomanip>

DRAM::DRAM(sc_core::sc_module_name name) : 
    sc_module(name),
    read_transaction_cnt(0) 

{
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

            read_transaction_cnt++;
            read_row_cnt++;
            //during one clk we will transfer 2*(4 pixels 16 bits) = 2 lines by 64 bits
            if(read_transaction_cnt==8){
                offset += sc_core::sc_time(DELAY, sc_core::SC_NS);
                read_transaction_cnt = 0;
            }

            if(read_row_cnt==COLS+2){
            //every time we call a new burst transaction there will be an init lag 100-110ns
                offset += sc_core::sc_time(11*DELAY, sc_core::SC_NS);
                read_row_cnt = 0;
            }

            pl.set_response_status(tlm::TLM_OK_RESPONSE);
            break;
        default: 
            pl.set_response_status(tlm::TLM_COMMAND_ERROR_RESPONSE);    
    }

}


