#ifndef DRAM_HPP_
#define DRAM_HPP_

#include <systemc>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include "utils.hpp"

//TODO: define DRAM interface

#define DMEM_SIZE 1024*1024*1024 // 1GB DRAM

class DRAM : public sc_core::sc_module {
    public:
        DRAM(sc_core::sc_module_name name);
        ~DRAM();
        tlm_utils::simple_target_socket<DRAM> dram_socket_s1;
        tlm_utils::simple_target_socket<DRAM> dram_socket_s2; 
    protected:
        void b_transport(pl_t &, sc_core::sc_time &);
        std::vector<unsigned char> dmem;
};

#endif //DRAM_HPP_


