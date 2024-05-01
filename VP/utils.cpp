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

void build_histogram(num_t grad_mag[ROWS][COLS], num_t grad_angle[ROWS][COLS], num_t ori_histo[ROWS / CELL_SIZE][COLS / CELL_SIZE][nBINS]) {

    int cell_pow2 = CELL_SIZE * CELL_SIZE;
    num_t magROI[cell_pow2], angleROI[cell_pow2];

    num_t angleInDeg;

    for (int i = CELL_SIZE; i <= ROWS; i += CELL_SIZE) {
        for (int j = CELL_SIZE; j <= COLS; j += CELL_SIZE) {
            num_t hist[nBINS] = { 0, 0, 0, 0, 0, 0 };

            for (int k=0; k<cell_pow2; ++k) {
                magROI[k] = grad_mag[i-CELL_SIZE+(int)(k/CELL_SIZE)][j-CELL_SIZE+(k%CELL_SIZE)];
                angleROI[k] = grad_angle[i-CELL_SIZE+(int)(k/CELL_SIZE)][j-CELL_SIZE+(k%CELL_SIZE)];

                angleInDeg = angleROI[k]*(180.0/PI);

                if (angleInDeg >= 0.0 && angleInDeg < 30.0) {
                    hist[0] += magROI[k];
                }
                else if (angleInDeg >= 30.0 && angleInDeg < 60.0) {
                    hist[1] += magROI[k];
                }
                else if (angleInDeg >= 60.0 && angleInDeg < 90.0) {
                    hist[2] += magROI[k];
                }
                else if (angleInDeg >= 90.0 && angleInDeg < 120.0) {
                    hist[3] += magROI[k];
                }
                else if (angleInDeg >= 120.0 && angleInDeg < 150.0) {
                    hist[4] += magROI[k];
                }
                else {
                    hist[5] += magROI[k];
                }
            }

            for (int k=0; k<nBINS; ++k) ori_histo[(int)(i-CELL_SIZE)/CELL_SIZE][(int)(j-CELL_SIZE)/CELL_SIZE][k] = hist[k];

        }
    }
}

void get_gradient(num_t im_dx[ROWS][COLS], num_t im_dy[ROWS][COLS], num_t grad_mag[ROWS][COLS], num_t grad_angle[ROWS][COLS]) {

    num_t dX, dY;
    for (int i = 0; i<ROWS; ++i) {
        for (int j = 0; j < COLS; ++j) {
            dX = im_dx[i][j];
            dY = im_dy[i][j];

            grad_mag[i][j] = sqrt(pow(dX,2) + pow(dY,2));

            if (fabs(dX) > 0.00001) {
                grad_angle[i][j] = atan((float)dY / dX) + PI / 2;
            }
            else if (dY < 0 && dX < 0) {
                grad_angle[i][j] = 0;
            }
            else {
                grad_angle[i][j] = PI;
            }

        }
    }

}

void get_block_descriptor(num_t ori_histo[ROWS/CELL_SIZE][COLS/CELL_SIZE][nBINS], num_t ori_histo_normalized[HEIGHT-(BLOCK_SIZE-1)][WIDTH-(BLOCK_SIZE-1)][nBINS*(BLOCK_SIZE*BLOCK_SIZE)]) {

    for (int i = BLOCK_SIZE; i <= HEIGHT; i += BLOCK_SIZE) {
        for (int j = BLOCK_SIZE; j <= WIDTH; j += BLOCK_SIZE) {
            num_t concatednatedHist[HIST_SIZE];
            num_t concatednatedHist2[HIST_SIZE];
            num_t histNorm = 0.0;

            for (int k = 0; k < HIST_SIZE; ++k) {
                concatednatedHist[k] = (float)ori_histo[i-BLOCK_SIZE+(int)k/12][j-BLOCK_SIZE+((int)k/6)%2][(k%6)];
                concatednatedHist2[k] = concatednatedHist[k]*concatednatedHist[k];
                histNorm += concatednatedHist2[k];
            }
            histNorm += 0.001;
            histNorm = sqrt(histNorm);
 
 
            for (int k=0; k<HIST_SIZE; ++k) ori_histo_normalized[i-BLOCK_SIZE][j-BLOCK_SIZE][k] = concatednatedHist[k]/histNorm;
        }
    }
}


