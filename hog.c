#include <stdio.h>
#include <stdlib.h>
#include <math.h>

//assume the size of our picture is fixed and already determined
#define ROWS 200
#define COLS 200

#define CELL_SIZE 8
#define nBINS 6

#define BLOCK_SIZE 2

#define PI 3.14159265358979323846

#define HEIGHT 25
#define WIDTH 25

#define HIST_SIZE 6*BLOCK_SIZE*BLOCK_SIZE

//3 x 3 Sobel filter
const char filter_x[9] = {1,0,-1, 2,0,-2, 1,0,-1};  //Dx = filter_x conv D
const char filter_y[9] = {1,2,1, 0,0,0, -1,-2,-1};    //Dy = filter_y conv D

//TODO: in main before calling this function you need to pad the image on all edges by 1 and fill them with zeros
//so the filtered image has the same rezolution as the original
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
                imROI[k]=padded_img[i+(int)k/3][j+(k%3)];

                im_filtered[i][j]+=imROI[k]*filter[k];
            }
        }
    }
}

//getting the amplitude and phase matrix of the filtered image
void get_gradient(float im_dx[ROWS][COLS], float im_dy[ROWS][COLS], float grad_mag[ROWS][COLS], float grad_angle[ROWS][COLS]){
    
    for(int i=0; i<ROWS; ++i){
        for(int j=0; j<COLS; ++j){
            int dX = im_dx[i][j];
            int dY = im_dy[i][j];
  
            //determining the amplitude matrix:
            grad_mag[i][j] = sqrt(pow(dX,2)+pow(dY,2));

            //determining the phase matrix:
            if(abs(dX)>0.00001){
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

    //start from the upper left corner
    int x_corner = 0;
    int y_corner = 0;
    //define REGION of INTEREST, our new chunks
    int cell_pow2 = CELL_SIZE*CELL_SIZE;
    float magROI[cell_pow2], angleROI[cell_pow2];

    float angleInDeg;

    while(x_corner+CELL_SIZE <= ROWS){
        while(y_corner+CELL_SIZE <= COLS){
            float hist[6]={0, 0, 0, 0, 0, 0};

            for(int k=0; k<9; ++k){
                magROI[k]=grad_mag[x_corner+(int)k/CELL_SIZE][y_corner+(k%CELL_SIZE)];
                angleROI[k]=grad_angle[x_corner+(int)k/CELL_SIZE][y_corner+(k%CELL_SIZE)];
            }

            for(int i=0; i<cell_pow2; ++i){
                angleInDeg = angleROI[i]*(180 / PI);

                if(angleInDeg >=0 && angleInDeg < 30){
                    hist[0] += magROI[i];
                }else if(angleInDeg >=30 && angleInDeg < 60){
                    hist[1] += magROI[i];
                }else if(angleInDeg >=60 && angleInDeg < 90){
                    hist[2] += magROI[i];
                }else if(angleInDeg >=90 && angleInDeg < 120){
                    hist[3] += magROI[i];
                }else if(angleInDeg >=120 && angleInDeg < 150){
                    hist[4] += magROI[i];
                }else{
                    hist[5] += magROI[i];
                }  
            }

            //ori_histo[int(x_corner/cell_size),int(y_corner/cell_size),:] = hist
            for(int i=0; i<nBINS; ++i) ori_histo[(int)x_corner/CELL_SIZE][(int)y_corner/CELL_SIZE][i] = hist[i];

            y_corner+=CELL_SIZE;
        }
        x_corner+=CELL_SIZE;
        y_corner=0;
    }
}

void get_block_descriptor(float ori_histo[(int)ROWS/CELL_SIZE][(int)COLS/CELL_SIZE][nBINS]){
    int x_window = 0;
    int y_window = 0;
    float ori_histo_normalized[HEIGHT-(BLOCK_SIZE-1)][WIDTH-(BLOCK_SIZE-1)][6*(BLOCK_SIZE*BLOCK_SIZE)];        
    while(x_window + BLOCK_SIZE <= HEIGHT){
        while(y_window + BLOCK_SIZE <= WIDTH){
            float concatednatedHist[HIST_SIZE];
            int index = 0;
            for(int i = 0;i <= x_window + BLOCK_SIZE;i++){
                for(int j = 0;j <= y_window + BLOCK_SIZE;j++){
                    for(int k = 0;k < 6; k++){
                        concatednatedHist[index]=ori_histo[i][j][k];
                        ++index;
                    }
                }
            }
            float histNorm = 0.0;
            for(int i = 0; i < HIST_SIZE;i++){
                histNorm += concatednatedHist[i] * concatednatedHist[i];
            }
            histNorm = sqrt(histNorm + 0.001);

            int h_i = 0;
            for(int i = 0; i < HIST_SIZE; i++){
                ori_histo_normalized[x_window][y_window][i] = concatednatedHist[h_i] / histNorm;
                h_i++;
                y_window += BLOCK_SIZE;
            }
        }
        x_window += BLOCK_SIZE;
        y_window = 0; 
    }
}

void extract_hog(float im[ROWS][COLS], float hog[]) {
    
    // im_min and im_max used for normalizing the image
    im[0][0] = im[0][0]/255.0;
    float im_min = im[0][0]; // initalize
    float im_max = im[0][0]; // initalize
    
    for(int i = 0; i < ROWS; ++i)
      for(int j = 0; j < COLS; ++j) {
        im[i][j] = im[i][j]/255.0; // converting to float format
        if(im_min > im[i][j]) im_min = im[i][j]; // find min im
        if(im_max < im[i][j]) im_max = im[i][j]; // find max im
      }
    
    for(int i = 0; i < ROWS; ++i)
      for(int j = 0; j < COLS; ++j) {
        im[i][j] = (im[i][j] - im_min) / im_max; // Normalize image to [0, 1]
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
    
    float ori_histo[(int)ROWS/CELL_SIZE][(int)COLS/CELL_SIZE][nBINS];
    build_histogram(grad_mag, grad_angle, ori_histo);
    
    //TODO: Finish the function when Andjela finishes with her function
    
}

int main(){

    /*FILE * out;
    out = fopen("color_test.ppm", "wb");

    fprintf(out, "P6 256 256 255\n");
    
    for(int r=0; r<256; r++) {
        for(int b=0; b<256; b++) {
            fputc(r, out);
            fputc(0, out);
            fputc(b, out);
        }
    }
  
    fclose(out);*/
    
    FILE * rach;
    rach = fopen("disgustedrachel.ppm", "r");

  return 0;
}
