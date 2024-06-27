#include <dram.hpp>

DRAM::DRAM(sc_core::sc_module_name name) : sc_module(name) {
    dram_socket_s1.register_b_transport(this, &DRAM::b_transport);
    dram_socket_s2.register_b_transport(this, &DRAM::b_transport);    
    dram_socket_s3.register_b_transport(this, &DRAM::b_transport);
    //dmem.reserve()
    //
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
    
    FILE *fp = fopen("dram.txt", "r+");
    if(fp == NULL) { 
        cout << "ERROR: <dram.cpp> could not open file!" << endl;
        return -1;
    }

    switch(cmd) {
    case tlm::TLM_READ_COMMAND:
        for(unsigned char i = 0; i < len; ++i) {

        }
            
    }
}


