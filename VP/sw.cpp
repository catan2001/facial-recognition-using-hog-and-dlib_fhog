#include "sw.hpp"

SC_HAS_PROCESS(SW);

SW::SW(sc_core::sc_module_name name)
    : sc_module(name)
    , offset(sc_core::SC_ZERO_TIME)
{
    num_thresholded = 0;
    num_faces = 0;
    SC_THREAD(process_img);
    SC_REPORT_INFO("Soft", "Constructed.");
}

SW::~SW()
{   
    SC_REPORT_INFO("Soft", "Destroyed.");
}

void SW::process_img(){

    //int rows = 623;
    //int cols = 492;
    //int height = rows/CELL_SIZE;
    //int width = cols/CELL_SIZE;
    int steps = floor((UPPER_BOUNDARY-LOWER_BOUNDARY)/10);
    
    double *gray = new double[ROWS*COLS];
    
    FILE * gray_f = fopen("gray.txt", "rb");
    double tmp_gray;
      for (int i = 0; i < ROWS; ++i){
          for (int j = 0; j < COLS; ++j){
              fscanf(gray_f, "%lf", &tmp_gray);
              gray[i * COLS + j] = tmp_gray;
          }
      }
    fclose(gray_f);
    
    face_recognition_range(&gray[0], steps);
    
}

void SW::read_dram(sc_dt::uint64 addr, num_t2& val)
{
    pl_t pl;
    unsigned char buf[LEN_IN_BYTES];
    pl.set_address(addr | DRAM_BASE_ADDR);
    pl.set_data_length(LEN_IN_BYTES);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_READ_COMMAND);
    pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    interconnect_socket->b_transport(pl, offset);

    val = to_fixed(buf);
    //definisi vrijednost koju citas iz brama
}

void SW::write_dram(sc_dt::uint64 addr, num_t2 val)
{
    pl_t pl;
    unsigned char buf[LEN_IN_BYTES];
    to_uchar(buf, val);
    pl.set_address(addr | DRAM_BASE_ADDR);
    pl.set_data_length(LEN_IN_BYTES);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_WRITE_COMMAND);
    pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    interconnect_socket->b_transport(pl, offset);
}

int SW::read_hard(sc_dt::uint64 addr)
{
    pl_t pl;
    unsigned char buf[LEN_IN_BYTES];
    pl.set_address(addr | HARD_BASE_ADDR);
    pl.set_data_length(LEN_IN_BYTES);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_READ_COMMAND);
    pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    sc_core::sc_time offset = sc_core::SC_ZERO_TIME;
    interconnect_socket->b_transport(pl, offset);
    
    return to_int(buf);
}

void SW::write_hard(sc_dt::uint64 addr, int val)
{
    pl_t pl;
    unsigned char buf[LEN_IN_BYTES];
    int_to_uchar(buf, val); // NOTE: only for int...
    pl.set_address(addr | HARD_BASE_ADDR);
    pl.set_data_length(LEN_IN_BYTES);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_WRITE_COMMAND);
    pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
    interconnect_socket->b_transport(pl, offset);
}

void SW::cast_to_fix(int rows, int cols, matrix_t& dest, orig_array_t& src) {
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

double SW::mean_subtract(int len, double *array) {
    double mean = 0;

    for(int i = 0; i < len; ++i) {
        mean += *(array + i);
    }
    return (mean/len);
}

double SW::array_norm(int len, double *array) {
    double norm = 0;

    for(int i = 0; i < len; ++i)
        norm += ((*(array + i)) * (*(array + i)));
    return sqrt(norm);
}

double SW::array_dot(int len, double *array1, double *array2) {
    double dot = 0;

    for(int i = 0; i < len; ++i){ 
        dot += (*(array1 + i)) * (*(array2 + i));
	}
    return dot;
}

void SW::sort_bounded_boxes(int x, int y, int z, double *array) {
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

double SW::min(double num1, double num2) {
    return (num1 < num2 ? num1 : num2);
}

double SW::max(double num1, double num2) {
    return (num1 > num2 ? num1 : num2);
}
double SW::box_iou(double box1_x, double box1_y, double box2_x, double box2_y, double boxSize) {
    double sumOfAreas = 2*(boxSize*boxSize);
    double box_1[4] = {box1_x, box1_y, box1_x+boxSize, box1_y+boxSize}; 
    double box_2[4] = {box2_x, box2_y, box2_x+boxSize, box2_y+boxSize};
    double intersectionArea = ((min(box_1[2], box_2[2]) - max(box_1[0], box_2[0])) * (min(box_1[3], box_2[3]) - max(box_1[1], box_2[1]))); 

    return (intersectionArea / (sumOfAreas - intersectionArea)); 
}


void SW::find_max(int rows, int cols, double *matrix) {
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

void SW::get_gradient(int rows, int cols, double *im_dx, double *im_dy, double *grad_mag, double *grad_angle){

    double dX, dY;
    
    for(int i=0; i<rows; ++i){
        for(int j=0; j<cols; ++j){
            dX = *(im_dx + i*cols + j);
            dY = *(im_dy + i*cols + j);
            
            //determining the amplitude matrix:
            *(grad_mag + i*cols + j) = sqrt(pow(dX,2)+pow(dY,2));

            //determining the phase matrix:
            if(fabs(dX)>0.00001){
                *(grad_angle + i*cols + j) = atan(dY/dX) + PI/2;
            }else if(dY<0 && dX<0){
                *(grad_angle + i*cols + j) = 0;
            }else{
                *(grad_angle + i*cols + j) = PI;
            }
        }
    }
}

void SW::build_histogram(int rows, int cols, double *grad_mag, double *grad_angle, double *ori_histo){

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


void SW::get_block_descriptor(int rows, int cols, double *ori_histo, double *ori_histo_normalized){
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

//changed so it accepts both filtered by x and y filter
void SW::extract_hog(int rows, int cols, double *im, double *hog) { 
    
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


    //HARDWARE PART OF CODE:
    //Pad image:
    orig_array_t orig_gray(rows, vector<double>(cols));
    
    for (int i=0; i<rows; ++i){
        for (int j=0; j<cols; ++j){
            orig_gray[i][j] = *(im_c + i*cols + j);
        }
    }

    delete [] im_c;
    
    matrix_t matrix_gray(rows, array_t(cols, num_t(W, I, Q, O)));
    matrix_t matrix_im_filtered_y(rows, array_t(cols, num_t(W,I,Q,O)));
    matrix_t matrix_im_filtered_x(rows, array_t(cols, num_t(W,I,Q,O)));
    matrix_t padded_img(rows+2, array_t(cols+2, num_t(W,I,Q,O)));
    cast_to_fix(rows, cols, matrix_gray, orig_gray);

    
    //pad the image on the outer edges with zeros:
    for(int i=0; i<rows+2; ++i) {
        padded_img[i][0]=0;
        padded_img[i][cols+1]=0;
    }

    for(int i=0; i<cols+2; ++i) {
        padded_img[0][i]=0;
        padded_img[rows+1][i]=0;
    }
    
    for (int i=0; i<rows; ++i){
        for (int j=0; j<cols; ++j){
            matrix_im_filtered_y[i][j] = 0;
            matrix_im_filtered_x[i][j] = 0;
            padded_img[i+1][j+1]=matrix_gray[i][j];
        }
    }
  
    // 1 WRITE IMAGE TO DRAM:
    for(int i=0; i<rows+2; ++i){
      for(int j=0; j<cols+2; ++j){
        //cout<<padded_img[i][j]<<" ";
        write_dram(DRAM_LOW_ADDR | i*(cols+2)+j ,padded_img[i][j]);
      }
    }

    // 2 CONFIGURE HW REGISTERS AND SEND START CMD:
    write_hard(ADDR_WIDTH, cols+2);
    write_hard(ADDR_HEIGHT, rows+2);
    write_hard(ADDR_CMD, 1);
    
    for(int i = 0; i<rows; ++i){
        //cout << "I = " << i << endl;
      for(int j = 0; j<cols; ++j){
        read_dram((rows+2)*(cols+2) + 2*cols*i +j, matrix_im_filtered_x[i][j]);
        //cout<<matrix_im_filtered_x[i][j]<<" ";
        read_dram((rows+2)*(cols+2) + (2*i+1)*cols +j, matrix_im_filtered_y[i][j]);
        //cout<<matrix_im_filtered_y[i][j]<<" ";
      }
      //cout<<endl;
    }
    
    cout << "HARDWARE FINISHED!!!" << endl << endl;


    double *im_dx = new double[rows * cols];
    double *im_dy = new double[rows * cols];
    double *grad_mag = new double[rows * cols];
    double *grad_angle = new double[rows * cols];
   
 
   for(int i=0; i<rows; ++i){
   	for(int j=0; j<cols; ++j){
		*(im_dx + i*cols + j) = matrix_im_filtered_x[i][j];
	        *(im_dy + i*cols + j) = matrix_im_filtered_y[i][j];	
	}
    }
 
    get_gradient(rows, cols, &im_dx[0], &im_dy[0], &grad_mag[0], &grad_angle[0]);

    int height = rows/CELL_SIZE;
    int width = cols/CELL_SIZE;
 
    double *ori_histo = new double[(int)height * (int)width * nBINS];

    build_histogram(rows, cols, &grad_mag[0], &grad_angle[0], &ori_histo[0]);
    
    // TODO: Make makro to replace underneath
    double *ori_histo_normalized = new double[(height-(BLOCK_SIZE-1)) * (width-(BLOCK_SIZE-1)) * nBINS*(BLOCK_SIZE*BLOCK_SIZE)];   

    get_block_descriptor(rows, cols, &ori_histo[0], &ori_histo_normalized[0]);
    
    int HOG_LEN = (height-1) * (width-1) * (nBINS*BLOCK_SIZE*BLOCK_SIZE);
    int i = nBINS*BLOCK_SIZE*BLOCK_SIZE*(width-1);

    for(int l = 0; l < HOG_LEN; ++l){
        hog[l] = ori_histo_normalized[(int)(l/i)*(width-(BLOCK_SIZE-1))*nBINS*(BLOCK_SIZE*BLOCK_SIZE) + (int)((l/24)%(width-1))*nBINS*(BLOCK_SIZE*BLOCK_SIZE) + l%24];
        #ifdef DEBUG
            if(hog[l] != hog[l]) cout << "hogl NAN" << endl;
        #endif   
    }

    // deallocate allocated
    delete [] im_dx;
    delete [] im_dy;
    delete [] grad_mag;
    delete [] grad_angle;
    delete [] ori_histo;
    delete [] ori_histo_normalized;
}


double *SW::face_recognition(int img_h, int img_w, int box_h, int box_w, double *I_target, double *I_template) {
    
    int hog_len = ((int)(box_h/8) - 1)*((int)(box_w/8)-1)*24;    
    double *template_HOG = new double[((int)(box_h/8)-1)*((int)(box_w/8)-1)*24];

    extract_hog(box_h, box_w, &(I_template[0]), template_HOG);

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

            extract_hog(box_h, box_w, &img_window[0], &img_HOG[0]);    
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


void SW::face_recognition_range(double *I_target, int step) {
   
    double *found_faces = (double *) malloc(sizeof(double)*3);
    num_faces = 0;

    for(int width = UPPER_BOUNDARY; width >= LOWER_BOUNDARY; width -= step) {
     	cout << "current template: " << width << endl;
        
        char gray_template[50] = "fixed_point_analysis/template/template_";
        char size_gray[4];
        snprintf(size_gray, sizeof(size_gray), "%d", width);
        strcat(gray_template, size_gray);
        strcat(gray_template, ".txt");

        cout << gray_template << endl;
            
        double *I_template = new double[width * width];

        FILE * rach = fopen(gray_template, "rb");
        double val = 0;

        for (int i = 0; i < width; ++i){
            for (int j = 0; j < width; ++j){
                fscanf(rach, "%lf", &val);
                I_template[i * width + j] = val;
            }
        }

        double *found_boxes = face_recognition(ROWS, COLS, width, width, I_target, I_template);
        num_faces += num_thresholded;   
        found_faces = (double *) realloc(found_faces, sizeof(double)*num_faces*3);

   //     cout << "number_thresholded: " << num_thresholded << " at " << width << endl;
     //   cout << "number_faces: " << num_faces << endl;
        
        for(int i = 0; i < num_thresholded; i++) {
            found_faces[(i+(num_faces-num_thresholded))*3 + 0] = found_boxes[i*3 + 0];
            found_faces[(i+(num_faces-num_thresholded))*3 + 1] = found_boxes[i*3 + 1];
            found_faces[(i+(num_faces-num_thresholded))*3 + 2] = found_boxes[i*3 + 2];


           cout << "x_ff: " << found_faces[(i+(num_faces-num_thresholded))*3 + 0] << " y_ff: " << found_faces[(i+(num_faces-num_thresholded))*3 + 1] << " score_ff: " <<  found_faces[(i+(num_faces-num_thresholded))*3 + 2] <<  endl;  
        }

        delete [] found_boxes;
        delete [] I_template;

    }

    char faces_width[20] = "orig_";
    char width[4];
    snprintf(width, sizeof(width), "%d", W);
    strcat(faces_width, width);
    strcat(faces_width, ".txt");

	write_txt(found_faces, num_faces, faces_width);
    
    free(found_faces);
}
