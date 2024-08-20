#ifndef DRAM_HPP_
#define DRAM_HPP_

#include <systemc>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include "utils.hpp"

#define DMEM_SIZE 1024*1024 // 1/2GB DRAM

class DRAM : public sc_core::sc_module {
    public:
        DRAM(sc_core::sc_module_name name);
        ~DRAM();
        tlm_utils::simple_target_socket<DRAM> dram_ctrl_socket;
    protected:
        void b_transport(pl_t &, sc_core::sc_time &);
        u6_t read_transaction_cnt;
        u11_t read_row_cnt;
        std::vector<output_t> dmem;
};

#endif //DRAM_HPP_


