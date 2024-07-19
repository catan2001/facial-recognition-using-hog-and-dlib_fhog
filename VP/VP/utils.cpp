#include "utils.hpp"

int to_int (unsigned char *buf)
{
  int sum = 0;
//  sum += ((int)buf[0]) << 24;
//  sum += ((int)buf[1]) << 16;
  sum += ((int)buf[0]) << 8;
  sum += ((int)buf[1]);
  return sum;
}

num_t2 concat (unsigned char buf_high, unsigned char buf_low)
{
  num_t2 sum = 0;
  sum += ((num_t2)buf_high) << 8;
  sum += ((num_t2)buf_low);
  return sum;
}

char flip(char c) {return (c == '0')? '1': '0';}

string twos_complement(string bin)
{
  int n = bin.length();
  int i;

  string ones, twos;
  ones = twos = "";

  //  for ones complement flip every bit
  for (i = 0; i < n; i++)
    ones += flip(bin[i]);

  //  for two's complement go from right to left in
  //  ones complement and if we get 1 make, we make
  //  them 0 and keep going left when we get first
  //  0, make that 1 and go out of loop
  twos = ones;
  for (i = n - 1; i >= 0; i--)
    {
      if (ones[i] == '1')
        twos[i] = '0';
      else
        {
          twos[i] = '1';
          break;
        }
    }

  // If No break : all are 1  as in 111  or  11111;
  // in such case, add extra 1 at beginning
  if (i == -1)
    twos = '1' + twos;

  // cout << "1's complement: " << ones << endl;
  // cout << "2's complement: " << twos << endl; 
  return twos;
}



double to_fixed (unsigned char *buf)
{
  string concated = "";
  for (int i = 0; i<CHARS_AMOUNT; ++i) {// concatenate char array into eg. "10101101000"
    concated += bitset<CHAR_LEN>((int)buf[i]).to_string();
  }

  double multiplier = 1;
  if (concated[0] == '1')
  {
      concated = twos_complement(concated);
      multiplier = -1;
  }

  double sum = 0;
  int tmp = 0;
  
  for (int i = 0; i<DATA_WIDTH; ++i)
    {
      tmp = (I - i - 1);
      sum += (concated[i]-'0') * pow(2.0, tmp);
    }

  return sum*multiplier;
}

void to_char (unsigned char *buf, string s)
{
  s.erase(0,2);
  s.erase(3, 1);
  char single_char[CHAR_LEN];
  for (int i = 0; i<CHARS_AMOUNT; ++i)
    {
      s.copy(single_char,CHAR_LEN,i*CHAR_LEN);
      int char_int = stoi(single_char, nullptr, 2);
      buf[i] = (unsigned char) char_int;
    } 
}

void to_uchar(unsigned char *c, num_t2 d)
{
  to_char(c,d.to_bin());
}

void int_to_uchar(unsigned char *buf, int num) {
    buf[0] = (num & 0xFF00) >> 8;
    buf[1] = (num & 0x00FF);
}

void cast_to_fix(int rows, int cols, matrix_t& dest, orig_array_t& src, int width, int integer) {
    for(int i = 0; i != rows; ++i) {
        for (int j = 0; j != cols; ++j) {
            num_t d(width, integer);
            d = src[i][j];
            if(d.overflow_flag())
                std::cout << "Overflow!" << endl;
            dest[i][j] = d;
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
