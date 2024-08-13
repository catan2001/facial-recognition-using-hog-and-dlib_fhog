#ifndef SW_HPP_
#define SW_HPP_

#include <iostream>
#include <fstream>
#include <systemc>
#include <tlm_utils/simple_initiator_socket.h>
#include "def.hpp"
#include "utils.hpp"
#include "hw.hpp"

class SW : public sc_core::sc_module
{
public:
	SW(sc_core::sc_module_name name);
	~SW();
	tlm_utils::simple_initiator_socket<SW> interconnect_socket;

protected:
	pl_t pl;
	sc_core::sc_time offset;
	int img_width, img_height;

	void process_img(void);
	void read_dram(sc_dt::uint64 addr, output_t& val, sc_core::sc_time &offset);
	void write_dram(sc_dt::uint64 addr, output_t val, sc_core::sc_time &offset);
	int read_hard(sc_dt::uint64 addr, sc_core::sc_time &offset);
	void write_hard(sc_dt::uint64 addr, int val, sc_core::sc_time &offset);
	
	void get_gradient(int rows, int cols, double *im_dx, double *im_dy, double *grad_mag, double *grad_angle);
	void build_histogram(int rows, int cols, double *grad_mag, double *grad_angle, double *ori_histo);
	void get_block_descriptor(int rows, int cols, double *ori_histo, double *ori_histo_normalized);
	void extract_hog(int rows, int cols, double *im, double *hog);
	double *face_recognition(int img_h, int img_w, int box_h, int box_w, double *I_target, double *I_template, int *num_thresholded);
	void face_recognition_range(double *I_target, int step); 
};

#endif // SOFT_HPP_
