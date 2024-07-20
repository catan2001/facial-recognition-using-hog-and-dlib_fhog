#include "sw.hpp"

SC_HAS_PROCESS(SW);

SW::SW(sc_core::sc_module_name name)
    : sc_module(name)
    , offset(sc_core::SC_ZERO_TIME)
{
    SC_THREAD(process_img);
    SC_REPORT_INFO("Soft", "Constructed.");
}

SW::~SW()
{   
    SC_REPORT_INFO("Soft", "Destroyed.");
}

void SW::process_img(){

    int rows = 450;
    int cols = 450;
    int height = rows/CELL_SIZE;
    int width = cols/CELL_SIZE;
    
    double *gray = new double[rows*cols];
    
    FILE * gray_f = fopen("gray450.txt", "rb");
    double tmp_gray;
      for (int i = 0; i < ROWS; ++i){
          for (int j = 0; j < COLS; ++j){
              fscanf(gray_f, "%lf", &tmp_gray);
              gray[i * COLS + j] = tmp_gray;
          }
      }
    fclose(gray_f);
    
    double im_min = *(gray + 0)/255.00000000;
    double im_max = *(gray + 0)/255.00000000;
    
    double *im_c = new double[rows*cols];
    
    for(int i = 0; i < rows; ++i){
      for(int j = 0; j < cols; ++j){
          *(im_c + i*cols + j) = *(gray + i*cols +j);
          *(im_c + i*cols + j) = *(im_c + i*cols + j)/255.0; // converting to double format
          if(im_min > *(im_c + i*cols + j)) im_min = *(im_c + i*cols + j); // find min im
          if(im_max < *(im_c + i*cols + j)) im_max = *(im_c + i*cols + j); // find max im
      }
    }
    
    delete [] gray;

    for(int i = 0; i < rows; ++i){
        for(int j = 0; j < cols; ++j){
            *(im_c + i*cols + j) = (*(im_c + i*cols + j) - im_min) / im_max; // Normalize image to [0, 1]
        }
    }
    
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
    matrix_t padded_img(rows+2, array_t(cols+2));
    cast_to_fix(rows, cols, matrix_gray, orig_gray, W, I);

    
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
   
    //test:

    /*const char * name_txt = "padded_img.txt";

    mat_txt(name_txt, &padded_img, rows+2, cols+2);*/


    /*for(int i=0; i<rows+2; ++i){
      for(int j=0; j<cols+2; ++j){
        cout<<padded_img[i][j]<<" ";
        //padded_img[i][j];
      }
      cout << endl;
      cout << "i: " << i << endl;
    } 
    cout << endl << endl << endl;*/

    // 1 WRITE IMAGE TO DRAM:
    for(int i=0; i<rows+2; ++i){
      for(int j=0; j<cols+2; ++j){
        //cout<<padded_img[i][j]<<" ";
        write_dram(DRAM_LOW_ADDR | i*(cols+2)+j ,padded_img[i][j]);
      }
    }

    // 2 CONFIGURE HW REGISTERS AND SEND START CMD:
    write_hard(ADDR_WIDTH, ROWS+2);
    write_hard(ADDR_HEIGHT, COLS+2);
    write_hard(ADDR_CMD, 1);
    
    for(int i = 0; i<ROWS; ++i){
        cout << "I = " << i << endl;
      for(int j = 0; j<COLS; ++j){
        read_dram((ROWS+2)*(COLS+2) + 2*COLS*i +j, matrix_im_filtered_x[i][j]);
        //cout<<matrix_im_filtered_x[i][j]<<" ";
        read_dram((ROWS+2)*(COLS+2) + (2*i+1)*COLS +j, matrix_im_filtered_y[i][j]);
        cout<<matrix_im_filtered_y[i][j]<<" ";
      }
      cout<<endl;
    }
    
    cout << "HARDWARE FINISHED!!!" << endl << endl;
    
    
    // 3 WAIT FOR HW TO FINISH:
    /*int ready = 1;
    while (!ready)
    {
      ready = read_hard(ADDR_STATUS);
    }
    write_hard(ADDR_CMD, 0);*/

    // 4 READ RESULTS FROM DRAM:
    /*
    num_t2 val;
    for(int i=0; i<rows+2; ++i){
      for(int j=0; j<cols+2; ++j){
        //cout<<padded_img[i][j]<<" ";
        read_dram(DRAM_LOW_ADDR | i*(cols+2)+j, val);
        cout << val << " ";
      }
    }
    */
    /*
    write_hard(ADDR_WIDTH, ROWS);
    write_hard(ADDR_HEIGHT, COLS);
    write_hard(ADDR_CMD, 1);
    
    int ready = 1;
    while (ready)
    {
      ready = read_hard(ADDR_STATUS);
    }
    write_hard(ADDR_CMD, 0);
    while (!ready)
    {
      ready = read_hard(ADDR_STATUS);
    }

    cout<<"SLIKA JE FILTRIRANA"<<endl;
     */
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

/*void SW::mat_txt(const char * name_txt, matrix_t * matrix, int rows, int cols){ 
    //FILE * ptr;
    //ptr = fopen(name_txt, "wb"); 

    num_t2 temp = 0;
    double zero;

    std::ofstream out(name_txt);
    std::streambuf *coutbuf = std::cout.rdbuf(); //save old buf
    std::cout.rdbuf(out.rdbuf());
 
    for (int i=0; i<rows; ++i){ 
        for (int j=0; j<cols; ++j){ 
            zero = matrix[i][j];
            cout << zero << " ";
            //fprintf(ptr, "%3.13f ", zero); 
        } 
        cout << endl;
        //fprintf(ptr, "\n"); 

    } 

     std::cout.rdbuf(coutbuf);
    //fclose(ptr); 
} */
