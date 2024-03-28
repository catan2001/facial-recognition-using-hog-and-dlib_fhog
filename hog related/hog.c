#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

//assume the size of our picture is fixed and already determined
#define ROWS 200
#define COLS 200

#define BLOCK_SIZE 2

#define CELL_SIZE 8
#define nBINS 6

#define PI 3.14159265358979323846

#define HEIGHT (ROWS/CELL_SIZE)
#define WIDTH (COLS/CELL_SIZE)

#define HIST_SIZE nBINS*BLOCK_SIZE*BLOCK_SIZE

//3 x 3 Sobel filter
const char filter_x[9] = {1,0,-1, 2,0,-2, 1,0,-1};  //Dx = filter_x conv D
const char filter_y[9] = {1,2,1, 0,0,0, -1,-2,-1};    //Dy = filter_y conv D

void filter_image(float img[ROWS][COLS], float im_filtered[ROWS][COLS], const char* filter){

    //create a local matrix that will hold the padded image:
    float padded_img[ROWS+2][COLS+2];
    
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
            im_filtered[i][j] = 0;
            //putting the original image within the padded one:
            padded_img[i+1][j+1]=img[i][j];
        }
    }

    //filter image:
    float imROI[9];

    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){

            //np.dot(img[i:i+3][j:j+3].flatten(), filter)
            for(int k=0; k<9; ++k){
                imROI[k]=padded_img[i+(int)(k/3)][j+(k%3)];

                im_filtered[i][j]+=imROI[k]*filter[k];
            }
        }
    }
}

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

void mat_txt(FILE * ptr, char * name_txt, float matrix[ROWS][COLS]){

    ptr = fopen(name_txt, "wb");

    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){
            fprintf(ptr, "%.16f ", matrix[i][j]);
        }
        fprintf(ptr, "\n");
    }
    fclose(ptr);
}

void orihisto_txt(FILE * ptr, char * name_txt, float matrix[(int)ROWS/CELL_SIZE][(int)COLS/CELL_SIZE][nBINS]){

    ptr = fopen(name_txt, "wb");

    for (int i=0; i<ROWS/CELL_SIZE; ++i){
        for (int j=0; j<COLS/CELL_SIZE; ++j){
            for (int k=0; k<nBINS; ++k){
                fprintf(ptr, "%f ", matrix[i][j][k]);
            }
            fprintf(ptr, "\n");
        }
        fprintf(ptr, "\n");
    }
    fclose(ptr);
}

void orihistonorm_txt(FILE * ptr, char * name_txt, float matrix[HEIGHT-(BLOCK_SIZE-1)][WIDTH-(BLOCK_SIZE-1)][nBINS*(BLOCK_SIZE*BLOCK_SIZE)]){

    ptr = fopen(name_txt, "wb");

    for (int i=0; i<(HEIGHT-(BLOCK_SIZE-1)); ++i){
        for (int j=0; j<(HEIGHT-(BLOCK_SIZE-1)); ++j){
            for (int k=0; k<(nBINS*(BLOCK_SIZE*BLOCK_SIZE)); ++k){
                fprintf(ptr, "%f ", matrix[i][j][k]);
            }
            fprintf(ptr, "\n");
        }
        fprintf(ptr, "\n");
    }
    fclose(ptr);
}

void extract_hog(float im[ROWS][COLS], float hog[(HEIGHT-(BLOCK_SIZE-1)) * (WIDTH-(BLOCK_SIZE-1)) * (nBINS*BLOCK_SIZE*BLOCK_SIZE)]) {

    
    double im_min = im[0][0]/255.0; // initalize
    double im_max = im[0][0]/255.0; // initalize
    
    for(int i = 0; i < ROWS; ++i){
      for(int j = 0; j < COLS; ++j){
            im[i][j] = im[i][j]/255.0; // converting to float format

            if(im_min > im[i][j]) im_min = im[i][j]; // find min im
            if(im_max < im[i][j]) im_max = im[i][j]; // find max im

        }
    }

    for(int i = 0; i < ROWS; ++i){
      for(int j = 0; j < COLS; ++j){
            im[i][j] = (im[i][j] - im_min) / im_max; // Normalize image to [0, 1]
        }
    } 

    float dx[ROWS][COLS];
    float dy[ROWS][COLS];
    //GET X GRADIENT OF THE PICTURE
    filter_image(im, dx, filter_x);
    //GET Y GRADIENT OF THE PICTURE
    filter_image(im, dy, filter_y);
    
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

void array_txt(FILE * ptr, char * name_txt, float matrix[(HEIGHT-(BLOCK_SIZE-1)) * (WIDTH-(BLOCK_SIZE-1)) * (6*BLOCK_SIZE*BLOCK_SIZE)]){

    ptr = fopen(name_txt, "wb");

    for (int i=0; i<(HEIGHT-(BLOCK_SIZE-1)) * (WIDTH-(BLOCK_SIZE-1)) * (6*BLOCK_SIZE*BLOCK_SIZE); ++i){
        fprintf(ptr, "%f ", matrix[i]);
    }
    fclose(ptr);
}


int main(){


    unsigned int a;
    float b;
    float gray[ROWS][COLS], c_hog[(HEIGHT-(BLOCK_SIZE-1)) * (WIDTH-(BLOCK_SIZE-1)) * (6*BLOCK_SIZE*BLOCK_SIZE)];
    float im_dx[ROWS][COLS], im_dy[ROWS][COLS], grad_mag[ROWS][COLS], grad_angle[ROWS][COLS];
    float ori_histo[(int)ROWS/CELL_SIZE][(int)COLS/CELL_SIZE][nBINS];
    float ori_histo_normalized[HEIGHT-(BLOCK_SIZE-1)][WIDTH-(BLOCK_SIZE-1)][nBINS*(BLOCK_SIZE*BLOCK_SIZE)];
    float hog[(HEIGHT-(BLOCK_SIZE-1)) * (WIDTH-(BLOCK_SIZE-1)) * (nBINS*BLOCK_SIZE*BLOCK_SIZE)];

    FILE * rach;
    rach = fopen("gray.txt", "rb");


    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){

            fscanf(rach, "%d", &a);

            gray[i][j] = a;
            //printf("%d ", a);
        }
        //printf("\n");
    }

    fclose(rach);

    extract_hog(gray, hog);

    FILE * hog_ptr;
    array_txt(hog_ptr, "hog1_c.txt", hog);

    return 0;
}