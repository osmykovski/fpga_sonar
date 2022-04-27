#include <hls_stream.h>
#include <ap_axi_sdata.h>
#include "ap_int.h"
#include <stdint.h>

typedef struct {
    ap_int<24>       data;
    ap_uint<3>       user;
    ap_uint<1>       last;
} axis_8ch;

static int dma_status = 0;

int sound_dma(hls::stream<axis_8ch> &din, int *mem){

    axis_8ch in_data;
    uint8_t tlast = 0;
    uint8_t wr_ptr[8] = {0, 0, 0, 0, 0, 0, 0, 0};
    uint8_t wr_done = 0;

    while(wr_done != 0xFF){
		#pragma HLS PIPELINE

        in_data = din.read();

        // find packets beginning
        if(tlast != 0xFF){
            tlast |= ((int)in_data.last << in_data.user);

		// write packets in memory
        } else {
            mem[256*in_data.user + wr_ptr[in_data.user]] = (int)in_data.data;

            wr_ptr[in_data.user]++;

            if(wr_ptr[in_data.user] == 255) wr_done |= (1 << in_data.user);
        }
    }


    return 0;
}
