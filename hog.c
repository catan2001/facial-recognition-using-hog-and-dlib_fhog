#include <stdio.h>
#include <stdlib.h>
#include <math.h>

//assume the size of our picture is fixed and already determined
#define ROWS 200
#define COLS 200

#define BLOCK_SIZE 2

#define CELL_SIZE 8
#define nBINS 6

#define PI 3.14159265358979323846

#define HEIGHT (ROWS/CELL_SIZE)
#define WIDTH (COLS/CELL_SIZE)

#define HIST_SIZE 6*BLOCK_SIZE*BLOCK_SIZE

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
                imROI[k]=padded_img[i+(int)k/3][j+(k%3)];

                im_filtered[i][j]+=imROI[k]*filter[k];
                
                im_filtered[i][j]=(float)((512+(int)im_filtered[i][j])%256);
                
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
                grad_angle[i][j] = atan((float)dY/dX) + PI/2;
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

void get_block_descriptor(float ori_histo[(int)ROWS/CELL_SIZE][(int)COLS/CELL_SIZE][nBINS], float ori_histo_normalized[HEIGHT-(BLOCK_SIZE-1)][WIDTH-(BLOCK_SIZE-1)][6*(BLOCK_SIZE*BLOCK_SIZE)]){
    int x_window = 0;
    int y_window = 0;

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

void extract_hog(float im[ROWS][COLS], float hog[(HEIGHT-(BLOCK_SIZE-1)) * (WIDTH-(BLOCK_SIZE-1)) * (6*BLOCK_SIZE*BLOCK_SIZE)]) {
    
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
    
    float ori_histo[(int)ROWS/CELL_SIZE][(int)COLS/CELL_SIZE][nBINS]; // TODO: check to replace ROWS/CELL_SIZE with HEIGHT
    build_histogram(grad_mag, grad_angle, ori_histo);
    
    // TODO: Make makro to replace underneath
    float ori_histo_normalized[HEIGHT-(BLOCK_SIZE-1)][WIDTH-(BLOCK_SIZE-1)][6*(BLOCK_SIZE*BLOCK_SIZE)];        
    
    get_block_descriptor(ori_histo, ori_histo_normalized);
    
    int l = 0;
    for(int i = 0; i < HEIGHT-(BLOCK_SIZE-1); ++i)
      for(int j = 0; j < WIDTH-(BLOCK_SIZE-1); ++j)
        for(int k = 0; k < 6*BLOCK_SIZE*BLOCK_SIZE; ++k)
          hog[l++] = ori_histo_normalized[i][j][k];
}


int main(){


    unsigned int a,b;
    float gray[ROWS][COLS], c_hog[(HEIGHT-(BLOCK_SIZE-1)) * (WIDTH-(BLOCK_SIZE-1)) * (6*BLOCK_SIZE*BLOCK_SIZE)];

    FILE * rach;
    rach = fopen("gray.txt", "rb");


    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){

            fscanf(rach, "%d", &a);

            gray[i][j] = a;
            //printf("%f ", gray[i][j]);
        }
        //printf("\n");
    }

    fclose(rach);

    extract_hog(gray, c_hog);

    FILE * dx_rach;

    dx_rach = fopen("c_hog.txt", "wb");

    for (int i=0; i<13824; ++i){

            a = c_hog[i];

            fprintf(dx_rach, "%d ", a);
    }

    fclose(dx_rach);



    /*FILE * rach;
    FILE * ptr;
    rach = fopen("dx.txt", "rb");
    rach = fopen("dj_c.txt", "rb");

    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){

            fscanf(rach, "%d", &a);
            fscanf(ptr, "%d", &b);

            if(a==b) 
            //printf("%f ", gray[i][j]);
        }
        //printf("\n");
    }

    fclose(rach);*/

    /*FILE * rach;
    rach = fopen("gray.txt", "rb");


    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){

            fscanf(rach, "%d", &a);

            gray[i][j] = a;
            //printf("%f ", gray[i][j]);
        }
        //printf("\n");
    }

    fclose(rach);

    filter_image(gray, dx, filter_x);

    FILE * dx_rach;

    dx_rach = fopen("dx_c.txt", "wb");

    int c;


    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){

            a = dx[i][j];

            fprintf(dx_rach, "%d ", a);

        }
        fprintf(dx_rach, "\n");
    }

    fclose(dx_rach);






    unsigned char c=-150;

    c = ~c;

    printf("c=%d ", c);*/

    /*FILE* dx, *dc;
    dx = fopen("dx.ppm", "rb");
    dc = fopen("dx_C.ppm", "rb");

    char c, x;
    int a=0;

    do{
        c = fgetc(dc);
        x = fgetc(dx);
        a++;

        if(c != x){
            printf("c=%d ", c);
            printf("x=%d ", x);
            printf("redni broj=%d \n", a);
        }


    }while(c != EOF);*/

    /*FILE * rach;
    rach = fopen("gray_rachel.ppm", "rb");

    char ch;
    float a;
    float matrix[ROWS][COLS], dx[ROWS][COLS];


    printf("\n");

    for(int k=0; k<15; ++k) ch = fgetc(rach); //predji na prvi clan niza

    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){
            
            //ch = fgetc(rach);
            //ch = fgetc(rach);
            ch = fgetc(rach);
            a=ch;

            matrix[i][j] = a;
            //printf("%d ", (int)matrix[i][j]);
        }
        //printf("\n");
    }      

    fclose(rach);

    filter_image(matrix, dx, filter_x);

    printf("\n\n\n");

    FILE * dx_rach;
    dx_rach = fopen("dx_C.ppm", "wb");

    fprintf(dx_rach, "P6 200 200 255\n");
  
    for(int i=0; i<200; i++) {
        for(int j=0; j<600; j++) {
        fputc((int)dx[i][j], dx_rach);
        }
    }
    fclose(dx_rach);


    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){
        
            printf("%d ", (int)dx[i][j]);
        }
        break;
        printf("\n");
    }  */


    return 0;
}