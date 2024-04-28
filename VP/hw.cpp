#include "hw.hpp"

HW::HW(sc_core::sc_module_name name)
    : sc_module(name)
    , offset(sc_core::SC_ZERO_TIME)
{
    interconnect_socket.register_b_transport(this, &HW::b_transport);
    SC_REPORT_INFO("Hard", "Constructed.");
}

HW::~HW()
{
    SC_REPORT_INFO("Hard", "Destroyed.");
}

void HW::b_transport(pl_t& pl, sc_core::sc_time& offset)
{

}

