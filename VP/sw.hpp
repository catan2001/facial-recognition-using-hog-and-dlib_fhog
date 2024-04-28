#ifndef SW_HPP_
#define SW_HPP_

#include <iostream>
#include <fstream>
#include "systemc.h"
#include <tlm_utils/simple_initiator_socket.h>
#include "def.hpp"


class SW : public sc_core::sc_module
{
public:
	SW(sc_core::sc_module_name name);
	~SW();
	tlm_utils::simple_initiator_socket<SW> interconnect_socket;

protected:
	pl_t pl;
	sc_core::sc_time offset;
	std::ifstream matrix_picture_file;
	int img_width, img_height;
	void process_img();
	void read_bram(sc_dt::uint64 addr, num_t& val);
	void write_bram(sc_dt::uint64 addr, num_t val);
	int read_hard(sc_dt::uint64 addr);
	void write_hard(sc_dt::uint64 addr, int val);
};

#endif // SOFT_HPP_