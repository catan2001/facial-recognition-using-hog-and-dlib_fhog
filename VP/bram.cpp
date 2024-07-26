#include "bram.hpp"

Bram::Bram(sc_core::sc_module_name name) : sc_module(name)
{
    bram_ctrl_socket.register_b_transport(this, &Bram::b_transport);

    mem.reserve(RESERVED_MEM);

    SC_REPORT_INFO("BRAM", "Constructed.");
}

Bram::~Bram()
{
    SC_REPORT_INFO("BRAM", "Destroyed.");
}

void Bram::b_transport(pl_t& pl, sc_core::sc_time& offset)
{
    sc_dt::uint64 addr = pl.get_address(); 
    tlm::tlm_command cmd = pl.get_command(); 
    unsigned char *data = pl.get_data_ptr(); 
    unsigned int len = pl.get_data_length();

    switch (cmd)
    {
    case tlm::TLM_WRITE_COMMAND:
            mem[addr] = to_fixed(data);
        pl.set_response_status(tlm::TLM_OK_RESPONSE); 
        break;
    case tlm::TLM_READ_COMMAND:
          to_uchar(data, mem[addr]);
        pl.set_response_status(tlm::TLM_OK_RESPONSE);
        break;
    default:
        pl.set_response_status(tlm::TLM_COMMAND_ERROR_RESPONSE);
    }
    offset += sc_core::sc_time(DELAY, sc_core::SC_NS);
}
