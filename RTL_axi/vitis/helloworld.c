#include <stdio.h>
#include <xil_printf.h>
#include "platform.h"
#include "xparameters.h"
#include "xaxidma.h"
#include "xil_io.h"
#include "xil_types.h"
#include "xil_exception.h"
#include "xscugic.h"
#include "xil_cache.h"
#include "sleep.h"
#include "xdebug.h"
#include "img_150_150.h"

//sahe 1
#define SAHE1_BASE_ADDR 0
#define READY_REG_OFFSET 0
#define START_REG_OFFSET 1
#define WIDTH_REG_OFFSET 2
#define HEIGHT_REG_OFFSET 12
#define WIDTH_2_REG_OFFSET 23
//sahe2
#define SAHE2_BASE_ADDR 4
#define WIDTH_4_REG_OFFSET 0
#define EFFECTIVE_ROW_LIMIT_REG_OFFSET 8
#define CYCLE_NUM_IN_REG_OFFSET 20
#define CYCLE_NUM_OUT_REG_OFFSET 26
//sahe 3
#define SAHE3_BASE_ADDR 8
#define ROWS_NUM_REG_OFFSET 0
#define BRAM_HEIGHT_REG_OFFSET 10
#define RESET_REG_OFFSET 15

#define BRAM_HEIGHT 16
#define DMA0_DEV_ID		XPAR_AXIDMA_0_DEVICE_ID			// DMA0 Device ID
#define DMA1_DEV_ID		XPAR_AXIDMA_1_DEVICE_ID			// DMA1 Device ID
#define DMA0_BASEADDR 	XPAR_AXI_DMA_0_BASEADDR			// DMA0 BaseAddr
#define DMA1_BASEADDR 	XPAR_AXI_DMA_1_BASEADDR			// DMA1 BaseAddr
#define DDR_BASE_ADDR 	XPAR_PS7_DDR_0_S_AXI_BASEADDR	// DDR START ADDRESS
#define MEM_BASE_ADDR	(DDR_BASE_ADDR + 0x1000000)		// MEM START ADDRESS

// REGISTER OFFSETS FOR DMA
// MEMORY TO STREAM REGISTER OFFSETS
#define MM2S_DMACR_OFFSET	0x00
#define MM2S_DMASR_OFFSET 	0x04
#define MM2S_SA_OFFSET 		0x18
#define MM2S_SA_MSB_OFFSET 	0x1c
#define MM2S_LENGTH_OFFSET 	0x28
// STREAM TO MEMORY REGISTER OFFSETS
#define S2MM_DMACR_OFFSET	0x30
#define S2MM_DMASR_OFFSET 	0x34
#define S2MM_DA_OFFSET 		0x48
#define S2MM_DA_MSB_OFFSET 	0x4c
#define S2MM_LENGTH_OFFSET 	0x58

// FLAG BITS INSIDE DMACR REGISTER
#define DMACR_IOC_IRQ_EN 	(1 << 12) // this is IOC_IrqEn bit in DMACR register
#define DMACR_ERR_IRQ_EN 	(1 << 14) // this is Err_IrqEn bit in DMACR register
#define DMACR_RESET 		(1 << 2)  // this is Reset bit in DMACR register
#define DMACR_RS 			 1 		  // this is RS bit in DMACR register

#define DMASR_IOC_IRQ 		(1 << 12) // this is IOC_Irq bit in DMASR register

// TRANSMIT TRANSFER (MEMORY TO STREAM) INTERRUPT ID
#define TX0_INTR_ID		61U
#define TX1_INTR_ID		63U
// TRANSMIT TRANSFER (MEMORY TO STREAM) BUFFER START ADDRESS
#define TX0_BUFFER_BASE	(MEM_BASE_ADDR + 0x01000000)
#define TX1_BUFFER_BASE	(MEM_BASE_ADDR + 0x04000000)

// RECIEVE TRANSFER (STREAM TO MEMORY) INTERRUPT ID
#define RX0_INTR_ID		62U
#define RX1_INTR_ID		64U
// RECIEVE TRANSFER (STREAM TO MEMORY) BUFFER START ADDRESS
#define RX0_BUFFER_BASE	(MEM_BASE_ADDR + 0x08000000)
#define RX1_BUFFER_BASE	(MEM_BASE_ADDR + 0x0C000000)

// INTERRUPT CONTROLLER DEVICE ID
#define INTC_DEVICE_ID 	XPAR_SCUGIC_0_DEVICE_ID

//WTF IS THIS
#define RESET_TIMEOUT_COUNTER	10000

//******* FUNCTION DECLARATIONS **********
// Disable Interrupt System
static void Disable_Interrupt_System();

u32 Setup_Interrupt(u32 DeviceId, Xil_InterruptHandler Handler, u32 interrupt_ID);

void DMA_init_interrupts();
u32 Initialize_System();
u32 DMA0_Simple_Write(u32 *TxBufferPtr, u32 max_pkt_len); // my function
u32 DMA1_Simple_Write(u32 *TxBufferPtr, u32 max_pkt_len); // my function
u32 DMA0_Simple_Read (u32 *RxBufferPtr, u32 max_pkt_len); // my function
u32 DMA1_Simple_Read (u32 *RxBufferPtr, u32 max_pkt_len); // my function

volatile int Error;

static XScuGic INTCInst;	// Instance of Interrupt Controller
//static XAxiDma AxiDma;		// Instance of the XAxiDma

u64 *TxBufferPtr0 = (u64 *)TX0_BUFFER_BASE;
u64 *TxBufferPtr1 = (u64 *)TX1_BUFFER_BASE;
u64 *RxBufferPtr0 = (u64 *)RX0_BUFFER_BASE;
u64 *RxBufferPtr1 = (u64 *)RX1_BUFFER_BASE;

int main()
{
  Xil_DCacheDisable();
  Xil_ICacheDisable();
  init_platform();

  xil_printf("\r\nStarting simulation\r\n");

  Xil_Out32(XPAR_TOP_AXI_0_BASEADDR + SAHE3_BASE_ADDR, 1<<15);
  while(!(Xil_In32(XPAR_TOP_AXI_0_BASEADDR + SAHE1_BASE_ADDR) & 0x00000001));
  Xil_Out32(XPAR_TOP_AXI_0_BASEADDR + SAHE3_BASE_ADDR, 0<<15);

  u32 SAHE1 = (WIDTH_2 << WIDTH_2_REG_OFFSET) + (HEIGHT << HEIGHT_REG_OFFSET) + (WIDTH << WIDTH_REG_OFFSET);
  u32 SAHE2 = (CYCLE_NUM_OUT << CYCLE_NUM_OUT_REG_OFFSET) + (CYCLE_NUM_LIMIT << CYCLE_NUM_IN_REG_OFFSET) + (EFFECTIVE_ROW_LIMIT << EFFECTIVE_ROW_LIMIT_REG_OFFSET) + (WIDTH_4 << WIDTH_4_REG_OFFSET);
  u32 SAHE3 = (BRAM_HEIGHT << BRAM_HEIGHT_REG_OFFSET) + (ROWS_NUM << ROWS_NUM_REG_OFFSET);

  //sending param to filter core
  Xil_Out32(XPAR_TOP_AXI_0_BASEADDR + SAHE1_BASE_ADDR, SAHE1);
  Xil_Out32(XPAR_TOP_AXI_0_BASEADDR + SAHE2_BASE_ADDR, SAHE2);
  Xil_Out32(XPAR_TOP_AXI_0_BASEADDR + SAHE3_BASE_ADDR, SAHE3);
  xil_printf("\r\nWRITTEN TO CONFIG REGISTERS:\r\n");

  int tx_cnt = 0;
  int rx_cnt = 0;

  for(int i = 0; i < HEIGHT; i+=2){
    for(int j = 0; j < WIDTH; j+=4){
    	TxBufferPtr0[tx_cnt] = ((u64)img[i*WIDTH + j] << 48) + ((u64)img[i*WIDTH + j + 1] << 32) + ((u64)img[i*WIDTH + j + 2] << 16) + (u64)img[i*WIDTH + j + 3];
    	TxBufferPtr1[tx_cnt] = ((u64)img[(i+1)*WIDTH + j] << 48) + ((u64)img[(i+1)*WIDTH + j + 1] << 32) + ((u64)img[(i+1)*WIDTH + j + 2] << 16) + (u64)img[(i+1)*WIDTH + j + 3];

        tx_cnt++;

    }
  }
  xil_printf("\r\nTX ARRAY LEN:%d \r\n", tx_cnt);


  for(int i = 0; i < HEIGHT-2; ++i){
    for(int j = 0; j < WIDTH; j+=4){
    	RxBufferPtr0[rx_cnt] = 0;
    	RxBufferPtr1[rx_cnt] = 0;
        rx_cnt++;
    }
  }
  xil_printf("\r\nRX ARRAY CNT:%d \r\n", rx_cnt);

  //START DUT
  Xil_Out32(XPAR_TOP_AXI_0_BASEADDR + SAHE1_BASE_ADDR, (SAHE1 | 0x00000002));
  Xil_Out32(XPAR_TOP_AXI_0_BASEADDR + SAHE1_BASE_ADDR, (SAHE1 & 0XFFFFFFFD));

  //CONFIG DMA
  DMA1_Simple_Read((u32*)RxBufferPtr1, rx_cnt*8);
  DMA0_Simple_Read((u32*)RxBufferPtr0, rx_cnt*8);

  DMA0_Simple_Write((u32*)TxBufferPtr0, tx_cnt*8);
  DMA1_Simple_Write((u32*)TxBufferPtr1, tx_cnt*8);


  while(!(Xil_In32(XPAR_TOP_AXI_0_BASEADDR + SAHE1_BASE_ADDR) & 0x00000001));

  xil_printf("\r\nFINISHED.\r\n");

  cleanup_platform();
  Disable_Interrupt_System();
  return 0;
}

u32 DMA0_Simple_Write(u32 *TxBufferPtr, u32 max_pkt_len) {

  u32 MM2S_DMACR_reg = 0;

  MM2S_DMACR_reg = Xil_In32(DMA0_BASEADDR + MM2S_DMACR_OFFSET); // READ from MM2S_DMACR register
  Xil_Out32(DMA0_BASEADDR + MM2S_DMACR_OFFSET, MM2S_DMACR_reg | DMACR_RS); // set RS bit in MM2S_DMACR register (this bit starts the DMA)

  Xil_Out32(DMA0_BASEADDR + MM2S_SA_OFFSET,  (UINTPTR)TxBufferPtr); // Write into MM2S_SA register the value of TxBufferPtr.
  Xil_Out32(DMA0_BASEADDR + MM2S_SA_MSB_OFFSET, 0);				// With this, the DMA knows from where to start.

  Xil_Out32(DMA0_BASEADDR + MM2S_LENGTH_OFFSET,  max_pkt_len); // Write into MM2S_LENGTH register. This is the length of a tranaction.

  return 0;
}

u32 DMA0_Simple_Read(u32 *RxBufferPtr, u32 max_pkt_len) {

  u32 S2MM_DMACR_reg = 0;

  S2MM_DMACR_reg = Xil_In32(DMA0_BASEADDR + S2MM_DMACR_OFFSET); // READ from S2MM_DMACR register
  Xil_Out32(DMA0_BASEADDR + S2MM_DMACR_OFFSET, S2MM_DMACR_reg | DMACR_RS); // set RS bit in S2MM_DMACR register (this bit starts the DMA)

  Xil_Out32(DMA0_BASEADDR + S2MM_DA_OFFSET,  (UINTPTR)RxBufferPtr); // Write into S2MM_SA register the value of TxBufferPtr.
  Xil_Out32(DMA0_BASEADDR + S2MM_DA_MSB_OFFSET, 0); 		// With this, the DMA knows from where to start.

  Xil_Out32(DMA0_BASEADDR + S2MM_LENGTH_OFFSET,  max_pkt_len); // Write into S2MM_LENGTH register. This is the length of a tranaction.

  return 0;
}

u32 DMA1_Simple_Write(u32 *TxBufferPtr, u32 max_pkt_len) {

  u32 MM2S_DMACR_reg = 0;

  MM2S_DMACR_reg = Xil_In32(DMA1_BASEADDR + MM2S_DMACR_OFFSET); // READ from MM2S_DMACR register
  Xil_Out32(DMA1_BASEADDR + MM2S_DMACR_OFFSET, MM2S_DMACR_reg | DMACR_RS); // set RS bit in MM2S_DMACR register (this bit starts the DMA)

  Xil_Out32(DMA1_BASEADDR + MM2S_SA_OFFSET,  (UINTPTR)TxBufferPtr); // Write into MM2S_SA register the value of TxBufferPtr.
  Xil_Out32(DMA1_BASEADDR + MM2S_SA_MSB_OFFSET, 0);				// With this, the DMA knows from where to start.

  Xil_Out32(DMA1_BASEADDR + MM2S_LENGTH_OFFSET,  max_pkt_len); // Write into MM2S_LENGTH register. This is the length of a tranaction.

  return 0;
}


u32 DMA1_Simple_Read(u32 *RxBufferPtr, u32 max_pkt_len) {

  u32 S2MM_DMACR_reg =0;

  S2MM_DMACR_reg = Xil_In32(DMA1_BASEADDR + S2MM_DMACR_OFFSET); // READ from S2MM_DMACR register
  Xil_Out32(DMA1_BASEADDR + S2MM_DMACR_OFFSET, S2MM_DMACR_reg | DMACR_RS); // set RS bit in S2MM_DMACR register (this bit starts the DMA)

  Xil_Out32(DMA1_BASEADDR + S2MM_DA_OFFSET,  (UINTPTR)RxBufferPtr); // Write into S2MM_SA register the value of TxBufferPtr.
  Xil_Out32(DMA1_BASEADDR + S2MM_DA_MSB_OFFSET, 0); 		// With this, the DMA knows from where to start.

  Xil_Out32(DMA1_BASEADDR + S2MM_LENGTH_OFFSET,  max_pkt_len); // Write into S2MM_LENGTH register. This is the length of a tranaction.

  return 0;
}

static void Disable_Interrupt_System()
{

  XScuGic_Disconnect(&INTCInst, TX0_INTR_ID);
  XScuGic_Disconnect(&INTCInst, RX0_INTR_ID);

  XScuGic_Disconnect(&INTCInst, TX1_INTR_ID);
  XScuGic_Disconnect(&INTCInst, RX1_INTR_ID);
}

u32 Setup_Interrupt(u32 DeviceId, Xil_InterruptHandler Handler, u32 interrupt_ID)
{
  XScuGic_Config *IntcConfig;
  XScuGic INTCInst;
  int status;
  // Extracts informations about processor core based on its ID, and they are used to setup interrupts
  IntcConfig = XScuGic_LookupConfig(DeviceId);

  // Initializes processor registers using information extracted in the previous step
  status = XScuGic_CfgInitialize(&INTCInst, IntcConfig, IntcConfig->CpuBaseAddress);
  if(status != XST_SUCCESS) return XST_FAILURE;
  status = XScuGic_SelfTest(&INTCInst);
  if (status != XST_SUCCESS) return XST_FAILURE;

  // Connect Timer Handler And Enable Interrupt
  // The processor can have multiple interrupt sources, and we must setup trigger and   priority
  // for the our interrupt. For this we are using interrupt ID.
   XScuGic_SetPriorityTriggerType(&INTCInst, interrupt_ID, 0xA8, 3);

  // Connects out interrupt with the appropriate ISR (Handler)
  status = XScuGic_Connect(&INTCInst, interrupt_ID, Handler, (void *)&INTCInst);
  if(status != XST_SUCCESS) return XST_FAILURE;

  // Enable interrupt for out device
  XScuGic_Enable(&INTCInst, interrupt_ID);

  //Two lines bellow enable exeptions
  Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			       (Xil_ExceptionHandler)XScuGic_InterruptHandler,&INTCInst);
  Xil_ExceptionEnable();

  return XST_SUCCESS;
}

void DMA_init_interrupts()
{
  u32 MM2S_DMACR_reg;
  u32 S2MM_DMACR_reg;

  Xil_Out32(DMA0_BASEADDR + MM2S_DMACR_OFFSET,  DMACR_RESET); // writing to MM2S_DMACR register
  Xil_Out32(DMA0_BASEADDR + S2MM_DMACR_OFFSET,  DMACR_RESET); // writing to S2MM_DMACR register

  Xil_Out32(DMA1_BASEADDR + MM2S_DMACR_OFFSET,  DMACR_RESET); // writing to MM2S_DMACR register
  Xil_Out32(DMA1_BASEADDR + S2MM_DMACR_OFFSET,  DMACR_RESET); // writing to S2MM_DMACR register

  /* THIS HERE IS NEEDED TO CONFIGURE DMA*/
  //enable interrupts
  MM2S_DMACR_reg = Xil_In32(DMA0_BASEADDR + MM2S_DMACR_OFFSET); // Reading from MM2S_DMACR register inside DMA
  Xil_Out32((DMA0_BASEADDR + MM2S_DMACR_OFFSET),  (MM2S_DMACR_reg | DMACR_IOC_IRQ_EN | DMACR_ERR_IRQ_EN)); // writing to MM2S_DMACR register
  S2MM_DMACR_reg = Xil_In32(DMA0_BASEADDR + S2MM_DMACR_OFFSET); // Reading from S2MM_DMACR register inside DMA
  Xil_Out32((DMA0_BASEADDR + S2MM_DMACR_OFFSET),  (S2MM_DMACR_reg | DMACR_IOC_IRQ_EN | DMACR_ERR_IRQ_EN)); // writing to S2MM_DMACR register

  MM2S_DMACR_reg = Xil_In32(DMA1_BASEADDR + MM2S_DMACR_OFFSET); // Reading from MM2S_DMACR register inside DMA
  Xil_Out32((DMA1_BASEADDR + MM2S_DMACR_OFFSET),  (MM2S_DMACR_reg | DMACR_IOC_IRQ_EN | DMACR_ERR_IRQ_EN)); // writing to MM2S_DMACR register
  S2MM_DMACR_reg = Xil_In32(DMA1_BASEADDR + S2MM_DMACR_OFFSET); // Reading from S2MM_DMACR register inside DMA
  Xil_Out32((DMA1_BASEADDR + S2MM_DMACR_OFFSET),  (S2MM_DMACR_reg | DMACR_IOC_IRQ_EN | DMACR_ERR_IRQ_EN)); // writing to S2MM_DMACR register

}

