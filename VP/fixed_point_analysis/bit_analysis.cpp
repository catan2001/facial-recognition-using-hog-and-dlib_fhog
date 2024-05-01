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
//typedef std::vector<std::vector<num_t>> array_num_t;
typedef std::deque<num_t> array_t;
typedef std::deque<array_t> matrix_t;
typedef std::vector<std::vector<float>> orig_array_t;

//typedef sc_dt::sc_fixed <64, 32, sc_dt::SC_RND, sc_dt::SC_SAT> num_t;
//assume the size of our picture is fixed and already determined
//getting the amplitude and phase matrix of the filtered image
void get_gradient(float im_dx[ROWS][COLS], float im_dy[ROWS][COLS], float grad_mag[ROWS][COLS], float grad_angle[ROWS][COLS]){

    float dX, dY;
    
    for(int i=0; i<ROWS; ++i){
        for(int j=0; j<COLS; ++j){
            dX = im_dx[i][j];
            dY = im_dy[i][j];

            //determining the amplitude matrix:
            grad_mag[i][j] = sqrt(pow(dX,2)+pow(dY,2));


            //determining the phase matrix:
            if(fabs(dX)>0.00001){
                grad_angle[i][j] = atan(dY/dX) + PI/2;
            }else if(dY<0 && dX<0){
                grad_angle[i][j] = 0;
            }else{
                grad_angle[i][j] = PI;
            }
        }
    }
}

void build_histogram(float grad_mag[ROWS][COLS], float grad_angle[ROWS][COLS], float ori_histo[(int)ROWS/CELL_SIZE][(int)COLS/CELL_SIZE][nBINS]){

    //define REGION of INTEREST, our new chunks
    int cell_pow2 = CELL_SIZE*CELL_SIZE;
    float magROI[cell_pow2], angleROI[cell_pow2];

    float angleInDeg;

    for(int i = CELL_SIZE; i <= ROWS; i+=CELL_SIZE){
        for(int j = CELL_SIZE; j <= COLS; j+=CELL_SIZE){
            float hist[nBINS]={0, 0, 0, 0, 0, 0};

            for(int k=0; k<cell_pow2; ++k){
                magROI[k]=grad_mag[i-CELL_SIZE+(int)(k/CELL_SIZE)][j-CELL_SIZE+(k%CELL_SIZE)];
                angleROI[k]=grad_angle[i-CELL_SIZE+(int)(k/CELL_SIZE)][j-CELL_SIZE+(k%CELL_SIZE)];
           
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
            for(int k=0; k<nBINS; ++k) ori_histo[(int)(i-CELL_SIZE)/CELL_SIZE][(int)(j-CELL_SIZE)/CELL_SIZE][k] = hist[k];

        }
    }
}

void get_block_descriptor(float ori_histo[ROWS/CELL_SIZE][COLS/CELL_SIZE][nBINS], float ori_histo_normalized[HEIGHT-(BLOCK_SIZE-1)][WIDTH-(BLOCK_SIZE-1)][nBINS*(BLOCK_SIZE*BLOCK_SIZE)]){

    for(int i = BLOCK_SIZE; i <= HEIGHT; i+=BLOCK_SIZE){
        for(int j = BLOCK_SIZE; j <= WIDTH; j+=BLOCK_SIZE){
            float concatednatedHist[HIST_SIZE];
            float concatednatedHist2[HIST_SIZE];
            float histNorm = 0.0;

            for(int k=0; k<HIST_SIZE; ++k) {
                concatednatedHist[k]=ori_histo[i-BLOCK_SIZE+(int)k/12][j-BLOCK_SIZE+((int)k/6)%2][(k%6)];
                //printf("concatednatedHIST: %.7f \n", concatednatedHist[k]);
                concatednatedHist2[k]=concatednatedHist[k]*concatednatedHist[k];
                //printf("kvadrirano: %.7f \n", concatednatedHist2[k]);
                histNorm+=concatednatedHist2[k];
            }
            //printf("suma prije 0.001: %d %d %lf \n", (i-BLOCK_SIZE), (j-BLOCK_SIZE), histNorm);
            histNorm+=0.001;
            //printf("suma: %d %d %f \n", (i-BLOCK_SIZE), (j-BLOCK_SIZE), histNorm);
            histNorm = sqrt(histNorm);

            //printf("korijen: %d %d %f \n", (i-BLOCK_SIZE), (j-BLOCK_SIZE), histNorm);
            //break;

            for(int k = 0; k < HIST_SIZE; ++k) ori_histo_normalized[i-BLOCK_SIZE][j-BLOCK_SIZE][k] = concatednatedHist[k] / histNorm;
        }
    }
}
//changed so it accepts both filtered by x and y filter
void extract_hog(float dx[ROWS][COLS], float dy[ROWS][COLS], float hog[(HEIGHT-(BLOCK_SIZE-1)) * (WIDTH-(BLOCK_SIZE-1)) * (nBINS*BLOCK_SIZE*BLOCK_SIZE)]) { 

    float grad_mag[ROWS][COLS];
    float grad_angle[ROWS][COLS];
    get_gradient(dx, dy, grad_mag, grad_angle);
    
    float ori_histo[(int)ROWS/CELL_SIZE][(int)COLS/CELL_SIZE][nBINS]; // TODO: check to replace ROWS/CELL_SIZE with HEIGHT
    build_histogram(grad_mag, grad_angle, ori_histo);
    
    // TODO: Make makro to replace underneath
    float ori_histo_normalized[HEIGHT-(BLOCK_SIZE-1)][WIDTH-(BLOCK_SIZE-1)][nBINS*(BLOCK_SIZE*BLOCK_SIZE)];        
    get_block_descriptor(ori_histo, ori_histo_normalized);
    
    int HOG_LEN = (HEIGHT-1) * (WIDTH-1) * (nBINS*BLOCK_SIZE*BLOCK_SIZE);
    int i = nBINS*BLOCK_SIZE*BLOCK_SIZE*(WIDTH-1);

    for(int l=0; l < HOG_LEN; ++l){
        hog[l] = ori_histo_normalized[(int)(l/i)][(int)((l/24)%(WIDTH-1))][l%24];
    }
  
}

void cast_to_fix(matrix_t& dest, orig_array_t& src, int W, int I) {
    for(int i = 0; i != ROWS; ++i) {
        for (int j = 0; j != COLS; ++j) {
            num_t d(W, I);
            d = src[i][j];
            if(d.overflow_flag())
                std::cout << "Overflow!" << endl;
            //dest[i][j] = dest[i][j](W,I);
            dest[i][j] = d;
            //cout << "Casted: " << dest[i][j] << endl;
        }
    }
}

int sc_main(int, char*[]) {
    // TODO: implement filters to be also bit width dependant 
    FILE * rach;
    rach = fopen("gray_norm.txt", "rb");

    float gray[ROWS][COLS];
    orig_array_t orig_gray(ROWS, vector<float>(COLS));
    float a;

    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){
            fscanf(rach, "%f", &a);
            orig_gray[i][j] = a;
        }
    }
    fclose(rach);
    
    int i = 1;
    int W = 64;
    const int I = 3;
    
    // loop to find minimal bitwidth
    do {
        
        cout << "Width W: " << W << endl;
        cout << "Fixed point: " << I << endl;

        matrix_t matrix_gray(ROWS, array_t(COLS, num_t(W,I, Q, O)));
        matrix_t matrix_im_filtered_y(ROWS, array_t(COLS, num_t(W,I,Q,O)));
        matrix_t matrix_im_filtered_x(ROWS, array_t(COLS, num_t(W,I,Q,O)));
        matrix_t padded_img(ROWS+2, array_t(COLS+2, num_t(W,I,Q, O)));
        cast_to_fix(matrix_gray, orig_gray, W, I);
                
        //pad the image on the outer edges with zeros:
        for(int i=0; i<ROWS+2; ++i) {
            padded_img[i][0]=0;
            padded_img[i][COLS+1]=0;
        }

        for(int i=0; i<COLS+2; ++i) {
            padded_img[0][i]=0;
            padded_img[ROWS+1][i]=0;
        }
        
        for (int i=0; i<ROWS; ++i){
            for (int j=0; j<COLS; ++j){
                //fill filtered image with zeros:
                matrix_im_filtered_y[i][j] = 0;
                matrix_im_filtered_x[i][j] = 0;
                //putting the original image within the padded one:
                padded_img[i+1][j+1]=matrix_gray[i][j];
            }
        }

        //filter image:
        array_t imROI(9, num_t(W,I, Q, O));
        
        float dx[ROWS][COLS]; //
        float dy[ROWS][COLS]; //
        float hog[(HEIGHT-(BLOCK_SIZE-1)) * (WIDTH-(BLOCK_SIZE-1)) * (nBINS*BLOCK_SIZE*BLOCK_SIZE)];
        for (int i=0; i<ROWS; ++i){
            for (int j=0; j<COLS; ++j){
                //np.dot(img[i:i+3][j:j+3].flatten(), filter)
                for(int k=0; k<9; ++k){
                    imROI[k]=padded_img[i+(int)(k/3)][j+(k%3)];
                    matrix_im_filtered_y[i][j]+=imROI[k]*filter_y[k];
                    matrix_im_filtered_x[i][j]+=imROI[k]*filter_x[k];
                }
                //cout << matrix_im_filtered_y[i][j] << endl;
                dx[i][j] = matrix_im_filtered_x[i][j];
                dy[i][j] = matrix_im_filtered_y[i][j];
                //cout << std::setprecision(50);
                //cout << "dx: "<< dy[i][j] << endl;
                //cout << "matrix_im_filtered_x: " << matrix_im_filtered_x[i][j] << endl;
            }
        }
        extract_hog(dx, dy, hog);
        
        for (int i=0; i<(HEIGHT-(BLOCK_SIZE-1)) * (WIDTH-(BLOCK_SIZE-1)) * (6*BLOCK_SIZE*BLOCK_SIZE); ++i){
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
