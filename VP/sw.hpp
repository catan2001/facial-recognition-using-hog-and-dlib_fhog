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
	int num_thresholded;
        int num_faces;
	void process_img();
	void read_dram(sc_dt::uint64 addr, num_t2& val);
	void write_dram(sc_dt::uint64 addr, num_t2 val);
	int read_hard(sc_dt::uint64 addr);
	void write_hard(sc_dt::uint64 addr, int val);
	void mat_txt(const char * name_txt,  matrix_t * matrix, int rows, int cols);
	double mean_subtract(int len, double *array);
	double array_norm(int len, double *array); 
	double array_dot(int len, double *array1, double *array2);
	void sort(int x, int y, int z, double *array);
	void cast_to_fix(int rows, int cols, matrix_t& dest, orig_array_t& src);
        void find_max(int rows, int cols, double *matrix);
        double min(double num1, double num2);
        double max(double num1, double num2);
        double box_iou(double box1_x, double box1_y, double box2_x, double box2_y, double boxSize);
        void sort_bounded_boxes(int x, int y, int z, double *array);
	void get_gradient(int rows, int cols, double *im_dx, double *im_dy, double *grad_mag, double *grad_angle);
        void build_histogram(int rows, int cols, double *grad_mag, double *grad_angle, double *ori_histo);
        void get_block_descriptor(int rows, int cols, double *ori_histo, double *ori_histo_normalized);
        void extract_hog(int rows, int cols, double *im, double *hog);
        double *face_recognition(int img_h, int img_w, int box_h, int box_w, double *I_target, double *I_template);
        void face_recognition_range(double *I_target, int step); 
};

#endif // SOFT_HPP_
