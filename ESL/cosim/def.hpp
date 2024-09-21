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
#define HARD_HIGH_ADDR 0x42000100
//DRAM & DRAM_CTRL
#define DRAM_BASE_ADDR 0x00000000 // Start Address of DRAM
#define DRAM_LOW_ADDR 0x00000000
#define DRAM_HIGH_ADDR 0x3fffffff // End Address of DRAM

#define ADDR_WIDTH 0x00
#define ADDR_HEIGHT 0x04
#define ADDR_START 0x08
#define ADDR_STATUS 0x0c
#define ADDR_INPUT_REG 0x10
#define ADDR_EFFECTIVE_ROW_LIMIT 0x14
#define ADDR_RESET 0x18
#define ADDR_CONFIG 0x1c

#define ADDR_WIDTH_2 0x20
#define ADDR_WIDTH_4 0x24
#define ADDR_CYCLE_NUM_IN 0x28
#define ADDR_CYCLE_NUM_OUT 0x2c
#define ADDR_DRAM_IN 0x30
#define ADDR_DRAM_X 0x34
#define ADDR_DRAM_Y 0x38
#define ADDR_ROWS_IN_BRAM 0x3c
#define ADDR_BRAM_HEIGHT 0x40

//write
#define ADDR_DATA_IN1 0X44
#define ADDR_DATA_IN2 0x48

//read
#define ADDR_DATA_OUT1 0X4c
#define ADDR_DATA_OUT2 0x50

//write
#define ADDR_HP0_LAST_IN 0x54
#define ADDR_HP0_VALID_IN 0x58
#define ADDR_HP0_STRB_IN 0x5c
#define ADDR_HP1_LAST_IN 0x60
#define ADDR_HP1_VALID_IN 0x64
#define ADDR_HP1_STRB_IN 0x68
#define ADDR_HP0_READY_OUT 0x6c
#define ADDR_HP1_READY_OUT 0x70

//read
#define ADDR_HP0_STRB_OUT 0x58
#define ADDR_HP0_LAST_OUT 0x5c
#define ADDR_HP0_VALID_OUT 0x60
#define ADDR_HP0_READY_IN 0x64
//read
#define ADDR_HP1_LAST_OUT 0x68
#define ADDR_HP1_STRB_OUT 0x6c
#define ADDR_HP1_VALID_OUT 0x70
#define ADDR_HP1_READY_IN 0x74

#define ADDR_DATA_OUT 0x7800
#define ADDR_DATA_IN 0x7c00
#define ADDR_COLS 0x8c00
#define ADDR_ROWS 0x9000

#define WRITE_IMG 0x8000
#define READ_DX 0x8400
#define READ_DY 0x8800

/*
#define ADDR_SAHE1 0x20
#define ADDR_SAHE2 0x24
#define ADDR_SAHE3 0x28
#define ADDR_SAHE4 0x2c
#define ADDR_SAHE5 0x30
#define ADDR_SAHE6 0x34
*/

//#define MAX_SIZE 200
#define ROWS 150
#define COLS 150
#define nBINS 6
#define CELL_SIZE 8
#define CELL_POW (CELL_SIZE*CELL_SIZE)
#define BLOCK_SIZE 2
#define HIST_SIZE nBINS*BLOCK_SIZE*BLOCK_SIZE

#define UPPER_BOUNDARY (ROWS > COLS ? COLS : ROWS)
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
#define DATA_LEN_IN_BYTES 8
#define W 16 // DATA_WIDTH
#define I 4 // FIXED_POINT_WIDTH
#define I_IN 1 // FIXED_POINT_WIDTH
#define Q sc_dt::SC_RND // quantization methods
#define O sc_dt::SC_SAT // overflow methods

typedef std::vector<std::vector<double>> orig_array_t;
typedef sc_dt::sc_fixed_fast <W, I, Q, O> output_t; // bit-width 16, INT part 4
typedef std::deque<output_t> out_array_t;           // array of 16,4
typedef std::deque<out_array_t> out_matrix_t;       // matrix of 16,4

typedef sc_dt::sc_fixed_fast <W, I_IN, Q, O> input_t; // bit-width 16, INT part 4
typedef std::deque<input_t> in_array_t;           // array of 16,4
typedef std::deque<in_array_t> in_matrix_t;       // matrix of 16,4

typedef sc_dt::sc_int  <32> s32_t;  // bit_width 32
typedef sc_dt::sc_uint <32> u32_t;  // bit_width 32
typedef sc_dt::sc_uint <W>  u16_t;  // bit-width 16
typedef sc_dt::sc_uint <11>  u11_t;  // bit-width 11
typedef sc_dt::sc_uint <10> u10_t;  // bit_width 10
typedef sc_dt::sc_uint <9> u9_t;  // bit_width 9
typedef sc_dt::sc_uint <8> u8_t;  // bit_width 8
typedef sc_dt::sc_uint <6>  u6_t;   // bit-width 6
typedef sc_dt::sc_uint <1>  u1_t;   // bit-width 1
typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
#endif

