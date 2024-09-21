#ifndef DRAM_CTRL_HPP_
#define DRAM_CTRL_HPP_

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <tlm_utils/simple_initiator_socket.h>
#include "def.hpp"
#include "utils.hpp"

class DramCtrl: public sc_core::sc_module
{
    public:
        DramCtrl(sc_core::sc_module_name name);
        ~DramCtrl();
        tlm_utils::simple_target_socket<DramCtrl> interconnect_socket;
        tlm_utils::simple_initiator_socket<DramCtrl> ip_core_x_socket;
        tlm_utils::simple_initiator_socket<DramCtrl> ip_core_y_socket;
        tlm_utils::simple_initiator_socket<DramCtrl> dram_in1_socket;
	tlm_utils::simple_initiator_socket<DramCtrl> dram_in2_socket;
        tlm_utils::simple_initiator_socket<DramCtrl> dram_out1_socket;
	tlm_utils::simple_initiator_socket<DramCtrl> dram_out2_socket;
        tlm_utils::simple_initiator_socket<DramCtrl> ip_core_data1_socket;
	tlm_utils::simple_initiator_socket<DramCtrl> ip_core_data2_socket;

    protected:
        void b_transport (pl_t &, sc_core::sc_time &);
        pl_t pl_dram;
	pl_t pl_core_in1, pl_core_in2, pl_core_out1, pl_core_out2;
	pl_t pl_dram_in1, pl_dram_in2, pl_dram_out1, pl_dram_out2;

	sc_dt::uint64 actual_addr_read_dx, actual_addr_read_dy, actual_addr_write;
	sc_dt::uint64 dx_addr_in, dx_addr_out, dy_addr_in, dy_addr_out;

	unsigned char buf_bram_in1[DATA_LEN_IN_BYTES], buf_bram_in2[DATA_LEN_IN_BYTES];
	unsigned char buf_dram_in1[LEN_IN_BYTES], buf_dram_in2[LEN_IN_BYTES];
	unsigned char buf_bram_out1[DATA_LEN_IN_BYTES], buf_bram_out2[DATA_LEN_IN_BYTES];
	unsigned char buf_dram_out1[LEN_IN_BYTES], buf_dram_out2[LEN_IN_BYTES];
	

        //iterators for writing img to DRAM:
	int cols = 0;
	int rows = 0;
        int i_img = 0;
        int j_img = 0;
        //iterators for reading dx_img from DRAM:
        int i_dx = 0;
        int j_dx = 0;
        //iterators for reading dy_img from DRAM:
        int i_dy = 0;
        int j_dy = 0;
        //iterators for writing dx and dy to DRAM from IP_CORE:
        int rows_out_dx = 0;
        int cols_out_dx = 0;
        int rows_out_dy = 0;
        int cols_out_dy = 0;
         //iterators for reading img from DRAM:
        int rows_in_dx = 0;
        int cols_in_dx = 0;
        int rows_in_dy = 0;
        int cols_in_dy = 0;

};

#endif // DRAM_CTRL_HPP_

