//#include "functions.h" 
#include "firmware.h"
#include "img_150_150.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>

int main(void)
{
	 int k = 0;
	 int rows = ROWS+2;
	 int cols = COLS+2;
	 int64_t dx_img[(COLS+2)*ROWS], dy_img[ROWS*(COLS+2)];
	 int64_t image_even[(COLS+2)*(ROWS+2)/8], image_odd[(ROWS+2)*(COLS+2)/8];


	 uint32_t SAHE1 = (WIDTH_2 << WIDTH_2_REG_OFFSET) + ((ROWS+2) << HEIGHT_REG_OFFSET) + ((COLS+2) << WIDTH_REG_OFFSET);
 	 uint32_t SAHE2 = (CYCLE_NUM_OUT << CYCLE_NUM_OUT_REG_OFFSET) + (CYCLE_NUM_LIMIT << CYCLE_NUM_IN_REG_OFFSET) + (EFFECTIVE_ROW_LIMIT << EFFECTIVE_ROW_LIMIT_REG_OFFSET) + (WIDTH_4 << WIDTH_4_REG_OFFSET);
 	 uint32_t SAHE3 = (BRAM_HEIGHT << BRAM_HEIGHT_REG_OFFSET) + (ROWS_NUM << ROWS_NUM_REG_OFFSET);
	
	write_hard(SAHE3_addr, (0x00008000 | SAHE3));
	while(!(read_hard(SAHE1_addr) & 0x00000001));
	write_hard(SAHE3_addr, SAHE3);

	write_hard(SAHE2_addr, SAHE2); 
	

	for(int i = 0; i < rows; i+=2){ 
	 	for(int j = 0; j < cols; j+=4){
	 	 image_even[k] = ((uint64_t)img[i*cols + j] << 48) | ((uint64_t)(img[i*cols + j + 1]) << 32) | ((uint64_t)(img[i*cols + j + 2]) << 16) | ((uint64_t)(img[i*cols + j + 3]));
		//printf("image_even %llu \n", image_even[k]);
		 image_odd[k] = ((uint64_t)img[(i+1)*cols + j] << 48) | ((uint64_t)(img[(i+1)*cols + j + 1]) << 32) | ((uint64_t)(img[(i+1)*cols + j + 2]) << 16) | ((uint64_t)(img[(i+1)*cols + j + 3]));
		//printf("image_odd %llu \n", image_odd[k]);
	         k++;
		}
	}
	
	write_hard(SAHE1_addr, (SAHE1 | 0x2));
	//while(!(read_hard(SAHE1) & 0x00000001));
	write_hard(SAHE1_addr, SAHE1);

	// If memory map is defined send image directly via mmap
	
	int fd;
	int64_t *even;
	int64_t *odd;
	int64_t *dx;
	int64_t *dy;

	//IMG_EVEN DMA0----------------------------------------------------

	fd = open("/dev/dma0", O_RDWR|O_NDELAY);
	if (fd < 0)
	{
		printf("Cannot open /dev/dma0 for img_even\n");
		return -1;
	}
	
	even=(int64_t *)mmap(0, (rows*cols), PROT_WRITE, MAP_SHARED, fd, 0);
	memcpy(even, image_even, (rows*cols));

	close(fd);
	if (fd < 0)
	{
		printf("Cannot close /dev/dma0 for img_even\n");
		return -1;
	}
/*
	for(int i = 0; i < rows/2; ++i)
		for(int j = 0; j < cols/4; ++j)
			printf("image_even = %llu\n", image_even[i*cols/4 + j]);	
*/
	//IMG_ODD DMA1:--------------------------------------------------
	
	fd = open("/dev/dma1", O_RDWR|O_NDELAY);
	if (fd < 0)
	{
		printf("Cannot open /dev/dma1 for img_odd\n");
		return -1;
	}

	odd=(int64_t*)mmap(0, (rows*cols), PROT_WRITE, MAP_SHARED, fd, 0);
	memcpy(odd, image_odd, (rows*cols));

	close(fd);

	if (fd < 0)
	{
		printf("Cannot close /dev/dma1 for img_odd\n");
		return -1;
	}
/*
	for(int i = 0; i < rows/2; ++i)
		for(int j = 0; j < cols/4; ++j)
			printf("image_odd = %llu\n", image_odd[i*cols/4 + j]);	
*/
	//DX DMA0:--------------------------------------------------------
	
	fd = open("/dev/dma0", O_RDWR|O_NDELAY);
	if (fd < 0)
	{
		printf("Cannot open /dev/dma0 for dx\n");
		return -1;
	}


	dx=(int64_t *)mmap(0, ((rows-2)*cols*2), PROT_READ, MAP_SHARED, fd, 0);
	memcpy(dx_img, dx, ((rows-2)*cols*2));

	close(fd);
	if (fd < 0)
	{
		printf("Cannot close /dev/dma0 for dx\n");
		return -1;
	}

	//DY DMA1:--------------------------------------------------
	fd = open("/dev/dma1", O_RDWR|O_NDELAY);
	if (fd < 0)
	{
		printf("Cannot open /dev/dma1 for dy\n");
		return -1;
	}

	dy=(int64_t *)mmap(0, ((rows-2)*(cols)*2), PROT_READ, MAP_SHARED, fd, 0);
	memcpy(dy_img, dy, ((rows-2)*cols*2));

	close(fd);
	if (fd < 0)
	{
		printf("Cannot close /dev/dma1 for dy\n");
		return -1;
	}

	//CONFIG DMA:-------------------------------------------
	usleep(200);
	config_dma(rows*cols, (rows-2)*cols*2, 0); // config dma 0
	config_dma(rows*cols, (rows-2)*cols*2, 1); // config dma 1

	sleep(2);

	for(int i = 0; i < rows-2; i++){
		printf("ROW: %d\n", i);
		for(int j = 0; j < cols/4; j++){
			//printf("Even NOT : %llu", )
			printf("%d: %llx ", j, dy[i*(cols/4) + j]); 
		}
		printf("\n");
	}




//	for(int i = 0; i < rows-2; ++i)
//		for(int j = 0; j < cols/4; ++j)
//			printf("dy_img = %llu, dy = %llu\n", dy_img[i*cols + j], dy[i*cols + j]);	



	munmap(even, (rows*cols));
	munmap(odd, (rows*cols));
	munmap(dx, ((rows-2)*cols*2));
	munmap(dy, ((rows-2)*cols*2));

	
	return 0;
}

