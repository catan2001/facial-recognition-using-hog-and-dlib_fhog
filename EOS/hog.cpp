#include <stdio.h>
#include <iostream>
#include <cmath>
#include <string.h>
#include <math.h>
#include <deque>
#include <iomanip>
#include <chrono>

#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>


using namespace std;

//sahe 1
#define SAHE1_addr 0
#define READY_REG_OFFSET 0
#define START_REG_OFFSET 1
#define WIDTH_REG_OFFSET 2
#define HEIGHT_REG_OFFSET 12
#define WIDTH_2_REG_OFFSET 23
//sahe2
#define SAHE2_addr 4
#define WIDTH_4_REG_OFFSET 0
#define EFFECTIVE_ROW_LIMIT_REG_OFFSET 8
#define CYCLE_NUM_IN_REG_OFFSET 20
#define CYCLE_NUM_OUT_REG_OFFSET 26
//sahe 3
#define SAHE3_addr 8
#define ROW_CAP_BRAM_REG_OFFSET 0
#define BRAM_HEIGHT_REG_OFFSET 10
#define RESET_REG_OFFSET 15

#define BRAM_HEIGHT 16
#define BRAM_WIDTH 2048

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

int num_thresholded = 0;
int num_faces = 0;

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

int main() {

        int upper_boundary = (ROWS > COLS)? COLS : ROWS;
        int step = ceil(floor((upper_boundary-floor(upper_boundary/3))/10)/4)*4; // parameter for face_recognition_range
        int lower_boundary = upper_boundary-10*step;

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

        double time_filter = 0;
        double time_get_gradient = 0;
        double time_build_histogram = 0;
        double time_block_descriptor = 0;

        double time_extract_hog = 0;
        double time_face_rec = 0;
        double algorithm_time = 0;

        auto start = chrono::high_resolution_clock::now();

        face_recognition_range(&gray[0], step, lower_boundary, upper_boundary, &time_face_rec, &time_extract_hog, &time_filter, &time_get_gradient, &time_build_histogram, &time_block_descriptor);

        auto finish = chrono::high_resolution_clock::now();

        algorithm_time = chrono::duration_cast<std::chrono::nanoseconds>(finish-start).count();

        cout << "algorithm time: " << algorithm_time << "ns\n";
        cout << chrono::duration_cast<std::chrono::seconds>(finish-start).count() << "s\n";

        /*cout << "FACE REC: " << time_face_rec << endl;
        cout << "face_rec_time/algorithm_time: " << (time_face_rec/algorithm_time)*100 << endl;

        cout << "EXTRACT HOG: " << time_extract_hog << endl;
        cout << "exctract_time/algorithm_time: " << (time_extract_hog/algorithm_time)*100 << endl;

        cout << "time taken for filtering the images: " << time_filter << endl;
        cout << "filter_time/algorithm_time: " << (time_filter/time_extract_hog)*100 << endl;

        cout << "time taken for get_gradient the images: " << time_get_gradient << endl;
        cout << "get_gradient_time/algorithm_time: " << (time_get_gradient/time_extract_hog)*100 << endl;

        cout << "time taken for build histogram the images: " << time_build_histogram << endl;
        cout << "build_histogram_time/algorithm_time: " << (time_build_histogram/time_extract_hog)*100 << endl;

        cout << "time taken for block descriptor the images: " << time_block_descriptor << endl;
        cout << "block_descriptor_time/algorithm_time: " << (time_block_descriptor/time_extract_hog)*100 << endl;*/

        
        delete [] gray; // deallocates whole array in memory

    return 0;
}

void write_hard(unsigned char addr, int val)
{
	FILE *filter_file;
	
	filter_file = fopen("/dev/filter_core", "w");
	fprintf(filter_file, "%d, %d\n", val, addr);
	fflush(filter_file);
	fclose(filter_file);
}

int read_hard(unsigned char addr)
{
	FILE *filter_file;
	int val[3];
	char tmp = addr/4;
	
	filter_file = fopen("/dev/filter_file", "r");
	fscanf(filter_file, "%d %d %d \n", &val[0], &val[1], &val[2]);
	fclose(filter_file);
	
	return val[tmp];
}

void write_txt(double* found_faces, int len, char *name_txt){
	
	FILE *fp;
	
  	fp = fopen(name_txt, "wb");

    	for(int i=0; i<len; ++i){
	       	fprintf(fp, "x: %.0lf y: %.0lf score: %.4lf \n", found_faces[i*3], found_faces[3*i+1], found_faces[3*i+2]);
    	//	printf("x: %.2lf y: %.2lf score: %.4lf \n", found_faces[i*3], found_faces[3*i+1], found_faces[3*i+2]);
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

void filter_hw(int rows, int cols, uint16_t *img, int64_t *dx_img, int64_t *dy_img){

	int fd;
	int64_t *even;
	int64_t *odd;
	int64_t *dx;
	int64_t *dy;

	int k = 0;
	int64_t image_even[(cols)*(rows)/8], image_odd[(rows)*(cols)/8];

    //SAHE3:
    int bram_height = BRAM_HEIGHT;
    int row_capacity_bram = floor(BRAM_WIDTH/(cols))*BRAM_HEIGHT;
    
    uint32_t SAHE3 = (bram_height << BRAM_HEIGHT_REG_OFFSET) + (row_capacity_bram << ROW_CAP_BRAM_REG_OFFSET);

    //SAHE2:
    int cycle_num_out = floor(BRAM_WIDTH/(cols-2));
    int cycle_num_in = floor(BRAM_WIDTH/cols);
    int accumulated_loss = (ceil(rows/(BRAM_HEIGHT*floor(BRAM_WIDTH/cols)))-1)*4;
    int effective_row_limit = floor(rows/PTS_PER_COL)*PTS_PER_COL + accumulated_loss;
    int width_4 = floor(cols/4);
    
    uint32_t SAHE2 = (cycle_num_out << CYCLE_NUM_OUT_REG_OFFSET) + (cycle_num_in << CYCLE_NUM_IN_REG_OFFSET) + (effective_row_limit << EFFECTIVE_ROW_LIMIT_REG_OFFSET) + (width_4 << WIDTH_4_REG_OFFSET);

    //SAHE1:
    int width_2 = (floor(cols/2)+1);

	uint32_t SAHE1 = (width_2 << WIDTH_2_REG_OFFSET) + (rows << HEIGHT_REG_OFFSET) + (cols << WIDTH_REG_OFFSET);
 	

	write_hard(SAHE3_addr, (0x00008000 | SAHE3));
	while(!(read_hard(SAHE1_addr) & 0x00000001));
	write_hard(SAHE3_addr, SAHE3);

	write_hard(SAHE2_addr, SAHE2); 
	

	for(int i = 0; i < rows; i+=2){ 
	 	for(int j = 0; j < cols; j+=4){
	 	 image_even[k] = ((uint64_t)img[i*cols + j] << 48) | ((uint64_t)(img[i*cols + j + 1]) << 32) | ((uint64_t)(img[i*cols + j + 2]) << 16) | ((uint64_t)(img[i*cols + j + 3]));
		//printf("image_even %llu \n", image_even[k]);
		 image_odd[k] = ((uint64_t)img[(i+1)*cols + j] << 48) | ((uint64_t)(img[(i+1)*cols + j + 1]) << 32) | ((uint64_t)(img[(i+1)*cols + j + 2]) << 16) | ((uint64_t)(img[(i+1)*cols + j + 3]));
		//printf("image_odd %llu \n", image_odd[k]);
	         k++;
		}
	}
	
	write_hard(SAHE1_addr, (SAHE1 | 0x2));
	//while(!(read_hard(SAHE1) & 0x00000001));
	write_hard(SAHE1_addr, SAHE1);

	//IMG_EVEN DMA0----------------------------------------------------

	fd = open("/dev/dma0", O_RDWR|O_NDELAY);
	if (fd < 0)
	{
		printf("Cannot open /dev/dma0 for img_even\n");
		return -1;
	}
	
	even=(int64_t *)mmap(0, (rows*cols), PROT_WRITE, MAP_SHARED, fd, 0);
	memcpy(even, image_even, (rows*cols));

	close(fd);
	if (fd < 0)
	{
		printf("Cannot close /dev/dma0 for img_even\n");
		return -1;
	}

	//IMG_ODD DMA1:--------------------------------------------------
	
	fd = open("/dev/dma1", O_RDWR|O_NDELAY);
	if (fd < 0)
	{
		printf("Cannot open /dev/dma1 for img_odd\n");
		return -1;
	}

	odd=(int64_t*)mmap(0, (rows*cols), PROT_WRITE, MAP_SHARED, fd, 0);
	memcpy(odd, image_odd, (rows*cols));

	close(fd);

	if (fd < 0)
	{
		printf("Cannot close /dev/dma1 for img_odd\n");
		return -1;
	}

	//DX DMA0:--------------------------------------------------------
	
	fd = open("/dev/dma0", O_RDWR|O_NDELAY);
	if (fd < 0)
	{
		printf("Cannot open /dev/dma0 for dx\n");
		return -1;
	}


	dx=(int64_t *)mmap(0, ((rows-2)*cols*2), PROT_READ, MAP_SHARED, fd, 0);
	memcpy(dx_img, dx, ((rows-2)*cols*2));

	close(fd);
	if (fd < 0)
	{
		printf("Cannot close /dev/dma0 for dx\n");
		return -1;
	}

	//DY DMA1:--------------------------------------------------
	fd = open("/dev/dma1", O_RDWR|O_NDELAY);
	if (fd < 0)
	{
		printf("Cannot open /dev/dma1 for dy\n");
		return -1;
	}

	dy=(int64_t *)mmap(0, ((rows-2)*(cols)*2), PROT_READ, MAP_SHARED, fd, 0);
	memcpy(dy_img, dy, ((rows-2)*cols*2));

	close(fd);
	if (fd < 0)
	{
		printf("Cannot close /dev/dma1 for dy\n");
		return -1;
	}

	//CONFIG DMA:-------------------------------------------
	usleep(200);

	config_dma(rows*cols, (rows-2)*cols*2, 0); // config dma 0
	config_dma(rows*cols, (rows-2)*cols*2, 1); // config dma 1

	usleep(200);
/*
	for(int i = 0; i < rows-2; i++){
		printf("ROW: %d\n", i);
		for(int j = 0; j < cols/4; j++){
			//printf("Even NOT : %llu", )
			printf("%d: %llx ", j, dy[i*(cols/4) + j]); 
		}
		printf("\n");
	}
*/
	munmap(even, (rows*cols));
	munmap(odd, (rows*cols));
	munmap(dx, ((rows-2)*cols*2));
	munmap(dy, ((rows-2)*cols*2));
}

void filter_image(int rows, int cols, double* matrix_im_filtered_x, double* matrix_im_filtered_y, double* padded_img){

 double filter_x[9] = {1,0,-1, 2,0,-2, 1,0,-1};
 double filter_y[9] = {1,2,1, 0, 0, 0, -1,-2,-1};  

 double imROI[9];

    for (int i=0; i<rows; ++i){
        for (int j=0; j<cols; ++j){
            for(int k=0; k<9; ++k){
                imROI[k] = *(padded_img + (i+(int)(k/3))*(cols+2) + j+(k%3));

                *(matrix_im_filtered_y + i*cols + j) += imROI[k] * filter_y[k];
                *(matrix_im_filtered_x + i*cols + j) += imROI[k] * filter_x[k];
            }
        }
    }

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
            if(fabs(dX)>0.001){
                *(grad_angle + i*cols + j) = atan(dY/dX) + PI/2;
            }else if(dY<0 && dX<0){
                *(grad_angle + i*cols + j) = 0;
            }else{
                *(grad_angle + i*cols + j) = PI;
            }
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

void extract_hog(int rows, int cols, double *im, double *hog, double* time_filter, double* time_get_gradient, double* time_build_histogram, double* time_block_descriptor) { 
    
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
    
    double *padded_img = new double[(rows+2)*(cols+2)];    
    double *im_dx = new double[rows * cols];
    double *im_dy = new double[rows * cols];
    
    //pad the image on the outer edges with zeros:
    for(int i=0; i<rows+2; ++i) {
        *(padded_img + i*(cols+2))=0;
        *(padded_img + i*(cols+2) + cols+1)=0;
    }

    for(int i=0; i<cols+2; ++i) {
        *(padded_img + i)=0;
        *(padded_img + (rows+1)*(cols+2) + i)=0;
    }
    
    for (int i=0; i<rows; ++i){
        for (int j=0; j<cols; ++j){
            *(im_dx + i*cols + j) = 0;
            *(im_dy + i*cols + j) = 0;
            *(padded_img + (i+1)*(cols+2) + j+1)=*(im_c + i*cols + j);
        }
    }

    delete [] im_c;

    //Filter image:----------------------------------------------------------------------------------------------------------------

    //auto start = chrono::high_resolution_clock::now();

    filter_image(rows, cols, &im_dx[0], &im_dy[0], &padded_img[0]);

    //auto finish = chrono::high_resolution_clock::now();

    //*time_filter += chrono::duration_cast<std::chrono::nanoseconds>(finish-start).count();
    //--------------------------------------------------------------------------------------------------------------------------------
    

    double *grad_mag = new double[rows * cols];
    double *grad_angle = new double[rows * cols];

    //Get gradient:----------------------------------------------------------------------------------------------------------------
    //start = chrono::high_resolution_clock::now();
 
    get_gradient(rows, cols, &im_dx[0], &im_dy[0], &grad_mag[0], &grad_angle[0]);

    //finish = chrono::high_resolution_clock::now();

    //*time_get_gradient += chrono::duration_cast<std::chrono::nanoseconds>(finish-start).count();
     //--------------------------------------------------------------------------------------------------------------------------------
    

    int height = rows/CELL_SIZE;
    int width = cols/CELL_SIZE;
 
    double *ori_histo = new double[(int)height * (int)width * nBINS];

    //Build histogram:----------------------------------------------------------------------------------------------------------------
    //start = chrono::high_resolution_clock::now();

    build_histogram(rows, cols, &grad_mag[0], &grad_angle[0], &ori_histo[0]);

    //finish = chrono::high_resolution_clock::now();

    //*time_build_histogram += chrono::duration_cast<std::chrono::nanoseconds>(finish-start).count();
     //--------------------------------------------------------------------------------------------------------------------------------
    
    
    double *ori_histo_normalized = new double[(height-(BLOCK_SIZE-1)) * (width-(BLOCK_SIZE-1)) * nBINS*(BLOCK_SIZE*BLOCK_SIZE)];   

    //Get block descriptor:----------------------------------------------------------------------------------------------------------------
    //start = chrono::high_resolution_clock::now();

    get_block_descriptor(rows, cols, &ori_histo[0], &ori_histo_normalized[0]);
    
    //finish = chrono::high_resolution_clock::now();

    //*time_block_descriptor += chrono::duration_cast<std::chrono::nanoseconds>(finish-start).count();
    //--------------------------------------------------------------------------------------------------------------------------------
    
    int HOG_LEN = (height-1) * (width-1) * (nBINS*BLOCK_SIZE*BLOCK_SIZE);
    int i = nBINS*BLOCK_SIZE*BLOCK_SIZE*(width-1);

    for(int l = 0; l < HOG_LEN; ++l){
        hog[l] = ori_histo_normalized[(int)(l/i)*(width-(BLOCK_SIZE-1))*nBINS*(BLOCK_SIZE*BLOCK_SIZE) + (int)((l/24)%(width-1))*nBINS*(BLOCK_SIZE*BLOCK_SIZE) + l%24];
        #ifdef DEBUG
            if(hog[l] != hog[l]) cout << "hogl NAN" << endl;
        #endif   
    }

    // deallocate allocated
    delete [] padded_img;
    delete [] im_dx;
    delete [] im_dy;
    delete [] grad_mag;
    delete [] grad_angle;
    delete [] ori_histo;
    delete [] ori_histo_normalized;
}

double *face_recognition(int img_h, int img_w, int box_h, int box_w, double *I_target, double *I_template, double* time_extract_hog, double* time_filter, double* time_get_gradient, double* time_build_histogram, double* time_block_descriptor) {
    
    int hog_len = ((int)(box_h/8) - 1)*((int)(box_w/8)-1)*24;    
    double *template_HOG = new double[((int)(box_h/8)-1)*((int)(box_w/8)-1)*24];

    //Extract hog 1:----------------------------------------------------------------------------------------------------------------
    //auto start = chrono::high_resolution_clock::now();

    extract_hog(box_h, box_w, &(I_template[0]), template_HOG, time_filter, time_get_gradient, time_build_histogram, time_block_descriptor);

    //auto finish = chrono::high_resolution_clock::now();

    //*time_extract_hog += chrono::duration_cast<std::chrono::nanoseconds>(finish-start).count();
    //--------------------------------------------------------------------------------------------------------------------------------
    

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

            //Extract hog 2:----------------------------------------------------------------------------------------------------------------
            //start = chrono::high_resolution_clock::now();


            extract_hog(box_h, box_w, &img_window[0], &img_HOG[0], time_filter, time_get_gradient, time_build_histogram, time_block_descriptor);    

            //finish = chrono::high_resolution_clock::now();

            //*time_extract_hog += chrono::duration_cast<std::chrono::nanoseconds>(finish-start).count();
            //--------------------------------------------------------------------------------------------------------------------------------
            
            
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
          
		 //       cout << "x: " << thresholded_boxes[tb*3 + 0] << " y: " << thresholded_boxes[tb*3 + 1] << " score: " << thresholded_boxes[tb*3 + 2] << endl;
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

void face_recognition_range(double *I_target, int step, int LOWER_BOUNDARY, int UPPER_BOUNDARY, double* time_face_rec, double* time_extract_hog, double* time_filter, double* time_get_gradient, double* time_build_histogram, double* time_block_descriptor) {
   
    double *found_faces = (double *) malloc(sizeof(double)*3);
    num_faces = 0;

    /*cout << "upper boundary: " << UPPER_BOUNDARY << endl;
    cout << "lower boundary: " << LOWER_BOUNDARY << endl;
    cout << "step: " << step << endl;*/

    for(int width = UPPER_BOUNDARY; width >= LOWER_BOUNDARY; width -= step) {
     	//cout << "current template: " << width << endl;
        
        char gray_template[35] = "template/template_";
        char size_gray[4];
        snprintf(size_gray, sizeof(size_gray), "%d", width);
        strcat(gray_template, size_gray);
        strcat(gray_template, ".txt");

        //cout << gray_template << endl;
            
        double *I_template = new double[width * width];

        FILE * rach = fopen(gray_template, "rb");
        double val = 0;

        for (int i = 0; i < width; ++i){
            for (int j = 0; j < width; ++j){
                fscanf(rach, "%lf", &val);
                I_template[i * width + j] = val;
            }
        }

        //Face rec:----------------------------------------------------------------------------------------------------------------
        //auto start = chrono::high_resolution_clock::now();

        double *found_boxes = face_recognition(ROWS, COLS, width, width, I_target, I_template, time_extract_hog, time_filter, time_get_gradient, time_build_histogram, time_block_descriptor);
        
        //auto finish = chrono::high_resolution_clock::now();

        //*time_face_rec += chrono::duration_cast<std::chrono::nanoseconds>(finish-start).count();
        
        //--------------------------------------------------------------------------------------------------------------------------------
        
            
        
        num_faces += num_thresholded;   
        found_faces = (double *) realloc(found_faces, sizeof(double)*num_faces*3);

   //     cout << "number_thresholded: " << num_thresholded << " at " << width << endl;
     //   cout << "number_faces: " << num_faces << endl;
        
        for(int i = 0; i < num_thresholded; i++) {
            found_faces[(i+(num_faces-num_thresholded))*3 + 0] = found_boxes[i*3 + 0];
            found_faces[(i+(num_faces-num_thresholded))*3 + 1] = found_boxes[i*3 + 1];
            found_faces[(i+(num_faces-num_thresholded))*3 + 2] = found_boxes[i*3 + 2];


           //cout << "x_ff: " << found_faces[(i+(num_faces-num_thresholded))*3 + 0] << " y_ff: " << found_faces[(i+(num_faces-num_thresholded))*3 + 1] << " score_ff: " <<  found_faces[(i+(num_faces-num_thresholded))*3 + 2] <<  endl;  
        }

        delete [] found_boxes;
        delete [] I_template;

    }

    /*char faces_width[20] = "orig_";
    char width[4];
    snprintf(width, sizeof(width), "%d", W);
    strcat(faces_width, width);
    strcat(faces_width, ".txt");

	write_txt(found_faces, num_faces, faces_width);*/
    
    free(found_faces);

}
