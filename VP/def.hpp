#ifndef DEF_HPP
#define DEF_HPP
//#include </usr/local/systemc-2.3.4/include/sysc/datatypes/fx/sc_fixed.h>
//#define SC_INCLUDE_FX
#include <systemc>
#include <tlm>

#define LEN_IN_BYTES 2
#define W 16 // DATA_WIDTH
#define I 3 // FIXED_POINT_WIDTH
#define Q sc_dt::SC_RND // quantization methods
#define O sc_dt::SC_SAT // overflow methods

typedef sc_dt::sc_fix_fast num_t;
typedef sc_dt::sc_fixed_fast <W, I ,Q ,O> num_t2;
typedef std::vector<num_t> array_t2;
typedef std::deque<num_t2> array_t;
typedef std::deque<array_t> matrix_t;
typedef std::vector<std::vector<double>> orig_array_t;

typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;

//BRAM & BRAM_CTRL
#define BRAM_BASE_ADDR 0x40000000 // PL AXI Slave port 0 starts at 0x40000000   
#define BRAM_LOW_ADDR 0x40000000
#define BRAM_HIGH_ADDR 0x41087600 //554496 TODO: check value
//HARD
#define HARD_BASE_ADDR 0x42000000
#define HARD_LOW_ADDR 0x42000000
#define HARD_HIGH_ADDR 0x4200000c
//DRAM & DRAM_CTRL
#define DRAM_BASE_ADDR 0x00000000 // Start Address of DRAM
#define DRAM_LOW_ADDR 0x00000000
#define DRAM_HIGH_ADDR 0x3fffffff // End Address of DRAM

#define ADDR_WIDTH 0x00
#define ADDR_HEIGHT 0x04
#define ADDR_CMD 0x08
#define ADDR_STATUS 0x0c
#define ADDR_INPUT_REG 0x10

//#define MAX_SIZE 200
#define ROWS 150
#define COLS 150
#define nBINS 6
#define CELL_SIZE 8
#define CELL_POW (CELL_SIZE*CELL_SIZE)
#define BLOCK_SIZE 2

#define HEIGHT (ROWS/CELL_SIZE)
#define WIDTH (COLS/CELL_SIZE)

#define BRAM_HEIGHT 59 //60th BRAM is used for registers //((ROWS > 128)? 128 : ROWS)
#define BRAM_WIDTH 2048 // depth of one BRAM_block

#define NUM_PARALLEL_POINTS 9
#define KERNEL_SIZE 3

#define REG36 36

#define HIST_SIZE nBINS*BLOCK_SIZE*BLOCK_SIZE

#define PI 3.14159265358979323846

#define RESERVED_MEM 2048*59//100000

#endif
