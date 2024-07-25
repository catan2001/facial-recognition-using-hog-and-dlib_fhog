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

void write_txt(double* found_faces, int len, char *name_txt){
	
	FILE *fp;
	
  	fp = fopen(name_txt, "wb");

    	for(int i=0; i<len; ++i){
	       	fprintf(fp, "x: %.0lf y: %.0lf score: %.4lf \n", found_faces[i*3], found_faces[3*i+1], found_faces[3*i+2]);
    	//	printf("x: %.2lf y: %.2lf score: %.4lf \n", found_faces[i*3], found_faces[3*i+1], found_faces[3*i+2]);
	}
	fclose(fp);

}

void cast_to_fix(int rows, int cols, matrix_t& dest, orig_array_t& src) {
    for(int i = 0; i != rows; ++i) {
        for (int j = 0; j != cols; ++j) {
            num_t d(W, I);
            d = src[i][j];
            if(d.overflow_flag())
                std::cout << "Overflow!" << endl;
            dest[i][j] = d;
        }
    }
}

void cast_to_fix(int rows, int cols, out_matrix_t& dest, orig_array_t& src) {
    for(int i = 0; i != rows; ++i) {
        for (int j = 0; j != cols; ++j) {
            output_t d;
            d = src[i][j];
            if(d.overflow_flag())
                std::cout << "Overflow!" << endl;
            dest[i][j] = d;
        }
    }
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
