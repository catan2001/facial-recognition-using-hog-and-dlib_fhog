#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

//assume the size of our picture is fixed and already determined
#define ROWS 200
#define COLS 600

#define CELL_SIZE 8
#define nBINS 6

#define PI 3.14159265358979323846

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



int main(){

    FILE * rach;
    rach = fopen("dx.ppm", "rb");

    unsigned char ch;
    unsigned char a;
    unsigned char matrix[ROWS][COLS], dx[ROWS][COLS];


    printf("\n");

    for(int k=0; k<15; ++k) ch = fgetc(rach); //predji na prvi clan niza

    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){
            
            //ch = fgetc(rach);
            //ch = fgetc(rach);
            ch = fgetc(rach);
            a=ch;

            matrix[i][j] = a;
            printf("%d ", (unsigned int)matrix[i][j]);
        }
        printf("\n");
    }     

     //printf("%d ", (int)matrix[1][0]);

    fclose(rach);

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