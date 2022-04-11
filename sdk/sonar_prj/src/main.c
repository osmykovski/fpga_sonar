#include "xil_printf.h"
#include "xil_io.h"
#include "sleep.h"

#define fifo_rd_fifo(baseaddr) Xil_In32(baseaddr + 0x00)
#define fifo_rx_get_occup(baseaddr) Xil_In32(baseaddr + 0x04)
#define fifo_wr_fifo(baseaddr, val) Xil_Out32(baseaddr + 0x08, val)
#define fifo_tx_get_occup(baseaddr) Xil_In32(baseaddr + 0x0c)

u32 DestinationBuffer[10000];

int main(){

	for(int i=0; i<10000;){
		int occup = fifo_rx_get_occup(XPAR_AXI_STREAM_FIFO_0_BASEADDR);
		for(int x=0; x<occup; x++){
			fifo_rd_fifo(XPAR_AXI_STREAM_FIFO_0_BASEADDR);
			i++;
		}
	}

	xil_printf("%08x\r\n", DestinationBuffer);

	for(int i=0; i<10000;){
		int occup = fifo_rx_get_occup(XPAR_AXI_STREAM_FIFO_0_BASEADDR);
		for(int x=0; x<occup/4; x++){
			DestinationBuffer[i] = fifo_rd_fifo(XPAR_AXI_STREAM_FIFO_0_BASEADDR);
			i++;
			fifo_rd_fifo(XPAR_AXI_STREAM_FIFO_0_BASEADDR);
			fifo_rd_fifo(XPAR_AXI_STREAM_FIFO_0_BASEADDR);
			fifo_rd_fifo(XPAR_AXI_STREAM_FIFO_0_BASEADDR);
		}
	}

	xil_printf("done.");

	while(1) fifo_rd_fifo(XPAR_AXI_STREAM_FIFO_0_BASEADDR);

	return 0;
}
