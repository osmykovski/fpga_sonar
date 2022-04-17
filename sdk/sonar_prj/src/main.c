#include "xil_printf.h"
#include "xil_io.h"
#include "sleep.h"

#define fifo_rd_fifo(baseaddr) Xil_In32(baseaddr + 0x00)
#define fifo_rx_get_occup(baseaddr) Xil_In32(baseaddr + 0x04)
#define fifo_wr_fifo(baseaddr, val) Xil_Out32(baseaddr + 0x08, val)
#define fifo_tx_get_occup(baseaddr) Xil_In32(baseaddr + 0x0c)

#define p_gen_enable(baseaddr) Xil_Out32(baseaddr + 0x00, 1)
#define p_gen_disable(baseaddr) Xil_Out32(baseaddr + 0x00, 0)
#define p_gen_is_enabled(baseaddr) Xil_In32(baseaddr + 0x00)

#define p_gen_set_pattern(baseaddr, val) Xil_Out32(baseaddr + 0x04, (val & 0x0000FFFF) | (Xil_In32(baseaddr + 0x04) & 0xFFFF0000))
#define p_gen_set_mask(baseaddr, val)    Xil_Out32(baseaddr + 0x04, ((val & 0x0000FFFF) << 16) | (Xil_In32(baseaddr + 0x04) & 0x0000FFFF))
#define p_gen_get_pattern(baseaddr) (Xil_In32(baseaddr + 0x04) & 0x0000FFFF)
#define p_gen_get_mask(baseaddr)   ((Xil_In32(baseaddr + 0x04) & 0xFFFF0000) >> 16)

#define p_gen_set_pulse_len(baseaddr, val) Xil_Out32(baseaddr + 0x08, val)
#define p_gen_get_pulse_len(baseaddr) Xil_In32(baseaddr + 0x08)

#define p_gen_set_tx_period(baseaddr, val) Xil_Out32(baseaddr + 0x0c, val)
#define p_gen_get_tx_period(baseaddr) Xil_In32(baseaddr + 0x0c)

u32 DestinationBuffer[8192];

int main(){

	p_gen_set_pulse_len(XPAR_PULSE_GEN_0_BASEADDR, 16);
	p_gen_set_tx_period(XPAR_PULSE_GEN_0_BASEADDR, 3333333);
	p_gen_set_pattern(XPAR_PULSE_GEN_0_BASEADDR, 0x1f35); // 13-bit barker code
	p_gen_set_mask(XPAR_PULSE_GEN_0_BASEADDR, 0x1FFF);
	p_gen_enable(XPAR_PULSE_GEN_0_BASEADDR);

	sleep(1);

	for(int i=0; i<10000;){
		int occup = fifo_rx_get_occup(XPAR_AXI_STREAM_FIFO_0_BASEADDR);
		for(int x=0; x<occup; x++){
			fifo_rd_fifo(XPAR_AXI_STREAM_FIFO_0_BASEADDR);
			i++;
		}
	}

	xil_printf("%08x\r\n", DestinationBuffer);

	// channels sync
	uint32_t fifo_data;
	uint8_t channel;
	while(1){
		int occup = fifo_rx_get_occup(XPAR_AXI_STREAM_FIFO_0_BASEADDR);
		if(occup) {
			fifo_data = fifo_rd_fifo(XPAR_AXI_STREAM_FIFO_0_BASEADDR);
			channel = fifo_data >> 24;
			if(channel == 7) break;
		}
	}

	int i = 0;
	while(1){
		int occup = fifo_rx_get_occup(XPAR_AXI_STREAM_FIFO_0_BASEADDR);
		for(int x=0; x<occup; x++){
			fifo_data = fifo_rd_fifo(XPAR_AXI_STREAM_FIFO_0_BASEADDR);
			channel = fifo_data >> 24;
			DestinationBuffer[i + 1024*channel] = fifo_data & 0x00FFFFFF;
			if(channel == 7) i++;
		}

		if(i>1023) break;
	}

	xil_printf("done.");

	while(1) fifo_rd_fifo(XPAR_AXI_STREAM_FIFO_0_BASEADDR);

	return 0;
}
