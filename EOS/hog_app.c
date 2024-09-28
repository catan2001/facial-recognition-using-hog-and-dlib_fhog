#include "functions.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>

int main(void)
{
	int width = 0, height = 0;

	write_hard(SAHE3, 0x00008000);
	while(!read_hard(SAHE1 & 0x00000001));
	write_hard(SAHE3, 0x040D7);
	write_hard(SAHE2, 0x34D09826);

	// If memory map is defined send image directly via mmap
	int fd;
	int *p, r*;
	fd = open("/dev/dma0", O_RDWR|O_NDELAY);
	if (fd < 0)
	{
		printf("Cannot open /dev/dma0 for write\n");
		return -1;
	}
	p=(int*)mmap(0,(width+2)/2*(height+2)/2*16, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	memcpy(p, image_even, (width+2)/2*(height+2)/2*16);
	munmap(p, (width+2)/2*(height+2)/2*16);
	close(fd);
	if (fd < 0)
	{
		printf("Cannot close /dev/dma0 for write\n");
		return -1;
	}

	fd = open("/dev/dma1", O_RDWR|O_NDELAY);
	if (fd < 0)
	{
		printf("Cannot open /dev/dma1 for write\n");
		return -1;
	}
	r=(int*)mmap(0,(width+2)/2*(height+2)/2*16, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	memcpy(p, image_odd, (width+2)/2*(height+2)/2*16);
	munmap(p, (width+2)/2*(height+2)/2*16);
	close(fd);
	if (fd < 0)
	{
		printf("Cannot close /dev/dma0 for write\n");
		return -1;
	}

	write_hard(SAHE1, 0X26098262);
	while(!read_hard(SAHE1 & 0x00000001));
	write_hard(SAHE1, 0X26098260);

	return 0;
}

