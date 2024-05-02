#define SC_INCLUDE_FX

#include <systemc>
#include <stdio.h>
#include <iostream>
#include <cmath>
#include <string.h>
#include <math.h>
#include <deque>
#include <iomanip>

using namespace sc_core;
using namespace std;
using namespace sc_dt;

#define BLOCK_SIZE 2
#define CELL_SIZE 8
#define nBINS 6
#define PI 3.14159265358979323846
#define HIST_SIZE nBINS*BLOCK_SIZE*BLOCK_SIZE
#define Q sc_dt::SC_RND
#define O sc_dt::SC_SAT
#define ROWS 150
#define COLS 150
#define HEIGHT (ROWS/CELL_SIZE)
#define WIDTH (COLS/CELL_SIZE)

const float filter_x[9] = {1,0,-1, 2,0,-2, 1,0,-1};  //Dx = filter_x conv D
const float filter_y[9] = {1,2,1, 0,0,0, -1,-2,-1};    //Dy = filter_y conv D

typedef sc_dt::sc_fix num_t;
typedef std::deque<num_t> array_t;
typedef std::deque<array_t> matrix_t;
typedef std::vector<std::vector<float>> orig_array_t;

//int ROWS = 150;
//int COLS = 150;

//typedef sc_dt::sc_fixed <64, 32, sc_dt::SC_RND, sc_dt::SC_SAT> num_t;
//assume the size of our picture is fixed and already determined
//getting the amplitude and phase matrix of the filtered image

void cast_to_fix(matrix_t& dest, orig_array_t& src, int W, int I) {
    for(int i = 0; i != ROWS; ++i) {
        for (int j = 0; j != COLS; ++j) {
            num_t d(W, I);
            d = src[i][j];
            if(d.overflow_flag())
                std::cout << "Overflow!" << endl;
            dest[i][j] = d;
        }
    }
}

void get_gradient(int rows, int cols, float *im_dx, float *im_dy, float *grad_mag, float *grad_angle){

    float dX, dY;
    
    for(int i=0; i<rows; ++i){
        for(int j=0; j<cols; ++j){
            dX = *(im_dx + i*cols + j);
            dY = *(im_dy + i*cols + j);

            //determining the amplitude matrix:
            *(grad_mag + i*cols + j) = sqrt(pow(dX,2)+pow(dY,2));

            //determining the phase matrix:
            if(fabs(dX)>0.00001){
                *(grad_angle + i*cols + j) = atan(dY/dX) + PI/2;
            }else if(dY<0 && dX<0){
                *(grad_angle + i*cols + j) = 0;
            }else{
                *(grad_angle + i*cols + j) = PI;
            }
        }
    }
}

void build_histogram(int rows, int cols, float *grad_mag, float *grad_angle, float *ori_histo){

    //define REGION of INTEREST, our new chunks
    int cell_pow2 = CELL_SIZE*CELL_SIZE;
    float magROI[cell_pow2], angleROI[cell_pow2];
    float angleInDeg;

    for(int i = CELL_SIZE; i <= rows; i+=CELL_SIZE){
        for(int j = CELL_SIZE; j <= cols; j+=CELL_SIZE){
            float hist[nBINS]={0, 0, 0, 0, 0, 0};

            for(int k=0; k<cell_pow2; ++k){
               // magROI[k]=grad_mag[i-CELL_SIZE+(int)(k/CELL_SIZE)][j-CELL_SIZE+(k%CELL_SIZE)];
                magROI[k]= *(grad_mag + (i-CELL_SIZE+(int)(k/CELL_SIZE))*cols + j-CELL_SIZE+(k%CELL_SIZE));
                //angleROI[k]=grad_angle[i-CELL_SIZE+(int)(k/CELL_SIZE)][j-CELL_SIZE+(k%CELL_SIZE)];
                angleROI[k]= *(grad_angle + (i-CELL_SIZE+(int)(k/CELL_SIZE))*cols + j-CELL_SIZE+(k%CELL_SIZE));
                angleInDeg = angleROI[k]*(180.0 / PI);

                if(angleInDeg >=0.0 && angleInDeg < 30.0){
                    hist[0] += magROI[k];
                }else if(angleInDeg >=30.0 && angleInDeg < 60.0){
                    hist[1] += magROI[k];
                }else if(angleInDeg >=60.0 && angleInDeg < 90.0){
                    hist[2] += magROI[k];
                }else if(angleInDeg >=90.0 && angleInDeg < 120.0){
                    hist[3] += magROI[k];
                }else if(angleInDeg >=120.0 && angleInDeg < 150.0){
                    hist[4] += magROI[k];
                }else{
                    hist[5] += magROI[k];
                }  
            }

            //ori_histo[int(x_corner/cell_size),int(y_corner/cell_size),:] = hist
            for(int k=0; k<nBINS; ++k) //ori_histo[(int)(i-CELL_SIZE)/CELL_SIZE][(int)(j-CELL_SIZE)/CELL_SIZE][k] = hist[k];
                                       *(ori_histo + ((int)(i-CELL_SIZE)/CELL_SIZE) * nBINS * (int)(cols/CELL_SIZE) + ((int)(j-CELL_SIZE)/CELL_SIZE)*nBINS + k) = hist[k];
        }
    }
}

void get_block_descriptor(int rows, int cols, float *ori_histo, float *ori_histo_normalized){
    int height = rows/CELL_SIZE;
    int width = cols/CELL_SIZE;
    for(int i = BLOCK_SIZE; i <= height; i+=BLOCK_SIZE){
        for(int j = BLOCK_SIZE; j <= width; j+=BLOCK_SIZE){
            float concatednatedHist[HIST_SIZE];
            float concatednatedHist2[HIST_SIZE];
            float histNorm = 0.0;

            for(int k=0; k<HIST_SIZE; ++k) {
                concatednatedHist[k] = *(ori_histo + (i-BLOCK_SIZE+(int)k/12)*nBINS*((int)cols/CELL_SIZE) + (j-BLOCK_SIZE+((int)k/6)%2)*nBINS + (k%6));
                concatednatedHist2[k]=concatednatedHist[k]*concatednatedHist[k];
                histNorm+=concatednatedHist2[k];
            }

            histNorm+=0.001;
            histNorm = sqrt(histNorm);

            for(int k = 0; k < HIST_SIZE; ++k) *(ori_histo_normalized + (i-BLOCK_SIZE)*((cols/CELL_SIZE)-(BLOCK_SIZE-1))*nBINS*BLOCK_SIZE*BLOCK_SIZE 
                                                + (j-BLOCK_SIZE)*nBINS*BLOCK_SIZE*BLOCK_SIZE + k )= concatednatedHist[k] / histNorm;
        }
    }
}
//changed so it accepts both filtered by x and y filter
void extract_hog(int rows, int cols, int W, int I, float *im, float *hog) { 
    
    float im_min = *(im)/255.0;
    float im_max = *(im)/255.0;
    
    for(int i = 0; i < rows; ++i){
        for(int j = 0; j < cols; ++j){
            *(im + i*cols + j) = *(im + i*cols + j)/255.0; // converting to double format
            if(im_min > *(im + i*cols + j)) im_min = *(im + i*cols + j); // find min im
            if(im_max < *(im + i*cols + j)) im_max = *(im + i*cols + j); // find max im
        }
    }

    for(int i = 0; i < rows; ++i){
        for(int j = 0; j < cols; ++j){
            *(im + i*cols + j) = (*(im + i*cols + j) - im_min) / im_max; // Normalize image to [0, 1]
        }
    }
    
    // Hardware part of the code:
    orig_array_t orig_gray(rows, vector<float>(cols));

    for (int i=0; i<rows; ++i){
        for (int j=0; j<cols; ++j){
            orig_gray[i][j] = *(im + i*cols + j);
        }
    }

    matrix_t matrix_gray(rows, array_t(cols, num_t(W, I, Q, O)));
    matrix_t matrix_im_filtered_y(rows, array_t(cols, num_t(W,I,Q,O)));
    matrix_t matrix_im_filtered_x(rows, array_t(cols, num_t(W,I,Q,O)));
    matrix_t padded_img(rows+2, array_t(cols+2, num_t(W,I,Q, O)));
    cast_to_fix(matrix_gray, orig_gray, W, I);
            
    //pad the image on the outer edges with zeros:
    for(int i=0; i<ROWS+2; ++i) {
        padded_img[i][0]=0;
        padded_img[i][cols+1]=0;
    }

    for(int i=0; i<cols+2; ++i) {
        padded_img[0][i]=0;
        padded_img[rows+1][i]=0;
    }
    
    for (int i=0; i<rows; ++i){
        for (int j=0; j<cols; ++j){
            matrix_im_filtered_y[i][j] = 0;
            matrix_im_filtered_x[i][j] = 0;
            padded_img[i+1][j+1]=matrix_gray[i][j];
        }
    }

    //filter image:
    array_t imROI(9, num_t(W,I, Q, O));
    
    float dx[rows][cols]; //
    float dy[rows][cols]; //
    for (int i=0; i<rows; ++i){
        for (int j=0; j<cols; ++j){
            for(int k=0; k<9; ++k){
                imROI[k]=padded_img[i+(int)(k/3)][j+(k%3)];
                matrix_im_filtered_y[i][j]+=imROI[k]*filter_y[k];
                matrix_im_filtered_x[i][j]+=imROI[k]*filter_x[k];
            }
            dx[i][j] = matrix_im_filtered_x[i][j];
            dy[i][j] = matrix_im_filtered_y[i][j];
            //cout << std::setprecision(50);
            //cout << "dx: "<< dy[i][j] << endl;
            //cout << "matrix_im_filtered_x: " << matrix_im_filtered_x[i][j] << endl;
        }
    }


    int height = rows/CELL_SIZE;
    int width = cols/CELL_SIZE;
    float grad_mag[rows][cols];
    float grad_angle[rows][cols];
    get_gradient(rows, cols, &dx[0][0], &dy[0][0], &grad_mag[0][0], &grad_angle[0][0]);
    
    float ori_histo[(int)rows/CELL_SIZE][(int)cols/CELL_SIZE][nBINS]; // TODO: check to replace ROWS/CELL_SIZE with HEIGHT
    build_histogram(rows, cols, &grad_mag[0][0], &grad_angle[0][0], &ori_histo[0][0][0]);
    
    // TODO: Make makro to replace underneath
    float ori_histo_normalized[height-(BLOCK_SIZE-1)][width-(BLOCK_SIZE-1)][nBINS*(BLOCK_SIZE*BLOCK_SIZE)];        
    get_block_descriptor(rows, cols, &ori_histo[0][0][0], &ori_histo_normalized[0][0][0]);
    
    int HOG_LEN = (height-1) * (width-1) * (nBINS*BLOCK_SIZE*BLOCK_SIZE);
    int i = nBINS*BLOCK_SIZE*BLOCK_SIZE*(width-1);

    for(int l=0; l < HOG_LEN; ++l){
        hog[l] = ori_histo_normalized[(int)(l/i)][(int)((l/24)%(width-1))][l%24];
    }  
}

int sc_main(int, char*[]) {
    // TODO: implement filters to be also bit width dependant 
    FILE * rach;
    rach = fopen("gray.txt", "rb");

    float gray[ROWS][COLS];
    float a;

    int rows = ROWS;
    int cols = COLS;

    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){
            fscanf(rach, "%f", &a);
            gray[i][j] = a;
        }
    }
    fclose(rach);

    int W = 64;
    const int I = 3;
    
    // loop to find minimal bitwidth
    do {
        
        cout << "Width W: " << W << endl;
        cout << "Fixed point: " << I << endl;
        
        int height = rows/CELL_SIZE;
        int width = cols/CELL_SIZE;
        float hog[(height-(BLOCK_SIZE-1)) * (width-(BLOCK_SIZE-1)) * (nBINS*BLOCK_SIZE*BLOCK_SIZE)];
        extract_hog(rows, cols, W, I, &gray[0][0], &hog[0]);
        
        for (int i=0; i<(height-(BLOCK_SIZE-1)) * (width-(BLOCK_SIZE-1)) * (6*BLOCK_SIZE*BLOCK_SIZE); ++i){
            //cout << hog[i] << endl;             
        }
        cout << std::setprecision(20);
        cout << "hog[0]: " << hog[0] << endl;
        W--;
    }
    while (W > 20);
  
    sc_start();
    return 0;
}
