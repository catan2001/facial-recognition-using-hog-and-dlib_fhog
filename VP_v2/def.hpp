#ifndef DEF_HPP
#define DEF_HPP
//#include </usr/local/systemc-2.3.4/include/sysc/datatypes/fx/sc_fixed.h>
//#define SC_INCLUDE_FX
#include <systemc>
#include <tlm>

//BRAM & BRAM_CTRL
#define BRAM_BASE_ADDR 0x40000000 // PL AXI Slave port 0 starts at 0x40000000   
#define BRAM_LOW_ADDR 0x40000000
#define BRAM_HIGH_ADDR 0x41087600 //554496 TODO: check value
//HARD
#define HARD_BASE_ADDR 0x42000000
#define HARD_LOW_ADDR 0x42000000
#define HARD_HIGH_ADDR 0x42000018
//DRAM & DRAM_CTRL
#define DRAM_BASE_ADDR 0x00000000 // Start Address of DRAM
#define DRAM_LOW_ADDR 0x00000000
#define DRAM_HIGH_ADDR 0x3fffffff // End Address of DRAM

#define ADDR_WIDTH 0x00
#define ADDR_HEIGHT 0x04
#define ADDR_START 0x08
#define ADDR_STATUS 0x0c
#define ADDR_INPUT_REG 0x10
#define ADDR_ACC_LOSS 0x14
#define ADDR_RESET 0x18
#define ADDR_CONFIG 0x1c

//#define MAX_SIZE 200
#define ROWS 365
#define COLS 300
#define nBINS 6
#define CELL_SIZE 8
#define CELL_POW (CELL_SIZE*CELL_SIZE)
#define BLOCK_SIZE 2
#define HIST_SIZE nBINS*BLOCK_SIZE*BLOCK_SIZE

#define UPPER_BOUNDARY (ROWS > COLS ? COLS : ROWS)
#define LOWER_BOUNDARY (floor(UPPER_BOUNDARY/3))
#define THRESHOLD 0.6 // TODO: CHANGE AS NEEDED!
#define SUPPRESSION 0.5 // TODO: CHANGE AS NEEDED!

#define HEIGHT (ROWS/CELL_SIZE)
#define WIDTH (COLS/CELL_SIZE)

#define BRAM_HEIGHT 16 //60th BRAM is used for registers //((ROWS > 128)? 128 : ROWS)
#define BRAM_WIDTH 2048 // depth of one BRAM_block

#define NUM_PARALLEL_POINTS 8
#define PTS_PER_ROW 2
#define PTS_PER_COL 4
#define REG24 24

#define PI 3.14159265358979323846

#define RESERVED_MEM BRAM_WIDTH*BRAM_HEIGHT

#define DELAY_IC 2
#define DELAY 7.5
#define LEN_IN_BYTES 2
#define W 16 // DATA_WIDTH
#define I 4 // FIXED_POINT_WIDTH
#define Q sc_dt::SC_RND // quantization methods
#define O sc_dt::SC_SAT // overflow methods

typedef std::vector<std::vector<double>> orig_array_t;
typedef sc_dt::sc_fixed_fast <W, I, Q, O> output_t; // bit-width 16, INT part 4
typedef std::deque<output_t> out_array_t;           // array of 16,4
typedef std::deque<out_array_t> out_matrix_t;       // matrix of 16,4

typedef sc_dt::sc_int  <32> s32_t;  // bit_width 32
typedef sc_dt::sc_uint <32> u32_t;  // bit_width 32
typedef sc_dt::sc_uint <W>  u16_t;  // bit-width 16
typedef sc_dt::sc_uint <11>  u11_t;  // bit-width 11
typedef sc_dt::sc_uint <6>  u6_t;   // bit-width 6
typedef sc_dt::sc_uint <1>  u1_t;   // bit-width 1
typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
#endif
