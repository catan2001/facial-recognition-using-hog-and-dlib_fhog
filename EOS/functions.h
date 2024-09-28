#include <stdio.h>
#include <iostream>
#include <cmath>
#include <string.h>
#include <math.h>
#include <deque>
#include <iomanip>
#include <chrono>

using namespace std;


#define BLOCK_SIZE 2
#define CELL_SIZE 8
#define CELL_POW (CELL_SIZE*CELL_SIZE)
#define nBINS 6
#define PI 3.14159265358979323846
#define HIST_SIZE nBINS*BLOCK_SIZE*BLOCK_SIZE
#define ROWS 150
#define COLS 150
#define TROWS 100
#define TCOLS 100
#define THRESHOLD 0.6 // TODO: CHANGE AS NEEDED!
#define SUPPRESSION 0.5 // TODO: CHANGE AS NEEDED!
#define HEIGHT (ROWS/CELL_SIZE)
#define WIDTH (COLS/CELL_SIZE)

#define SAHE1 0
#define SAHE2 4
#define SAHE3 8

#define DMA0
#define DMA1

void write_hard(unsigned char addr, int val);
int read_hard(unsigned char addr);

double mean_subtract(int len, double *array);
double array_norm(int len, double *array); 
double array_dot(int len, double *array1, double *array2);
void sort(int x, int y, int z, double *array);
void find_max(int rows, int cols, double *matrix);
double min(double num1, double num2);
double max(double num1, double num2);
double box_iou(double box1_x, double box1_y, double box2_x, double box2_y, double boxSize);
void get_gradient(int rows, int cols, double *im_dx, double *im_dy, double *grad_mag, double *grad_angle);
void build_histogram(int rows, int cols, double *grad_mag, double *grad_angle, double *ori_histo);
void get_block_descriptor(int rows, int cols, double *ori_histo, double *ori_histo_normalized);
void extract_hog(int rows, int cols, double *im, double *hog, double* time_filter, double* time_get_gradient, double* time_build_histogram, double* time_block_descriptor);
double *face_recognition(int img_h, int img_w, int box_h, int box_w, double *I_target, double *I_template, double* time_extract_hog, double* time_filter, double* time_get_gradient, double* time_build_histogram, double* time_block_descriptor);
void face_recognition_range(double *I_target, int step, int LOWER_BOUNDARY, int UPPER_BOUNDARY, double* time_face_rec, double* time_extract_hog, double* time_filter, double* time_get_gradient, double* time_build_histogram, double* time_block_descriptor); 