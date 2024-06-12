#include "utils.hpp"

int to_int (unsigned char *buf)
{
  int sum = 0;
  sum += ((int)buf[0]) << 24;
  sum += ((int)buf[1]) << 16;
  sum += ((int)buf[2]) << 8;
  sum += ((int)buf[3]);
  return sum;
}

void build_histogram(int rows, int cols, double *grad_mag, double *grad_angle, double *ori_histo){

    double magROI[CELL_POW], angleROI[CELL_POW];
    double angleInDeg;
    for(int i = CELL_SIZE; i <= rows; i+=CELL_SIZE){
        for(int j = CELL_SIZE; j <= cols; j+=CELL_SIZE){
            double hist[nBINS]={0, 0, 0, 0, 0, 0};

            for(int k = 0; k < CELL_POW; ++k){
                magROI[k]= *(grad_mag + (i-CELL_SIZE+(int)(k/CELL_SIZE))*cols + j-CELL_SIZE+(k%CELL_SIZE));
                if(magROI[k] != magROI[k]) cout << "NAN! -> " << k << " = " << magROI[k] << endl;

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

            for(int k=0; k<nBINS; ++k){
                                       *(ori_histo + ((int)(i-CELL_SIZE)/CELL_SIZE) * nBINS * (int)(cols/CELL_SIZE) + ((int)(j-CELL_SIZE)/CELL_SIZE)*nBINS + k) = hist[k]; 
                                       cout<<hist[k]<<" ";}

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

            for(int k = 0; k < HIST_SIZE; ++k) *(ori_histo_normalized + (i-BLOCK_SIZE)*((cols/CELL_SIZE)-(BLOCK_SIZE-1))*nBINS*BLOCK_SIZE*BLOCK_SIZE 
                                               + (j-BLOCK_SIZE)*nBINS*BLOCK_SIZE*BLOCK_SIZE + k )= concatednatedHist[k] / histNorm;  

        }
    }
}

