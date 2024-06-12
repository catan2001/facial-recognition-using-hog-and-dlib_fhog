#ifndef DEF_HPP
#define DEF_HPP
#include </home/andjela/systemc-2.3.3/include/sysc/datatypes/fx/sc_fixed.h>
#define SC_INCLUDE_FX
#include <systemc>
#include <tlm>

#define W 32 // DATA_WIDTH
#define I 16 // FIXED_POINT_WIDTH
#define Q sc_dt::SC_TRN // quantization methods
#define O sc_dt::SC_WRAP // overflow methods

typedef sc_dt::sc_fixed_fast <W, I, Q, O> num_t;
typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;

#define BRAM_BASE_ADDR 0x01000000
#define BRAM_LOW_ADDR 0x01000000
#define BRAM_HIGH_ADDR 0x01100000
#define HARD_BASE_ADDR 0x02000000
#define HARD_LOW_ADDR 0x02000008
#define HARD_HIGH_ADDR 0x0200001c

#define ADDR_WIDTH 0x08
#define ADDR_HEIGHT 0x10
#define ADDR_CMD 0x18
#define ADDR_STATUS 0x1c

//#define MAX_SIZE 200
#define ROWS 150
#define COLS 150
#define nBINS 6
#define CELL_SIZE 8
#define CELL_POW (CELL_SIZE*CELL_SIZE)
#define BLOCK_SIZE 2

#define HEIGHT (ROWS/CELL_SIZE)
#define WIDTH (COLS/CELL_SIZE)

#define HIST_SIZE nBINS*BLOCK_SIZE*BLOCK_SIZE

#define PI 3.14159265358979323846

#define RESERVED_MEM 100000

#endif
