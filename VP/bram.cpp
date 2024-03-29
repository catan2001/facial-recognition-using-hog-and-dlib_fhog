#include "bram.hpp"


Bram::Bram(sc_core::sc_module_name name) : sc_module(name)
{
    mem.reserve(RESERVED_MEM);
    SC_REPORT_INFO("BRAM", "Constructed.");
}

Bram::~Bram()
{
    SC_REPORT_INFO("BRAM", "Destroyed.");
}

void Bram::b_transport(pl_t& pl, sc_core::sc_time& offset)
{
    sc_dt::uint64 addr = pl.get_address(); //adresa kojoj se pristupa
    tlm::tlm_command cmd = pl.get_command(); //odredjuje da li ce cita ili pise na odg adresu
    unsigned char* data = pl.get_data_ptr(); //pokazivac na podatke koji se upisuju ili gdje se smjestaju
    unsigned int len = pl.get_data_length(); //broj podataka za citanje/pisanje

    switch (cmd)
    {
    case tlm::TLM_WRITE_COMMAND:
        for (unsigned int i = 0; i < len; ++i)
        {
            mem[addr++] = data[i];
        }
        pl.set_response_status(tlm::TLM_OK_RESPONSE); 
        break;
    case tlm::TLM_READ_COMMAND:
        for (unsigned int i = 0; i < len; ++i)
        {
            data[i] = mem[addr++];
        }
        pl.set_response_status(tlm::TLM_OK_RESPONSE);
        break;
    default:
        pl.set_response_status(tlm::TLM_COMMAND_ERROR_RESPONSE);
    }

    offset += sc_core::sc_time(10, sc_core::SC_NS);
}
