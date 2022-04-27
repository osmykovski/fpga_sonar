#include "xil_printf.h"
#include "xil_io.h"
#include "sleep.h"
#include "xuartps.h"
#include "xsound_dma.h"
#include "xil_cache.h"
#include "xscugic.h"
#include "xil_exception.h"

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

u32 DestinationBuffer[256*8];

XSound_dma dma_inst;
static XScuGic intc_inst;

void sound_dma_interrupt_handler(void){
	for(int i=0; i<2048; i++){
		xil_printf("%c%c%c",
				(DestinationBuffer[i] & 0x00FF0000) >> 16,
				(DestinationBuffer[i] & 0x0000FF00) >> 8,
				(DestinationBuffer[i] & 0x000000FF) >> 0
		);
	}
	XSound_dma_InterruptClear(&dma_inst, 0xFFFFFFFF);
}

int main(){
	Xil_DCacheDisable();

	XUartPs uart_inst;
	XUartPs_Config *uart_conf;
	uart_conf = XUartPs_LookupConfig(XPAR_PS7_UART_1_DEVICE_ID);
	XUartPs_CfgInitialize(&uart_inst, uart_conf, XPAR_PS7_UART_1_BASEADDR);
	XUartPs_SetBaudRate(&uart_inst, 460800);

	p_gen_set_pulse_len(XPAR_PULSE_GEN_0_BASEADDR, 16);
	p_gen_set_tx_period(XPAR_PULSE_GEN_0_BASEADDR, 20000000);
	p_gen_set_pattern(XPAR_PULSE_GEN_0_BASEADDR, 0x1f35); // 13-bit barker code
	p_gen_set_mask(XPAR_PULSE_GEN_0_BASEADDR, 0x1FFF);
	p_gen_enable(XPAR_PULSE_GEN_0_BASEADDR);

	XSound_dma_Initialize(&dma_inst, XPAR_SOUND_DMA_0_DEVICE_ID);
	XSound_dma_Set_mem(&dma_inst, (u32)DestinationBuffer);
	XSound_dma_InterruptGlobalEnable(&dma_inst);
	XSound_dma_InterruptEnable(&dma_inst, 0xFFFFFFFF);
	XSound_dma_EnableAutoRestart(&dma_inst);
	XSound_dma_Start(&dma_inst);

	Xil_ExceptionInit();
	Xil_ExceptionEnable();
	XScuGic_Config *IntcConfig;
	IntcConfig = XScuGic_LookupConfig(XPAR_SCUGIC_0_DEVICE_ID);
	XScuGic_CfgInitialize(&intc_inst, IntcConfig, IntcConfig->CpuBaseAddress);

	Xil_ExceptionRegisterHandler(
			XIL_EXCEPTION_ID_INT,
			(Xil_ExceptionHandler) sound_dma_interrupt_handler,
			&intc_inst
	);

	XScuGic_Connect(
			&intc_inst,
			XPAR_FABRIC_SOUND_DMA_0_INTERRUPT_INTR,
			(Xil_ExceptionHandler)sound_dma_interrupt_handler,
			(void *)&dma_inst
	);

	XScuGic_Enable(&intc_inst, XPAR_FABRIC_SOUND_DMA_0_INTERRUPT_INTR);


	while(1);

	return 0;
}
