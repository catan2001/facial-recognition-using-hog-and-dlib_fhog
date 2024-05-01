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

void build_histogram(num_t grad_mag[ROWS][COLS], num_t grad_angle[ROWS][COLS], num_t ori_histo[ROWS/CELL_SIZE][COLS/ CELL_SIZE][nBINS]);

void get_gradient(num_t filtered_img_x[ROWS][COLS], num_t filtered_img_y[ROWS][COLS], num_t grad_mag[ROWS][COLS], num_t grad_angle[ROWS][COLS]);

void get_block_descriptor(num_t ori_histo[ROWS/CELL_SIZE][COLS/CELL_SIZE][nBINS], num_t ori_histo_normalized[HEIGHT- (BLOCK_SIZE-1)][WIDTH-(BLOCK_SIZE-1)][nBINS*(BLOCK_SIZE*BLOCK_SIZE)]);

#endif // _UTILS_HPP_
