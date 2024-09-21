#include "ip_core.hpp"
#include <tlm>

using namespace sc_core;
using namespace sc_dt;
using namespace std;
using namespace tlm;

SC_HAS_PROCESS(Ip_Core);

Ip_Core::Ip_Core(sc_module_name name):
	sc_module(name),
	core("core"),
	clk("clk", DELAY, sc_core::SC_NS)
{
	interconnect_socket.register_b_transport(this, &Ip_Core::b_transport);
	dram_ctrl_in1_socket.register_b_transport(this, &Ip_Core::b_transport);
	dram_ctrl_in2_socket.register_b_transport(this, &Ip_Core::b_transport);
	dram_ctrl_x_socket.register_b_transport(this, &Ip_Core::b_transport);
	dram_ctrl_y_socket.register_b_transport(this, &Ip_Core::b_transport);


	core.clk(clk.signal());
	core.reset(reset);
	core.start(start);
	core.width(width);
	core.height(height);
	core.width_2(width_2);
	core.width_4(width_4);
	core.bram_height(bram_height);
	core.effective_row_limit(effective_row_limit);
	core.rows_num(rows_num);
	core.cycle_num_limit(cycle_num_limit);
	core.cycle_num_out(cycle_num_out);
	core.axi_hp0_ready_out(axi_hp0_ready_out);
	core.axi_hp0_valid_out(axi_hp0_valid_out);
	core.axi_hp0_strb_out(axi_hp0_strb_out);
	core.axi_hp0_last_out(axi_hp0_last_out);
	core.axi_hp0_last_in(axi_hp0_last_in);
	core.axi_hp0_valid_in(axi_hp0_valid_in);
	core.axi_hp0_strb_in(axi_hp0_strb_in);
	core.axi_hp0_ready_in(axi_hp0_ready_in);
	core.axi_hp1_ready_out(axi_hp1_ready_out);
	core.axi_hp1_valid_out(axi_hp1_valid_out);
	core.axi_hp1_strb_out(axi_hp1_strb_out);
	core.axi_hp1_last_out(axi_hp1_last_out);
	core.axi_hp1_last_in(axi_hp1_last_in);
	core.axi_hp1_valid_in(axi_hp1_valid_in);
	core.axi_hp1_strb_in(axi_hp1_strb_in);
	core.axi_hp1_ready_in(axi_hp1_ready_in);
	core.data_in1(data_in1);
	core.data_in2(data_in2);
	core.data_out1(data_out1);
	core.data_out2(data_out2);
	core.ready( ready );

	start.write(static_cast<sc_logic> (0));
	reset.write(static_cast<sc_logic> (0));
	width.write(static_cast< sc_lv<10> > (0));
	height.write(static_cast< sc_lv<11> > (0));
	width_2.write(static_cast< sc_lv<9> > (0));
	width_4.write(static_cast< sc_lv<8> > (0));
	bram_height.write(static_cast< sc_lv<5> > (0));
	effective_row_limit.write(static_cast< sc_lv<12> > (0));
	rows_num.write(static_cast< sc_lv<10> > (0));
	cycle_num_limit.write(static_cast< sc_lv<6> > (0));
	cycle_num_out.write(static_cast< sc_lv<6> > (0));
	data_in1.write(static_cast< sc_lv<64> > (0));
	data_in2.write(static_cast< sc_lv<64> > (0));
	axi_hp0_ready_out.write(static_cast< sc_logic > (0));
	axi_hp0_last_in.write(static_cast< sc_logic > (0));
	axi_hp0_valid_in.write(static_cast< sc_logic > (0));
	axi_hp0_strb_in.write(static_cast< sc_lv<8> > (0));
	axi_hp1_ready_out.write(static_cast< sc_logic > (0));
	axi_hp1_last_in.write(static_cast< sc_logic > (0));
	axi_hp1_valid_in.write(static_cast< sc_logic > (0));
	axi_hp1_strb_in.write(static_cast< sc_lv<8> > (0));
	
	SC_REPORT_INFO("Ip_Core", "Constructed.");
}

Ip_Core::~Ip_Core()
{
	SC_REPORT_INFO("Ip_Core", "Destroyed.");
}


void Ip_Core::b_transport(pl_t &pl, sc_core::sc_time &offset)
{
	//cout <<" package recieved" << endl;
	
	tlm::tlm_command cmd = pl.get_command();
 	sc_dt::uint64 addr = pl.get_address();
	sc_dt::uint64 taddr;
	unsigned int len = pl.get_data_length();
 	unsigned char *buf = pl.get_data_ptr();
 	pl.set_response_status( tlm::TLM_OK_RESPONSE );
 	
	switch(cmd)
 	{	
	 	case tlm::TLM_WRITE_COMMAND:
			if (addr == ADDR_START)
			{
				start.write(static_cast<sc_logic> (to_int32(buf)));
				printf("write %d in start\n", to_int32(buf));
				wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_RESET)
			{
				reset.write(static_cast<sc_logic> (to_int32(buf)));
				printf("write %d in reset\n", to_int32(buf));
				wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_WIDTH)
			{
				width.write(static_cast< sc_lv<10> > (to_int32(buf)));
				printf("write %d in width\n", to_int32(buf));
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_WIDTH_2)
			{
				width_2.write(static_cast< sc_lv<9> > (to_int32(buf)));
				printf("write %d in width_2\n", to_int32(buf));
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_WIDTH_4)
			{
				width_4.write(static_cast< sc_lv<8> > (to_int32(buf)));
				printf("write %d in width_4\n", to_int32(buf));
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_HEIGHT)
			{
				height.write(static_cast< sc_lv<11> > (to_int32(buf)));
				printf("write %d in height\n", to_int32(buf));
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_BRAM_HEIGHT)
			{
				bram_height.write(static_cast< sc_lv<5> > (to_int32(buf)));
				printf("write %d in bram_height\n", to_int32(buf));
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_EFFECTIVE_ROW_LIMIT)
			{
				effective_row_limit.write(static_cast< sc_lv<12> > (to_int32(buf)));
				printf("write %d in effective_row_limit\n", to_int32(buf));
				wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_ROWS_IN_BRAM)
			{
				rows_num.write(static_cast< sc_lv<10> > (to_int32(buf)));
				printf("write %d in rows_num\n", to_int32(buf));
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_CYCLE_NUM_IN)
			{
				cycle_num_limit.write(static_cast< sc_lv<6> > (to_int32(buf)));
				printf("write %d in cycle_num_limit\n", to_int32(buf));
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_CYCLE_NUM_OUT)
			{
				cycle_num_out.write(static_cast< sc_lv<6> > (to_int32(buf)));
				printf("write %d in cycle_num_out\n", to_int32(buf));
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_DATA_IN1)
			{
				data_in1.write(static_cast< sc_lv<64> > (to_int64(buf)));
				/*cout << "in ip: " << endl;
				bitset<64> x(to_int64(buf));

				cout << x << endl;*/				

				/*cout << "ip_core: "<< to_fixed(buf, 2, 4) << " ";
				cout << " "<< (bitset <16> (to_int(buf))) << " ";
				cout << " "<< (bitset <8> (buf[0]));
				cout << " "<< (bitset <8> (buf[1]));
				cout << endl;
				
				cout << "ip_core: "<< to_fixed(&buf[2], 2, 4);
				cout << endl;

				
				cout << "ip_core: "<< to_fixed(&buf[4], 2, 4);
				cout << endl;

				
				cout << "ip_core: "<< to_fixed(&buf[6], 2, 4);
				cout << endl;*/
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_DATA_IN2)
			{
				data_in2.write(static_cast< sc_lv<64> > (to_int64(buf)));
				/*printf("upakovan 0x%32X in data2\n", to_int64(buf));
				printf("***************************************************\n");
				printf("buf0 0x%02X in data2\n", buf[0]);
				printf("buf1 0x%02X in data2\n", buf[1]);
				printf("buf2 0x%02X in data2\n", buf[2]);
				printf("buf3 0x%02X in data2\n", buf[3]);
				printf("buf4 0x%02X in data2\n", buf[4]);
				printf("buf5 0x%02X in data2\n", buf[5]);
				printf("buf6 0x%02X in data2\n", buf[6]);
				printf("buf7 0x%02X in data2\n", buf[7]);
				printf("\n");*/
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_HP0_LAST_IN)
			{
				axi_hp0_last_in.write(static_cast< sc_logic > (to_int32(buf)));
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_HP0_VALID_IN)
			{
				axi_hp0_valid_in.write(static_cast< sc_logic > (to_int32(buf)));
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_HP0_STRB_IN)
			{
				axi_hp0_strb_in.write(static_cast< sc_lv<8> > (to_int32(buf)));
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_HP1_LAST_IN)
			{
				axi_hp1_last_in.write(static_cast< sc_logic > (to_int32(buf)));
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_HP1_VALID_IN)
			{
				axi_hp1_valid_in.write(static_cast< sc_logic > (to_int32(buf)));
				//wait(DELAY, SC_NS);
			}
			else if (addr == ADDR_HP1_STRB_IN)
			{
				axi_hp1_strb_in.write(static_cast< sc_lv<8> > (to_int32(buf)));
				//wait(DELAY, SC_NS);
			}
			else if(addr == ADDR_HP0_READY_OUT)
			{
				axi_hp0_ready_out.write(static_cast< sc_logic > (to_int32(buf)));
				//wait(DELAY, SC_NS);
			}
			else if(addr == ADDR_HP1_READY_OUT)
			{
				axi_hp1_ready_out.write(static_cast< sc_logic > (to_int32(buf)));
				wait(DELAY, SC_NS);
			}
			else
			{
				pl.set_response_status( tlm::TLM_ADDRESS_ERROR_RESPONSE );
				cout << "Wrong write address!" << endl;
			}
			break;
		case tlm::TLM_READ_COMMAND:
			if (addr == ADDR_STATUS)
			{	wait(DELAY, SC_NS);
				if (ready.read() == '1')
				{
					int_to_uchar(buf, 1);
					//printf("read %d from ready\n", toInt(buf));
				}				
				else
				{
					int_to_uchar(buf, 0);
					//printf("read %d from ready\n", toInt(buf));
				}			
			}
			else if (addr == ADDR_DATA_OUT1)
			{
				int64_to_uchar(buf, static_cast< sc_int<64> > (data_out1.read()));
				
				/*cout << "ip_core: "<< to_fixed(buf);
				cout << endl;
				
				cout << "ip_core: "<< to_fixed(&buf[2]);
				cout << endl;

				
				cout << "ip_core: "<< to_fixed(&buf[4]);
				cout << endl;

				
				cout << "ip_core: "<< to_fixed(&buf[6]);
				cout << endl;*/

			}	
			else if (addr == ADDR_DATA_OUT2)
			{
				int64_to_uchar(buf, static_cast< sc_int<64> > (data_out2.read()));
			}
			else if (addr == ADDR_HP0_STRB_OUT)
			{
				int_to_uchar(buf, static_cast< sc_uint<8> > (axi_hp0_strb_out.read()));
			}
			else if (addr == ADDR_HP0_LAST_OUT)
			{
				if (axi_hp0_last_out.read() == '1')
				{
					int_to_uchar(buf, 1);
				}				
				else
				{
					int_to_uchar(buf, 0);
				}
			}
			else if (addr == ADDR_HP1_STRB_OUT)
			{
				int_to_uchar(buf, static_cast<sc_uint<8>> (axi_hp1_strb_out.read()));	
			}
			else if (addr == ADDR_HP1_LAST_OUT)
			{
				if (axi_hp1_last_out.read() == '1')
				{
					int_to_uchar(buf, 1);
				}				
				else
				{
					int_to_uchar(buf, 0);
				}
			}
			else if(addr == ADDR_HP0_READY_IN)
			{
				if (axi_hp0_ready_in.read() == '1')
				{
					int_to_uchar(buf, 1);
				}				
				else
				{
					int_to_uchar(buf, 0);
				}
			}
			else if(addr == ADDR_HP1_READY_IN)
			{
				if (axi_hp1_ready_in.read() == '1')
				{
					int_to_uchar(buf, 1);
				}				
				else
				{
					int_to_uchar(buf, 0);
				}
			}
			else if(addr == ADDR_HP0_VALID_OUT)
			{
				if (axi_hp0_valid_out.read() == '1')
				{
					int_to_uchar(buf, 1);
				}				
				else
				{
					int_to_uchar(buf, 0);
				}
			}
			else if(addr == ADDR_HP1_VALID_OUT)
			{
				if (axi_hp1_valid_out.read() == '1')
				{
					int_to_uchar(buf, 1);
				}				
				else
				{
					int_to_uchar(buf, 0);
				}
			}
			else
			{
				pl.set_response_status( tlm::TLM_ADDRESS_ERROR_RESPONSE );
				cout << "Wrong read address!" << addr << endl;
			}
			break;
		default:
			pl.set_response_status( tlm::TLM_COMMAND_ERROR_RESPONSE );
			cout << "Wrong command!" << endl;
	}
	
	//offset += sc_core::sc_time(DELAY, sc_core::SC_NS);
}



