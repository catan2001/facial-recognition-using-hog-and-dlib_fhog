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

static const int DATA_WIDTH = 24;
static const int FIXED_POINT_WIDTH = 3;
static const int CHAR_LEN = 8;
static const int CHARS_AMOUNT = DATA_WIDTH / CHAR_LEN;

void to_char (unsigned char *, string);
void to_uchar (unsigned char *buf, num_t d);
double to_fixed (unsigned char *buf);

int to_int (unsigned char *);

void cast_to_fix(int rows, int cols, matrix_t& dest, orig_array_t& src, int width, int integer);

void build_histogram(int rows, int cols, double *grad_mag, double *grad_angle, double *ori_histo);

void get_block_descriptor(int rows, int cols, double *ori_histo, double *ori_histo_normalized);

void extract_hog(int rows, int cols, int A, int B, double *im, double *hog);

#endif // _UTILS_HPP_
