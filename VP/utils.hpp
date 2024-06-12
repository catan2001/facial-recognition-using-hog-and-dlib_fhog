#ifndef _UTILS_HPP_
#define _UTILS_HPP_

#include <systemc>
#include <string>
#include <iostream>
#include <string.h>
#include <bitset>
#include <math.h>
#include "def.hpp"

using namespace std;
using namespace sc_dt;

int to_int (unsigned char *);

void build_histogram(int rows, int cols, double *grad_mag, double *grad_angle, double *ori_histo);

void get_block_descriptor(int rows, int cols, double *ori_histo, double *ori_histo_normalized);

void extract_hog(int rows, int cols, int A, int B, double *im, double *hog);

#endif // _UTILS_HPP_
