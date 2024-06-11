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
#define CELL_POW (CELL_SIZE*CELL_SIZE)
#define nBINS 6
#define PI 3.14159265358979323846
#define HIST_SIZE nBINS*BLOCK_SIZE*BLOCK_SIZE
#define Q sc_dt::SC_RND
#define O sc_dt::SC_SAT
#define ROWS 150
#define COLS 150
#define TROWS 100
#define TCOLS 100
#define UPPER_BOUNDARY ROWS > COLS ? ROWS : COLS
#define LOWER_BOUNDARY 50
#define THRESHOLD 0.6 // TODO: CHANGE AS NEEDED!
#define SUPPRESSION 0.5 // TODO: CHANGE AS NEEDED!
#define HEIGHT (ROWS/CELL_SIZE)
#define WIDTH (COLS/CELL_SIZE)

const double filter_x[9] = {1,0,-1, 2,0,-2, 1,0,-1};  //Dx = filter_x conv D
const double filter_y[9] = {1,2,1, 0,0,0, -1,-2,-1};    //Dy = filter_y conv D

int num_thresholded = 0;
int num_faces = 0;

typedef sc_dt::sc_fix_fast num_t;
typedef std::deque<num_t> array_t;
typedef std::deque<array_t> matrix_t;
typedef std::vector<std::vector<double>> orig_array_t;

double mean_subtract(int len, double *array);

double array_norm(int len, double *array); 

double array_dot(int len, double *array1, double *array2);

void sort(int x, int y, int z, double *array);

void cast_to_fix(int rows, int cols, matrix_t& dest, orig_array_t& src, int W, int I);

void find_max(int rows, int cols, double *matrix);

double min(double num1, double num2);

double max(double num1, double num2);

double box_iou(double box1_x, double box1_y, double box2_x, double box2_y, double boxSize);

void get_gradient(int rows, int cols, double *im_dx, double *im_dy, double *grad_mag, double *grad_angle);

void build_histogram(int rows, int cols, double *grad_mag, double *grad_angle, double *ori_histo);

void get_block_descriptor(int rows, int cols, double *ori_histo, double *ori_histo_normalized);

void extract_hog(int rows, int cols, int W, int I, double *im, double *hog);

double *face_recognition(int img_h, int img_w, int box_h, int box_w, int W, int I, double *I_target, double *I_template);

void face_recognition_range(int W, int I, double *I_target, int step); 

int sc_main(int, char*[]) {
    // TODO: implement filters to be also bit width dependant 

    int W = 23;
    const int I = 3;
    
    #ifdef DEBUG
        cout << endl << "        NOTE: DEBUG preprocessor directive is on!" << endl << endl;
    #else
        cout << endl << "        NOTE: Compiled program without DEBUG!" << endl << "        To use it, compile with -DDEBUG" << endl << endl;
    #endif 

    // loop to find minimal bitwidth
    do {
        
        cout << "Width W: " << W << endl;
        cout << "Fixed point: " << I << endl;
        
        FILE * rach;
        rach = fopen("template/gray.txt", "rb");
        if(rach == NULL) {
            cout << "ERROR! could not open file!" << endl;
            return 101;
        }

        double *gray = new double[ROWS * COLS];
        double val;

        for (int i = 0; i < ROWS; ++i){
            for (int j = 0; j < COLS; ++j){
                fscanf(rach, "%lf", &val);
                gray[i * COLS + j] = val;
            }
        }
        fclose(rach);
        face_recognition_range(W, I, &gray[0], 10);

        delete [] gray; // deallocates whole array in memory
    
        W -= 2;
    }
    while (W > 8);
  
    sc_start();
    return 0;
}

void write_txt(double* found_faces, int len, char *name_txt){
	
	FILE *fp;
	
  	fp = fopen(name_txt, "wb");

    	for(int i=0; i<len; ++i){
	       	fprintf(fp, "x: %.0lf y: %.0lf score: %.4lf \n", found_faces[i*3], found_faces[3*i+1], found_faces[3*i+2]);
    		printf("x: %.2lf y: %.2lf score: %.4lf \n", found_faces[i*3], found_faces[3*i+1], found_faces[3*i+2]);
	}
	fclose(fp);

}

double mean_subtract(int len, double *array) {
    double mean = 0;

    for(int i = 0; i < len; ++i) {
        mean += *(array + i);
    }
    return (mean/len);
}

double array_norm(int len, double *array) {
    double norm = 0;

    for(int i = 0; i < len; ++i)
        norm += ((*(array + i)) * (*(array + i)));
    return sqrt(norm);
}

double array_dot(int len, double *array1, double *array2) {
    double dot = 0;

    for(int i = 0; i < len; ++i){ 
        dot += (*(array1 + i)) * (*(array2 + i));
	}
    return dot;
}

void sort_bounded_boxes(int x, int y, int z, double *array) {
    double tmp[3] = {0};

    #ifdef DEBUG
        cout << "array is being sorted..." << endl;
    #endif

    for(int i = 0; i < x; ++i){
        for(int j = 0; j < y; ++j){
            for(int ii = 0; ii < x; ++ii)
                for(int jj = 0; jj < y; ++jj) {
                    if(*(array + i*y*z + j*z + 2) > *(array + ii*y*z + jj*z + 2)) {
                        tmp[0] = *(array + ii*y*z + jj*z + 0);
                        tmp[1] = *(array + ii*y*z + jj*z + 1);
                        tmp[2] = *(array + ii*y*z + jj*z + 2);

                        *(array + ii*y*z + jj*z + 0) = *(array + i*y*z + j*z + 0);
                        *(array + ii*y*z + jj*z + 1) = *(array + i*y*z + j*z + 1);
                        *(array + ii*y*z + jj*z + 2) = *(array + i*y*z + j*z + 2);
                        
                        *(array + i*y*z + j*z + 0) = tmp[0];
                        *(array + i*y*z + j*z + 1) = tmp[1];
                        *(array + i*y*z + j*z + 2) = tmp[2];
                   }
                }
        }
    }

    #ifdef DEBUG
        cout << "array is sorted..." << endl;
        for(int i = x-1; i >= 0; --i){
            for(int j = y-1; j >= 0; --j){
                cout << "x: " << *(array + i*y*z + j*z + 0);
                cout << " y: " << *(array + i*y*z + j*z + 1);
                cout << " score: " << *(array + i*y*z + j*z + 2);
                cout << endl;
            }
            cout << endl;
        }
        cout << endl;
    #endif
   
}

double min(double num1, double num2) {
    return (num1 < num2 ? num1 : num2);
}

double max(double num1, double num2) {
    return (num1 > num2 ? num1 : num2);
}
double box_iou(double box1_x, double box1_y, double box2_x, double box2_y, double boxSize) {
    double sumOfAreas = 2*(boxSize*boxSize);
    double box_1[4] = {box1_x, box1_y, box1_x+boxSize, box1_y+boxSize}; 
    double box_2[4] = {box2_x, box2_y, box2_x+boxSize, box2_y+boxSize};
    double intersectionArea = ((min(box_1[2], box_2[2]) - max(box_1[0], box_2[0])) * (min(box_1[3], box_2[3]) - max(box_1[1], box_2[1]))); 

    return (intersectionArea / (sumOfAreas - intersectionArea)); 
}

void cast_to_fix(int rows, int cols, matrix_t& dest, orig_array_t& src, int W, int I) {
    for(int i = 0; i != rows; ++i) {
        for (int j = 0; j != cols; ++j) {
            num_t d(W, I);
            d = src[i][j];
            if(d.overflow_flag())
                std::cout << "Overflow!" << endl;
            dest[i][j] = d;
        }
    }
}

void find_max(int rows, int cols, double *matrix) {
    // TODO: implement faster algorithm
    double tmp_max = *matrix;
    int row, col;

    for(int i = 0; i < rows; ++i)
        for(int j = 0; j < cols; ++j) {
            if(*(matrix + i*cols + j) >= tmp_max) {
                tmp_max = *(matrix+i*cols + j);
                row = i;
                col = j;
            }
        }
     cout << "max: "<< tmp_max << endl;
     cout << "x = " << row *3 << " y= " << col*3 << endl;
}

void get_gradient(int rows, int cols, double *im_dx, double *im_dy, double *grad_mag, double *grad_angle){

    double dX, dY;
    
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


void get_gradient_t(int rows, int cols, int W, int I, matrix_t& dx, matrix_t& dy, matrix_t& grad_mag_t, matrix_t& grad_angle_t, double *grad_mag, double *grad_angle){

    num_t dX(W, I, Q, O);
    num_t dY(W, I, Q, O);
    
    num_t phase_const(20, I, Q, O);
    num_t pi_const(14, I, Q, O);
    phase_const = 0.00001;
    pi_const = PI;
    //cout << "phase_const: "<< phase_const << endl;

    for(int i=0; i<rows; ++i){
        for(int j=0; j<cols; ++j){
            dX = dx[i][j];
            dY = dy[i][j];
            
            //determining the amplitude matrix:
            grad_mag_t[i][j] = sqrt(pow(dX,2)+pow(dY,2));

            //determining the phase matrix:
            if(fabs(dX)>phase_const){
                grad_angle_t[i][j] = atan(dY/dX) + pi_const/2;
            }else if(dY<0 && dX<0){
                grad_angle_t[i][j] = 0;
            }else{
                grad_angle_t[i][j] = pi_const;
            }
	    
//	    *(grad_mag + i*cols + j) = grad_mag_t[i][j];
//	    *(grad_angle + i*cols + j) = grad_angle_t[i][j];
        }
    }



}

void build_histogram(int rows, int cols, double *grad_mag, double *grad_angle, double *ori_histo){

    double magROI[CELL_POW], angleROI[CELL_POW];
    double angleInDeg;
    for(int i = CELL_SIZE; i <= rows; i+=CELL_SIZE){
        for(int j = CELL_SIZE; j <= cols; j+=CELL_SIZE){
            double hist[nBINS]={0, 0, 0, 0, 0, 0};

            for(int k = 0; k < CELL_POW; ++k){
                //magROI[k]=grad_mag[i-CELL_SIZE+(int)(k/CELL_SIZE)][j-CELL_SIZE+(k%CELL_SIZE)];
                magROI[k]= *(grad_mag + (i-CELL_SIZE+(int)(k/CELL_SIZE))*cols + j-CELL_SIZE+(k%CELL_SIZE));
                if(magROI[k] != magROI[k]) cout << "NAN! -> " << k << " = " << magROI[k] << endl;

                //angleROI[k]=grad_angle[i-CELL_SIZE+(int)(k/CELL_SIZE)][j-CELL_SIZE+(k%CELL_SIZE)];
                angleROI[k]= *(grad_angle + (i-CELL_SIZE+(int)(k/CELL_SIZE))*cols + j-CELL_SIZE+(k%CELL_SIZE));
                angleInDeg = angleROI[k]*(180.0 / PI);
                if(angleInDeg != angleInDeg) cout << "NAN angleInDeg!" << endl;
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

            for(int k=0; k<nBINS; ++k) //ori_histo[(int)(i-CELL_SIZE)/CELL_SIZE][(int)(j-CELL_SIZE)/CELL_SIZE][k] = hist[k]; 
                                       *(ori_histo + ((int)(i-CELL_SIZE)/CELL_SIZE) * nBINS * (int)(cols/CELL_SIZE) + ((int)(j-CELL_SIZE)/CELL_SIZE)*nBINS + k) = hist[k]; 

        }
    } 
}


void get_block_descriptor(int rows, int cols, double *ori_histo, double *ori_histo_normalized){
    int height = rows/CELL_SIZE;
    int width = cols/CELL_SIZE;
    
    for(int i = 0; i < ((rows/CELL_SIZE-(BLOCK_SIZE-1)) * (cols/CELL_SIZE-(BLOCK_SIZE-1)) * nBINS*(BLOCK_SIZE*BLOCK_SIZE)); ++i)
        ori_histo_normalized[i] = 0;

    for(int i = BLOCK_SIZE; i <= height; i+=BLOCK_SIZE){
        for(int j = BLOCK_SIZE; j <= width; j+=BLOCK_SIZE){
            double concatednatedHist[HIST_SIZE];
            double concatednatedHist2[HIST_SIZE];
            double histNorm = 0.0;

            for(int k=0; k<HIST_SIZE; ++k) {
                concatednatedHist[k] = *(ori_histo + (i-BLOCK_SIZE+(int)k/12)*nBINS*((int)cols/CELL_SIZE) + (j-BLOCK_SIZE+((int)k/6)%2)*nBINS + (k%6));
                concatednatedHist2[k]=concatednatedHist[k]*concatednatedHist[k];
                histNorm+=concatednatedHist2[k];
            }
           
            histNorm+=0.001;
            histNorm = sqrt(histNorm);
            
            #ifdef DEBUG
            if(histNorm != histNorm) cout << "NAN hist Norm" << endl;
            #endif

            for(int k = 0; k < HIST_SIZE; ++k) *(ori_histo_normalized + (i-BLOCK_SIZE)*((cols/CELL_SIZE)-(BLOCK_SIZE-1))*nBINS*BLOCK_SIZE*BLOCK_SIZE 
                                               + (j-BLOCK_SIZE)*nBINS*BLOCK_SIZE*BLOCK_SIZE + k )= concatednatedHist[k] / histNorm;  
        }
    }
}
//changed so it accepts both filtered by x and y filter
void extract_hog(int rows, int cols, int W, int I, double *im, double *hog) { 
    //TODO: check why it fails again to have correct values
    double im_min = *(im + 0)/255.00000000;
    double im_max = *(im + 0)/255.00000000;
    
    double *im_c = new double[rows*cols];

    for(int i = 0; i < rows; ++i){
        for(int j = 0; j < cols; ++j){
            *(im_c + i*cols + j) = *(im + i*cols +j);
            *(im_c + i*cols + j) = *(im_c + i*cols + j)/255.0; // converting to double format
            if(im_min > *(im_c + i*cols + j)) im_min = *(im_c + i*cols + j); // find min im
            if(im_max < *(im_c + i*cols + j)) im_max = *(im_c + i*cols + j); // find max im
        }
    }

    for(int i = 0; i < rows; ++i){
        for(int j = 0; j < cols; ++j){
            *(im_c + i*cols + j) = (*(im_c + i*cols + j) - im_min) / im_max; // Normalize image to [0, 1]
        }
    }
    // Hardware part of the code:
    orig_array_t orig_gray(rows, vector<double>(cols));
    
    for (int i=0; i<rows; ++i){
        for (int j=0; j<cols; ++j){
            orig_gray[i][j] = *(im_c + i*cols + j);
        }
    }

    delete [] im_c;
    
    matrix_t matrix_gray(rows, array_t(cols, num_t(W, I, Q, O)));
    matrix_t matrix_im_filtered_y(rows, array_t(cols, num_t(W,I,Q,O)));
    matrix_t matrix_im_filtered_x(rows, array_t(cols, num_t(W,I,Q,O)));
    matrix_t padded_img(rows+2, array_t(cols+2, num_t(W,I,Q, O)));
    cast_to_fix(rows, cols, matrix_gray, orig_gray, W, I);

   /* double padded_img[rows+2][cols+2];
    double matrix_im_filtered_y[rows][cols];
    double matrix_im_filtered_x[rows][cols];
   */

    
    //pad the image on the outer edges with zeros:
    for(int i=0; i<rows+2; ++i) {
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
	    //padded_img[i+1][j+1]=orig_gray[i][j];

        }
    }

    //filter image:
    array_t imROI(9, num_t(W, I, Q, O));
    //double imROI[9] = {0};

    matrix_t dx(rows, array_t(cols, num_t(W, I, Q, O)));
    matrix_t dy(rows, array_t(cols, num_t(W, I, Q, O)));
    //double *dx = new double[rows * cols]; 
    //double *dy = new double[rows * cols]; 
    for (int i=0; i<rows; ++i){
        for (int j=0; j<cols; ++j){
            for(int k=0; k<9; ++k){
                imROI[k] = padded_img [i+(int)(k/3)] [j+(k%3)];
                matrix_im_filtered_y[i][j] += imROI[k] * filter_y[k];
                matrix_im_filtered_x[i][j] += imROI[k] * filter_x[k];
            }
            dx[i][j] = matrix_im_filtered_x[i][j];
            dy[i][j] = matrix_im_filtered_y[i][j];
        }
    }

   /* num_t dX(W, I, Q, O);
    num_t dY(W, I, Q, O);

    matrix_t grad_mag_t(rows, array_t(cols, num_t(W, I, Q, O)));
    matrix_t grad_angle_t(rows, array_t(cols, num_t(W, I, Q, O)));
    
    double *grad_mag = new double[rows * cols];
    double *grad_angle = new double[rows * cols];
    
    num_t phase_const(W,I,Q,O);
    num_t pi_const(W,I,Q,O);
    phase_const = 0.00001;
    pi_const = PI;
    //cout << "phase_const: "<< phase_const << endl;

    for(int i=0; i<rows; ++i){
        for(int j=0; j<cols; ++j){
            dX = dx[i][j];
            dY = dy[i][j];
            
            //determining the amplitude matrix:
            grad_mag_t[i][j] = sqrt(pow(dX,2)+pow(dY,2));

            //determining the phase matrix:
            if(fabs(dX)>phase_const){
                grad_angle_t[i][j] = atan(dY/dX) + pi_const/2;
            }else if(dY<0 && dX<0){
                grad_angle_t[i][j] = 0;
            }else{
                grad_angle_t[i][j] = pi_const;
            }

	        *(grad_mag + i*cols + j) = grad_mag_t[i][j];
	        *(grad_angle + i*cols + j) = grad_angle_t[i][j];
        }
    }*/


    int height = rows/CELL_SIZE;
    int width = cols/CELL_SIZE;
    
    matrix_t grad_mag_t(rows, array_t(cols, num_t(W, I, Q, O)));
    matrix_t grad_angle_t(rows, array_t(cols, num_t(W, I, Q, O)));
    
    double *grad_mag = new double[rows * cols];
    double *grad_angle = new double[rows * cols];
    
    get_gradient_t(rows, cols, W, I, dx, dy, grad_mag_t, grad_angle_t, &grad_mag[0], &grad_angle[0]);

   for(int i=0; i<rows; ++i){
   	for(int j=0; j<cols; ++j){
		*(grad_mag + i*cols + j) = grad_mag_t[i][j];
	        *(grad_angle + i*cols + j) = grad_angle_t[i][j];	
	}
   }


    double *ori_histo = new double[(int)height * (int)width * nBINS];

    build_histogram(rows, cols, &grad_mag[0], &grad_angle[0], &ori_histo[0]);
    
    // TODO: Make makro to replace underneath
    double *ori_histo_normalized = new double[(height-(BLOCK_SIZE-1)) * (width-(BLOCK_SIZE-1)) * nBINS*(BLOCK_SIZE*BLOCK_SIZE)];   

    get_block_descriptor(rows, cols, &ori_histo[0], &ori_histo_normalized[0]);
    
    int HOG_LEN = (height-1) * (width-1) * (nBINS*BLOCK_SIZE*BLOCK_SIZE);
    int i = nBINS*BLOCK_SIZE*BLOCK_SIZE*(width-1);

    for(int l = 0; l < HOG_LEN; ++l){
        hog[l] = ori_histo_normalized[(int)(l/i)*(width-(BLOCK_SIZE-1))*nBINS*(BLOCK_SIZE*BLOCK_SIZE) + (int)((l/24)%(width-1))*nBINS*(BLOCK_SIZE*BLOCK_SIZE) + l%24];
        #ifdef DEBUG
            if(hog[l] != hog[l]) cout << "hogl NAN" << endl;
        #endif
        //printf("%lf ", hog[l]);    
    }

    // deallocate allocated
    //delete [] dx;
    //delete [] dy;
    delete [] grad_mag;
    delete [] grad_angle;
    delete [] ori_histo;
    delete [] ori_histo_normalized;
}

double *face_recognition(int img_h, int img_w, int box_h, int box_w, int W, int I, double *I_target, double *I_template) {
    
    int hog_len = ((int)(box_h/8) - 1)*((int)(box_w/8)-1)*24;    
    double *template_HOG = new double[((int)(box_h/8)-1)*((int)(box_w/8)-1)*24];

    extract_hog(box_h, box_w, W, I, &(I_template[0]), template_HOG);

    double template_HOG_norm = 0;
    double template_HOG_mean = 0;
    
    template_HOG_mean = mean_subtract(hog_len, &template_HOG[0]);

    for(int l = 0; l < hog_len; ++l) 
        template_HOG[l] -= template_HOG_mean;
    
    template_HOG_norm = array_norm(hog_len, &template_HOG[0]); 
    
    #ifdef DEBUG
        cout << "Template Mean: " << template_HOG_mean << endl;  
        cout << "Template Norm: " << template_HOG_norm << endl;   
    #endif
   
    int x = 0;
    int y = 0;
        
    #ifdef DEBUG
        cout << "Calculating HOG for parts of image: " << endl;
    #endif

    double *img_window = new double[box_h * box_w];
    double score = 0;
    double img_HOG_norm = 0;
    double img_HOG_mean = 0;              
    double *all_scores = new double[((img_h-box_h)/3 + 1) * ((img_w-box_w)/3 + 1)];
    double *all_bounding_boxes = new double[((img_h-box_h)/3 + 1) * ((img_w-box_w)/3 + 1) * 3]; // 3 for: x, y and score  
    
    for (x = x+box_h; x <= img_h; x+=3){
        for(y = y+box_w; y <= img_w; y+=3) {
            int ll = 0;
            for(int i = 0; i < box_h; ++i) {
                for(int j = 0; j < box_w; ++j) {
                    img_window[i * box_w + j] = *(I_target +(i+x-box_h)*img_w + (j+y-box_w));
		        }
	        }
            
            double *img_HOG = new double[((int)(box_h/8) - 1)*((int)(box_w/8) - 1)*24];

            extract_hog(box_h, box_w, W, I, &img_window[0], &img_HOG[0]);    
            img_HOG_mean = mean_subtract(hog_len, &img_HOG[0]);
        
            for(int l = 0; l < hog_len; ++l){ 
                img_HOG[l] -= img_HOG_mean; 
    	    }

            img_HOG_norm = array_norm(hog_len, &img_HOG[0]);

            #ifdef DEBUG
            	cout << "image_mean: " << img_HOG_mean << endl;
                cout << "image_norm: " << img_HOG_norm << endl;
            #endif

            score = double(array_dot(hog_len, &img_HOG[0], &template_HOG[0])/ (template_HOG_norm * img_HOG_norm)); 

            all_bounding_boxes[((x-box_h)/3 * ((img_w-box_w)/3 + 1) * 3) + ((y-box_w)/3 * 3) + 0] = x-box_h;
            all_bounding_boxes[((x-box_h)/3 * ((img_w-box_w)/3 + 1) * 3) + ((y-box_w)/3 * 3) + 1] = y-box_w;
            all_bounding_boxes[((x-box_h)/3 * ((img_w-box_w)/3 + 1) * 3) + ((y-box_w)/3 * 3) + 2] = score*100;
  
            //deallocate img_HOG
            delete [] img_HOG;
        }
        y = 0;
    }
   
    #ifdef DEBUG
        for(int i = 0; i <= (img_h-box_h)/3; ++i) {
            for(int j = 0; j <= (img_w - box_w)/3; ++j){
                cout << "x: "<< all_bounding_boxes[(i * ((img_w-box_w)/3 + 1) * 3) + (j * 3) + 0];
                cout << " y: " << all_bounding_boxes[(i * ((img_w-box_w)/3 + 1) * 3) + (j * 3) + 1];
                cout << " score: " << all_bounding_boxes[(i * ((img_w-box_w)/3 + 1) * 3) + (j * 3) + 2];
                cout << endl;
            }
            cout << endl;
        }
    #endif
     
    // sorting array [Bubble Sort(slower version)]
    sort_bounded_boxes((img_h-box_h)/3 + 1, (img_w-box_w)/3 + 1, 3, all_bounding_boxes);
    num_thresholded = 0;

    for(int i = ((img_h-box_h)/3 + 1) - 1; i >= 0; --i){
        for(int j = ((img_w-box_w)/3 + 1) - 1; j >= 0; --j){
            if(*(all_bounding_boxes + i * ((img_w-box_w)/3 + 1) * 3 + j*3 + 2) > THRESHOLD*100) {
                num_thresholded++;
            }
        }
    }
    
    double *thresholded_boxes = new double[num_thresholded*3];

    int tb = 0; // thresholded_box
    for(int i = ((img_h-box_h)/3 + 1) - 1; i >= 0; --i) {
        for(int j = ((img_w-box_w)/3 + 1) - 1; j >= 0; --j) {
            if(*(all_bounding_boxes + i * ((img_w-box_w)/3 + 1) * 3 + j*3 + 2) > THRESHOLD*100) 
            {
                thresholded_boxes[tb*3 + 0] = *(all_bounding_boxes + i * ((img_w-box_w)/3 + 1) * 3 + j*3 + 0); 
                thresholded_boxes[tb*3 + 1] = *(all_bounding_boxes + i * ((img_w-box_w)/3 + 1) * 3 + j*3 + 1); 
                thresholded_boxes[tb*3 + 2] = *(all_bounding_boxes + i * ((img_w-box_w)/3 + 1) * 3 + j*3 + 2);
          
		        cout << "x: " << thresholded_boxes[tb*3 + 0] << " y: " << thresholded_boxes[tb*3 + 1] << " score: " << thresholded_boxes[tb*3 + 2] << endl;
		        tb++;
            }
        }
    }     
 
    
    #ifdef DEBUG
        cout << "Number of thresholded boxes with score > " << THRESHOLD*100 << " is: " << num_thresholded << endl << endl;
        for(int i = 0; i < num_thresholded; ++i) {
            cout << "x: " << thresholded_boxes[i*3 + 0] << " y: " << thresholded_boxes[i*3 + 1] << " score: " << thresholded_boxes[i*3 + 2] << endl;
        }
    #endif

    double *bounding_boxes = new double[num_thresholded * 3];

    tb = 0;
    int kk = 0;
    for(int i = num_thresholded-1; i >= 0; --i) {
        if(thresholded_boxes[i*3 + 2] <= 100) {
            double currBox[3] = {thresholded_boxes[i*3 + 0], thresholded_boxes[i*3 + 1], thresholded_boxes[i*3 + 2]};
            bounding_boxes[kk*3 + 0] = currBox[0];
            bounding_boxes[kk*3 + 1] = currBox[1];
            bounding_boxes[kk*3 + 2] = currBox[2];
            kk++;
            double nextBox[3];
            for(int j = num_thresholded-1; j >= 0; --j) {
                if(thresholded_boxes[j*3 + 2] <= 100) {
                    nextBox[0] = thresholded_boxes[j*3 + 0];
                    nextBox[1] = thresholded_boxes[j*3 + 1];
                    nextBox[2] = thresholded_boxes[j*3 + 2];
                    if(box_iou(currBox[0], currBox[1], nextBox[0], nextBox[1], box_w) >= 0.5) {
                        thresholded_boxes[j*3 + 2] = 404; // any number >100 just to make if statements false when iterating
                    }
                }
            }
        }
    }
    
    num_thresholded = kk;

    #ifdef DEBUG
        for(int i = 0; i < kk; ++i) {
            cout << "after x: " << bounding_boxes[i*3 + 0] << " y: " << bounding_boxes[i*3 + 1] << " score: " << bounding_boxes[i*3 + 2] << endl;
        }
        cout << endl << "face_recognition finished..." << endl << endl;
    #endif

    // deallocate everything!
    delete [] template_HOG;
    delete [] img_window;
    delete [] all_scores;
    delete [] all_bounding_boxes;
    delete [] thresholded_boxes;

    return bounding_boxes;
}

void face_recognition_range(int W, int I, double *I_target, int step) {
   
    double *found_faces = (double *) malloc(sizeof(double)*3);
    num_faces = 0;

    for(int width = UPPER_BOUNDARY; width >= LOWER_BOUNDARY; width -= step) {
     	cout << "current template: " << width << endl;
        
        char gray_template[20] = "template_";
        char size_gray[4];
        snprintf(size_gray, sizeof(size_gray), "%d", width);
        strcat(gray_template, size_gray);
        strcat(gray_template, ".txt");

        cout << gray_template << endl;
            
        double *I_template = new double[width * width];

        FILE * rach = fopen(gray_template, "rb");
        double val = 0;

        for (int i = 0; i < width; ++i){
            for (int j = 0; j < width; ++j){
                fscanf(rach, "%lf", &val);
                I_template[i * width + j] = val;
            }
        }

        double *found_boxes = face_recognition(ROWS, COLS, width, width, W, I, I_target, I_template);
        num_faces += num_thresholded;   
        found_faces = (double *) realloc(found_faces, sizeof(double)*num_faces*3);

        cout << "number_thresholded: " << num_thresholded << " at " << width << endl;
        cout << "number_faces: " << num_faces << endl;
        
        for(int i = 0; i < num_thresholded; i++) {
            found_faces[(i+(num_faces-num_thresholded))*3 + 0] = found_boxes[i*3 + 0];
            found_faces[(i+(num_faces-num_thresholded))*3 + 1] = found_boxes[i*3 + 1];
            found_faces[(i+(num_faces-num_thresholded))*3 + 2] = found_boxes[i*3 + 2];


           cout << "x_ff: " << found_faces[(i+(num_faces-num_thresholded))*3 + 0] << " y_ff: " << found_faces[(i+(num_faces-num_thresholded))*3 + 1] << " score_ff: " <<  found_faces[(i+(num_faces-num_thresholded))*3 + 2] <<  endl;  
        }

        delete [] found_boxes;
        delete [] I_template;

    }

	char faces_width[20] = "faces_";
    char width[4];
    snprintf(width, sizeof(width), "%d", W);
    strcat(faces_width, width);
    strcat(faces_width, ".txt");

	write_txt(found_faces, num_faces, faces_width);
    
    free(found_faces);
}
