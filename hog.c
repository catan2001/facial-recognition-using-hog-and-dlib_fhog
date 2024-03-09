#include <stdio.h>

//assume the size of our picture is fixed and already determined
#define ROWS 200
#define COLS 200

//3 x 3 Sobel filter
const char filter_x[9] = {1,0,-1, 2,0,-2, 1,0,-1};  //Dx = filter_x conv D
const char filter_y[9] = {1,2,1, 0,0,0, -1,-2,-1};    //Dy = filter_y conv D

//TODO: in main before calling this function you need to pad the image on all edges by 1 and fill them with zeros
//so the filtered image has the same rezolution as the original
void filter_image(int img[ROWS+2][COLS+2], int im_filtered[ROWS][COLS], const char* filter){

    //fill filtered image with zeros:
    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){
            im_filtered[i][j] = 0;
        }
    }

    //filter image:
    int chunk[9];

    for (int i=0; i<ROWS; ++i){
        for (int j=0; j<COLS; ++j){

            //np.dot(img[i:i+3][j:j+3].flatten(), filter)
            for(int k=0; k<9; ++k){
                chunk[k]=img[i+(int)k/3][j+(k%3)];

                im_filtered[i][j]+=chunk[k]*filter[k];
            }
        }
    }
}

//GETTING THE AMPLITUDE AND PHASE MATRIX OF THE FILTERED IMAGE
void get_gradient(){
    

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