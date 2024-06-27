#ifndef DRAM_HPP_
#define DRAM_HPP_

#include <systemc>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include "utils.hpp"

//TODO: define DRAM interface

#define DMEM 1024*1024*512

class DRAM : public sc_core::sc_module {
    public:
        DRAM (sc_core::sc_module_name name) {
            FILE *fp = fopen("dram.txt", "w+");
            if(fp == NULL) {
                cout << "ERROR:<dram.hpp> could not open file!" << endl;
                return -1;
            }
            for(int i = 0; i < DMEM)
                fprintf(fp, "%d ", 0); 
            fclose(fp);
        };
        ~DRAM ();
        tlm_utils::simple_target_socket<DRAM> dram_socket_s1, dram_socket_s2, dram_socket_s3; // s1->PS , s2 && s3 -> PL
    protected:
        num_t2 dmem_val;
}

#endif //DRAM_HPP_


