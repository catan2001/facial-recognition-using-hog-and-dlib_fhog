INIT:

//na bram_in blokove uvijek en=1
en_in = 1;
en_out = 1;

sel_bram_in = 0;
sel_filter = 0;
sel_bram_out = 0;
sel_dram = 0;

dram_row_ptr0 = 0;
dram_row_ptr1 = 1;
init = 1;

burst_len_read = width/4 - 1
burst_len_write = width/4 - 2;

-----------------------------------------------------------------------------------------------------------------------------
DRAM_TO_BRAM: (we_in, dram_addr0, dram_addr1, en, sel_bram_in, sel_bram_addr_in, bram_addr[0...7]_A/B, dram_row_ptr[0-1]) //[0..7] -> isto se generisu ali se inkrementuju u razlicitim vrem trenucima

(i, j, k, init) (i, k -> shared between this and CONTROL_LOGIC)

loop_bram_to_dram0:
i = 0;
sel_bram_in = 0;
sel_bram_addr_in = 0;

loop_dram_to_bram1:
  j = 0;

loop_dram_to_bram2: 
    dram_addr0 = dram_row_ptr0*(this->width)/4;
    dram_addr1 = dram_row_ptr1*(this->width)/4;

    while(en_axi = 0); // od AXI valid

    k = 0;
    we_in = 0x"0000000F";

loop_dram_to_bram3:       

      //staviti mux sa sel_bram_addr_in:
      bram_addr0_A = i*(this->width)/2 + k; //0 2 4 6
      bram_addr0_B = i*(this->width)/2 + k + 1; //1 3 5 7

      bram_addr1_A = i*(this->width)/2 + k;
      bram_addr1_B = i*(this->width)/2 + k + 1; 

      k = k + 2;
      //saljemo po 4 podatka odjednom po HP portu
      if(k = width/2) then
        goto end_dram_to_bram3;
      else
        goto loop_dram_to_bram3;
end_dram_to_bram3: 

    if(dram_row_ptr1=height) then
      goto end_dram_to_bram1;

    dram_row_ptr0 += 2;
    dram_row_ptr1 += 2;
    sel_bram_in += 1; // nojs
    we_in = we_in << 4;

    if(sel_bram_in = 8) then
      sel_bram_in = 0; // nojs
      we_in = 0X"0000000F";
    
    j = j + 2; 
    if(j = BRAM_HEIGHT) then
      goto end_dram_to_bram2;
    else
      goto loop_dram_to_bram2;

end_dram_to_bram2:
  i = i + 1;
  if(i = floor(2*BRAM_WIDTH/width)) then 
    goto end_dram_to_bram1;
  else
    goto loop_dram_to_bram1;

end_dram_to_bram1:

if(init){
  init = 0;
  goto CONTROL_LOGIC;
}else{
  goto RESUPPLY_FINISHED;
}

------------------------------------------------------------------------------------------------------
CONTROL_LOGIC: (we_in, finished, row_position, cycle_num, dram_row_ptr[0-1], sel_filter, sel_bram_out, sel_bram_addr_in)

(i, cnt_init)

i = 0;

control_loop:

  //uzimamo gornjih 6 bita rezultata mnozenja jer je i siroko 6 bita
  //1/BRAM_HEIGHT -> 10 bita sirine (6 cijeli dio i 4 decimalni)
  cycle_num = ((int)i*(1/BRAM_HEIGHT));  //1  

  if(cycle_num = (floor(2*BRAM_WIDTH/width)-1) && i = 12*cycle_num) then //2
    if(dram_row_ptr1<height) then
      
      cnt_init++;
      dram_row_ptr0 = (floor(2*BRAM_WIDTH/width)*BRAM_HEIGHT - (BRAM_HEIGHT-i)) * cnt_init;    //3
      dram_row_ptr1 = (floor(2*BRAM_WIDTH/width)*BRAM_HEIGHT - (BRAM_HEIGHT-i)) * cnt_init + 1; //4
      
      //konstante ne mora se realizovati kao oduzimanje 16-12 = 4
      i = i + 4;
      
      cycle_num = 0;
      sel_filter = 0;
      sel_bram_out = 0;
  
      goto DRAM_TO_BRAM and BRAM_TO_DRAM;

    end if;
  end if;

RESUPPLY_FINISHED:

row_position = 0; // position in row
sel_bram_addr_in = 1;
we_in = 0;
we_out = 0x"000F";

loop_row:      
    goto PIPELINE;

    END_PIPELINE:

    row_position = row_position + 2; // calculated 2 pixels
    if(row_position = width/2) then
        goto end_row;
    else
        goto loop_row;
end_row: 

  sel_filter = sel_filter + 1;
  if(sel_filter = 4) then
    sel_filter = 0;

  sel_bram_out = sel_bram_out + 1;
  we_out = we_out << 4;
  if(sel_bram_out = 4) then
    sel_bram_out = 0;
    we_out = 0x"000F";

  i = i + 4;

  if(i > floor(height/PTS_PER_ROWS) + accumulated_loss) then
    finished = 1;
    goto BRAM_TO_DRAM;
  else
    goto control_loop;    

----------------------------------------------------------------------------------------------------------
PIPELINE:
----------------------------------------------------------------------------------------------------------
BRAM_TO_FILTER: (sel_filter, cycle_num, row_position)

//signali BRAM BLOKA:
//we_in -> ctrl logic
//en -> ctrl logic
//addr -> ctrl logic
//data -> axi data

//sel=0 -> 0 1 2 3 4 5 addr

if(sel_filter = 3) then

  bram_addr[12..15]_A = row_position + cycle_num*width/2; // setting up the addresses
  bram_addr[12..15]_B = row_position + 1 + cycle_num*width/2; // setting up the addresses

  bram_addr[0..1]_A = row_position + (cycle_num+1)*width/2;
  bram_addr[0..1]_B = row_position + 1 + (cycle_num+1)*width/2;
else
  bram_addr[0..11]_A = row_position + cycle_num*width/2;
  bram_addr[0..11]_B = row_position + 1 + cycle_num*width/2;

------------------------------------------------------------------------------------------------------
FILTER: () // datapath

---------------------------------------------------------------------------------------------------------
FILTER_TO_BRAM: (sel_bram_out, cycle_num, row_position)

bram_output_x_addr = row_position>>1 + (width/2 - 1)*cycle_num;
bram_output_y_addr = row_position>>1 + (width/2 - 1)*cycle_num;

goto END_PIPELINE;
------------------------------------------------------------------------------------------------------
BRAM_TO_DRAM: (finished, sel_dram, dram_addr_x/y, bram_addr_x/y, we_out)

(i, k, row_cnt)

i = 0;
we_out = 0;

loop_bram_to_dram1:
  sel_dram = 0;

loop_bram_to_dram2:
    dram_addr_x = width*height + row_cnt*(width/4 - 1);
    dram_addr_y = width*height + (width - 2)*(height - 2) + row_cnt*(width/4 - 1);
    k = 0;

loop_bram_to_dram3:

      bram_addrA_x/y[sel_dram] = i*(width/2 - 1) + k; // nadamo se da ce k biti AXI
      bram_addrB_x/y[sel_dram] = i*(width/2 - 1) + 1 + k;

      k = k + 1; // molim te budi AXI
      if(k = (width/2 - 1)) then
        goto end_bram_to_dram3;
      else
        goto loop_bram_to_dram3;
end_bram_to_dram3:

    row_cnt = row_cnt + 1;
    sel_dram = sel_dram + 1;

    if(sel_dram = BRAM_HEIGHT)
      goto end_bram_to_dram2;
    else
      goto loop_bram_to_dram2;

end_bram_to_dram2: 

  i = i + 1;
  if(i = floor(2*BRAM_WIDTH/(width-1)))
    goto end_bram_to_dram1;
  else
    goto loop_bram_to_dram1;
end_bram_to_dram1:

if(finished)
  goto NOP;
else
  goto RESUPPLY_FINISHED;
------------------------------------------------------------------------------------------------------

DRAM_TO_BRAM:	

  switch(sel_bram_in)
  case 0:
  	bram_block0 = HP0;
	  bram_block1 = HP1;
  case 1:
  	bram_block2 = HP0;
	  bram_block3 = HP1;
  .....
  case 7:
	  bram_block14 = HP0;
	  bram_block15 = HP1;

BRAM_TO_FILTER:

//u svakom case-u se uvecavaju za 4 u odnosu na prvi case
switch(sel_filter){
    case 0:
      mux0_A = bram_block_A[0]; 
      mux0_B = bram_block_B[0];
      mux1_A = bram_block_A[1];
      mux1_B = bram_block_B[1];
      ...
      mux5_A = bram_block_A[5];
      mux5_B = bram_block_B[5];
    break;

    case 1:
      mux0_A = bram_block_A[4];
      mux0_B = bram_block_B[4];
      mux1_A = bram_block_A[5];
      mux1_B = bram_block_B[5];
      ...
      mux5_A = bram_block_A[9];
      mux5_B = bram_block_B[9];
    break;
   
    case 2:
      mux0_A = bram_block_A[8];
      mux0_B = bram_block_B[8];
      mux1_A = bram_block_A[9];
      mux1_B = bram_block_B[9];
      ...
      mux5_A = bram_block_A[13];
      mux5_B = bram_block_B[13];
    break;

    case 3:
      mux0_A = bram_block_A[12];
      mux0_B = bram_block_B[12];
      mux1_A = bram_block_A[13];
      mux1_B = bram_block_B[13];
      ...
      mux4_A = bram_block_A[0];
      mux4_B = bram_block_B[0];
      mux5_A = bram_block_A[1];
      mux5_B = bram_block_B[1];
    break; 

    default:
      break;
  }

FILTER:

//x prvi put po svim kolonama
temp[0] = mux(1-4)A(31-16)*2 + mux(2-5)A(31-16);
temp[1] = mux(1-4)B(31-16)*(-2) + mux(0-4)A(31-16);
temp[2] = mux(0-3)B*(31-16)*(-1) - mux(2-5)B(31-16);

mem18[0] = temp[0]+temp[1]+temp[2];

//x drugi put po svim kolonama
temp[0] = mux(1-4)A(15-0)*2 + mux(2-4)A(15-0);
temp[1] = mux(1-4)B(15-0)*(-2) + mux(0-3)A(15-0);
temp[2] = mux(0-3)B*(15-0)*(-1) - mux(2-5)B(15-0);

mem18[1] = temp[0]+temp[1]+temp[2];
.....

//y prvi put po svim kolonama
temp[3] = mux(0-3)A(15-0)*2 + mux(0-3)B(31-16);
temp[4] = mux(2-5)A(15-0)*(-2) + mux(0-3)A(31-16);
temp[5] = mux(2-5)A(31-16)*(-1) - mux(2-5)B(31-16);

mem18[8] = temp[3]+temp[4]+temp[5];

//y drugi put po svim kolonama
temp[3] = mux(0-3)B(31-16)*2 + mux(0-3)B(15-0);
temp[4] = mux(2-5)B(31-16)*(-2) + mux(0-3)A(15-0);
temp[5] = mux(2-5)A(15-0)*(-1) - mux(2-5)B(15-0);

mem18[9] = temp[3]+temp[4]+temp[5];
......
  
FILTER_TO_BRAM:

switch(sel_bram_out)
//za x, analogno y
case 0:
	bram_block0 = demux0
	bram_block1 = demux1
	bram_block2 = demux2
	bram_block3 = demux3
case 1:
	bram_block4 = demux0
	bram_block5 = demux1
	bram_block6 = demux2
	bram_block7 = demux3	
case 2:
	bram_block8 = demux0
	bram_block9 = demux1
	bram_block10 = demux2
	bram_block11 = demux3
case 3:
	bram_block12 = demux0
	bram_block13 = demux1
	bram_block14 = demux2
	bram_block15 = demux3

BRAM_TO_DRAM:

//analogno za y 1 veliki mux
switch(sel_dram)
case 0:
	mux_out = bram_block0;
case 1: 
	mux_out = bram_block1;
.....
case 15:
	mux_out = bram_block15;
--------------------------------------------------------------------------------------------------------