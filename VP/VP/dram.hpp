#ifndef DRAM_HPP_
#define DRAM_HPP_

#include <systemc>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include "utils.hpp"

//TODO: define DRAM interface

#define DMEM_SIZE 1024*1024 // 1/2GB DRAM

class DRAM : public sc_core::sc_module {
    public:
        DRAM(sc_core::sc_module_name name);
        ~DRAM();
        tlm_utils::simple_target_socket<DRAM> dram_ctrl_socket;
    protected:
        void b_transport(pl_t &, sc_core::sc_time &);
        std::vector<num_t2> dmem;
};

#endif //DRAM_HPP_

