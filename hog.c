#include <stdio.h>
#include <math.h>

//assume the size of our picture is fixed and already determined
#define ROWS 200
#define COLS 200

#define CELL_SIZE 8
#define nBINS 6

#define PI 3.14159265358979323846

//3 x 3 Sobel filter
const char filter_x[9] = {1,0,-1, 2,0,-2, 1,0,-1};  //Dx = filter_x conv D
const char filter_y[9] = {1,2,1, 0,0,0, -1,-2,-1};    //Dy = filter_y conv D

//TODO: in main before calling this function you need to pad the image on all edges by 1 and fill them with zeros
//so the filtered image has the same rezolution as the original
void filter_image(int img[ROWS][COLS], int im_filtered[ROWS][COLS], const char* filter){

    //create a local matrix that will hold the padded image:
    int padded_img[ROWS+2][COLS+2];
    
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
    int chunk[9];

    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){

            //np.dot(img[i:i+3][j:j+3].flatten(), filter)
            for(int k=0; k<9; ++k){
                chunk[k]=padded_img[i+(int)k/3][j+(k%3)];

                im_filtered[i][j]+=chunk[k]*filter[k];
            }
        }
    }
}

//getting the amplitude and phase matrix of the filtered image
void get_gradient(int im_dx[ROWS][COLS], int im_dy[ROWS][COLS], int grad_mag[ROWS][COLS], int grad_angle[ROWS][COLS]){
    
    for(int i=0; i<ROWS; ++i){
        for(int j=0; j<COLS; ++j){
            int dX = im_dx[i][j];
            int dY = im_dy[i][j];

            //determining the amplitude matrix:
            grad_mag[i][j] = sqrt(pow(dX,2)+pow(dY,2));

            //determining the phase matrix:
            if(abs(dX)>0.00001){
                grad_angle[i][j] = arctan(dY/dX) + PI/2;
            }else if(dY<0 && dX<0){
                grad_angle[i][j] = 0;
            }else{
                grad_angle[i][j] = PI;
            }
        }
    }
}

void build_histogram(int grad_mag[ROWS][COLS], int grad_angle[ROWS][COLS], float ori_histo[(int)ROWS/CELL_SIZE][(int)COLS/CELL_SIZE][nBINS]){

    int x_corner = 0;
    int y_corner = 0;

    while(x_corner+CELL_SIZE <= ROWS){
        while(y_corner+CELL_SIZE <= COLS){
            float hist[6]={0, 0, 0, 0, 0, 0};
        }
    }
}



int main(){

    int image[2][3]={{1, 0, 5}, {2, 2, 7}};

    for(int i=0; i<2; ++i){
        for(int j=0; j<3; ++j){
            //printf("%d ", image[i][j]);
        }
        printf("/n");
    }

    /*for(int i=0; i<2; ++i){
        printf("%d ", image[i]);
    }*/

    return 0;
}