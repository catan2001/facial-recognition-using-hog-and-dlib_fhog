#include "dram_ctrl.hpp"

DramCtrl::DramCtrl(sc_core::sc_module_name name) : sc_module(name) {
    interconnect_socket.register_b_transport(this, &DramCtrl::b_transport);  
    SC_REPORT_INFO("DRAM Controller", "Constructed.");
}

DramCtrl::~DramCtrl(){
    SC_REPORT_INFO("DRAM Controller", "Destroyed.");
}

void DramCtrl::b_transport(pl_t &pl, sc_core::sc_time &offset)
{
    tlm::tlm_command cmd = pl.get_command();
    sc_dt::uint64 addr = pl.get_address();
    sc_dt::uint64 addr_pos = pl.get_address();
    unsigned int len = pl.get_data_length();
    unsigned char *buf = pl.get_data_ptr(); 
    unsigned int len_data = DATA_LEN_IN_BYTES;
    addr = addr & 0xFF00;
    addr_pos = addr_pos & 0x00FF;
    switch(cmd){
	case tlm::TLM_WRITE_COMMAND:
		switch(addr){

			case WRITE_IMG:
				cols = addr_pos;
				printf("cols: %d ", cols);
				actual_addr_write = i_img*(cols+2)+j_img;
				//cout << "i_img: " << i_img << " j_img: " << j_img << " addr: " << actual_addr_write << " ";
				
				j_img++;
				if(j_img == cols + 2)
				{
					j_img = 0;
					i_img++;
					printf("i_img: %d ", i_img);
				}
				if(i_img == cols+2){
					i_img = 0;
				}
				pl_dram.set_command(cmd);
				pl_dram.set_address(actual_addr_write);
				pl_dram.set_data_length(len);
				pl_dram.set_data_ptr(buf);
				pl_dram.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );
				//cout << "pix: " << to_fixed(buf) << " |"; 

				dram_in1_socket->b_transport(pl_dram, offset);
								

				if(len != LEN_IN_BYTES) pl.set_response_status(tlm::TLM_BURST_ERROR_RESPONSE);
			break;

			case ADDR_DATA_OUT:

				//read from IP_CORE DATA:
				pl_core_out1.set_command(tlm::TLM_READ_COMMAND);
				pl_core_out1.set_address(ADDR_DATA_OUT1);
				pl_core_out1.set_data_length(len_data);
				pl_core_out1.set_data_ptr(buf_bram_out1);
				pl_core_out1.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

				pl_core_out2.set_command(tlm::TLM_READ_COMMAND);
				pl_core_out2.set_address(ADDR_DATA_OUT2);
				pl_core_out2.set_data_length(len_data);
				pl_core_out2.set_data_ptr(buf_bram_out2);
				pl_core_out2.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

				ip_core_x_socket->b_transport(pl_core_out1, offset);
				ip_core_y_socket->b_transport(pl_core_out2, offset);

				//write that DATA to DRAM:
			        if(cols_out_dx == cols - 2){

					for(int i = 0; i < 2; ++i) {   

						buf_dram_out1[0] = buf_bram_out1[2*i]; 
						buf_dram_out1[1] = buf_bram_out1[2*i+1];

						buf_dram_out2[0] = buf_bram_out2[2*i]; 
						buf_dram_out2[1] = buf_bram_out2[2*i+1];

						dx_addr_out = (cols+2)*(cols+2) + 2*cols*rows_out_dx + cols_out_dx + i;
						dy_addr_out = (cols+2)*(cols+2) + (2*rows_out_dy+1)*cols + cols_out_dy + i;

						pl_dram_out1.set_command(tlm::TLM_WRITE_COMMAND);
						pl_dram_out1.set_address(dx_addr_out);
						pl_dram_out1.set_data_length(len);
						pl_dram_out1.set_data_ptr(buf_dram_out1);
						pl_dram_out1.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

						pl_dram_out2.set_command(tlm::TLM_WRITE_COMMAND);
						pl_dram_out2.set_address(dy_addr_out);
						pl_dram_out2.set_data_length(len);
						pl_dram_out2.set_data_ptr(buf_dram_out2);
						pl_dram_out2.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

						dram_out1_socket->b_transport(pl_dram_out1, offset);
						dram_out2_socket->b_transport(pl_dram_out2, offset);
					}

				} else {


				for(int i = 0; i < 4; ++i) {   
					buf_dram_out1[0] = buf_bram_out1[2*i]; 
					buf_dram_out1[1] = buf_bram_out1[2*i+1];

					buf_dram_out2[0] = buf_bram_out2[2*i]; 
					buf_dram_out2[1] = buf_bram_out2[2*i+1];

					dx_addr_out = (cols+2)*(cols+2) + 2*cols*rows_out_dx + cols_out_dx + i;
					dy_addr_out = (cols+2)*(cols+2) + (2*rows_out_dy+1)*cols + cols_out_dy + i;

					pl_dram_out1.set_command(tlm::TLM_WRITE_COMMAND);
					pl_dram_out1.set_address(dx_addr_out);
					pl_dram_out1.set_data_length(len);
					pl_dram_out1.set_data_ptr(buf_dram_out1);
					pl_dram_out1.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

					pl_dram_out2.set_command(tlm::TLM_WRITE_COMMAND);
					pl_dram_out2.set_address(dy_addr_out);
					pl_dram_out2.set_data_length(len);
					pl_dram_out2.set_data_ptr(buf_dram_out2);
					pl_dram_out2.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

					dram_out1_socket->b_transport(pl_dram_out1, offset);
					dram_out2_socket->b_transport(pl_dram_out2, offset);
				}
				}
				cols_out_dx += 4;
				cols_out_dy += 4;
				
				if(cols_out_dx > cols-2)
				{
					cols_out_dx = 0;
					rows_out_dx++;
					printf("rows_out_dx: %d ", rows_out_dx);
				}
				if(rows_out_dx == cols+3){
					rows_out_dx = 0;
				}
				if(cols_out_dy > cols-2)
				{
					cols_out_dy = 0;
					rows_out_dy++;
				}
				if(rows_out_dy == cols+3){
					rows_out_dy = 0;
				}
				
				if(len != LEN_IN_BYTES) pl.set_response_status(tlm::TLM_BURST_ERROR_RESPONSE);
			break;
			
			case ADDR_DATA_IN:

			    //read from DRAM DATA:

				for(int i = 0; i < 4; ++i) {   

					dx_addr_in = 2*(cols+2)*rows_in_dx + cols_in_dx + i;
					dy_addr_in = (2*rows_in_dy+1)*(cols+2) + cols_in_dy + i;

					pl_dram_in1.set_command(tlm::TLM_READ_COMMAND);
					pl_dram_in1.set_address(dx_addr_in);
					pl_dram_in1.set_data_length(len);
					pl_dram_in1.set_data_ptr(buf_dram_in1);
					pl_dram_in1.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

					pl_dram_in2.set_command(tlm::TLM_READ_COMMAND);
					pl_dram_in2.set_address(dy_addr_in);
					pl_dram_in2.set_data_length(len);
					pl_dram_in2.set_data_ptr(buf_dram_in2);
					pl_dram_in2.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );
					//cout << "Adresa prilikom citanja neparnih redova "<<dy_addr_in<<endl;
					//printf("read from dram 0x%4X in data_in2\n", buf_dram_in2);
					
					dram_in1_socket->b_transport(pl_dram_in1, offset);
					dram_in2_socket->b_transport(pl_dram_in2, offset);

					buf_bram_in1[2*i] = buf_dram_in1[0]; 
					buf_bram_in1[2*i+1] = buf_dram_in1[1];
					//printf("addr=%d %f in data_in1\n",dx_addr_in, to_fixed(buf_dram_in1));
					//printf("buf_dramin1[1] i=%d 0x%02X in data_in1\n",2*i+1, buf_dram_in1[1]);
					buf_bram_in2[2*i] = buf_dram_in2[0]; 
					buf_bram_in2[2*i+1] = buf_dram_in2[1];
					//printf("read from dram 0x%4X in data_in1\n", to_int(buf_dram_in1));
				}

				//write that DATA to BRAM:
				pl_core_in1.set_command(tlm::TLM_WRITE_COMMAND);
				pl_core_in1.set_address(ADDR_DATA_IN1);
				pl_core_in1.set_data_length(len_data);
				pl_core_in1.set_data_ptr(buf_bram_in1);
				pl_core_in1.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

				pl_core_in2.set_command(tlm::TLM_WRITE_COMMAND);
				pl_core_in2.set_address(ADDR_DATA_IN2);
				pl_core_in2.set_data_length(len_data);
				pl_core_in2.set_data_ptr(buf_bram_in2);
				pl_core_in2.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );
				//printf("dram_ctrl 0x%16X in data_in1\n", to_int64(buf_bram_in2));

				ip_core_data1_socket->b_transport(pl_core_in1, offset);
				ip_core_data2_socket->b_transport(pl_core_in2, offset);

				cols_in_dx += 4;
				cols_in_dy += 4;
				
				if(cols_in_dx > cols)
				{
					cols_in_dx = 0;
					rows_in_dx++;
					printf("rows_i_dx: %d ", rows_in_dx);
				}
				if(rows_in_dx == cols/2){
					rows_in_dx = 0;
				}
				if(cols_in_dy > cols)
				{
					cols_in_dy = 0;
					rows_in_dy++;
				}
				if(rows_in_dy == cols/2){
					rows_in_dy = 0;
				}
				
				if(len != LEN_IN_BYTES) pl.set_response_status(tlm::TLM_BURST_ERROR_RESPONSE);
			break;

			default:
				pl.set_response_status(tlm::TLM_COMMAND_ERROR_RESPONSE);		
					
		}
	if(len != LEN_IN_BYTES) pl.set_response_status(tlm::TLM_BURST_ERROR_RESPONSE);
	break;

	case tlm::TLM_READ_COMMAND:
		switch(addr){
			case READ_DX:

				actual_addr_read_dx = (cols+2)*(cols+2) + 2*cols*i_dx +j_dx;
				
				j_dx++;
				if(j_dx == cols)
				{
					j_dx = 0;
					i_dx++;
					//printf("i_dx: %d ", i_dx);
				}
				if(i_dx == cols)
				{
					i_dx = 0;
				}
				pl_dram.set_command(cmd);
				pl_dram.set_address(actual_addr_read_dx);
				pl_dram.set_data_length(len);
				pl_dram.set_data_ptr(buf);
				pl_dram.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

				dram_in1_socket->b_transport(pl_dram, offset);

				//cout << "i_dx: " << i_dx << " j_dx: " << j_dx << " addr: " << actual_addr_read_dx << endl;
								

				if(len != LEN_IN_BYTES) pl.set_response_status(tlm::TLM_BURST_ERROR_RESPONSE);
			break;

			case READ_DY:

				actual_addr_read_dy = (cols+2)*(cols+2) + (2*i_dy+1)*cols +j_dy;
				
				j_dy++;
				if(j_dy == cols)
				{
					j_dy = 0;
					i_dy++;
					printf("i_dy: %d ", i_dy);
				}
				if(i_dy == cols)
				{
					i_dy = 0;
				}
				pl_dram.set_command(cmd);
				pl_dram.set_address(actual_addr_read_dy);
				pl_dram.set_data_length(len);
				pl_dram.set_data_ptr(buf);
				pl_dram.set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );

				dram_in1_socket->b_transport(pl_dram, offset);
								

				if(len != LEN_IN_BYTES) pl.set_response_status(tlm::TLM_BURST_ERROR_RESPONSE);
			break;
			
			default:
				pl.set_response_status(tlm::TLM_COMMAND_ERROR_RESPONSE);		
					
		}
	if(len != LEN_IN_BYTES) pl.set_response_status(tlm::TLM_BURST_ERROR_RESPONSE);
	break;

	default:
		pl.set_response_status(tlm::TLM_COMMAND_ERROR_RESPONSE);
    }

  
    if (pl_dram.is_response_error()) SC_REPORT_ERROR("Bram_RE",pl_dram.get_response_string().c_str());
}



