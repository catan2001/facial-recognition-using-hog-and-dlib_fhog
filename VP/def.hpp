#ifndef DEF_HPP
#define DEF_HPP

#include "systemc.h"
#include <tlm>

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

#define MAX_SIZE 200

#define RESERVED_MEM 100000

#define SC_INCLUDE_FX
//popraviti poslije bitske
#define W 32 // DATA_WIDTH
#define I 16 // FIXED_POINT_WIDTH
#define Q sc_dt::SC_TRN // quantization methods: SC_RND_ZERO, SC_RND_MIN_INF, SC_RND_INF, SC_RND_CONV, SC_TRN, SC_TRN_ZERO
#define O sc_dt::SC_WRAP // overflow methods: SC_SAT_ZERO, SC_SAT_SYM, SC_WRAP, SC_WRAP_SYM

typedef sc_dt::sc_fixed_fast <W, I, Q, O> num_t; //stavi odgovarajuce parametre poslije bitske
typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;

#endif