#include <hls_stream.h>
#include <ap_axi_sdata.h>

typedef struct {
    ap_int<24>       data;
    ap_uint<3>       user;
    ap_uint<1>       last;
} axis_8ch;

int sound_dma(hls::stream<axis_8ch> &din, int *mem);

int main(){

    axis_8ch sample;
    hls::stream<axis_8ch> test_data;

    int outdata[256*8];

    // junk data before packet beginning
    for(int i=0; i<80;i++){
        sample.data = 0x5555AAAA;
        sample.user = i % 8;
        sample.last = i / 8 == 9;

        test_data.write(sample);
    }

    // actual data
    for(int i=0; i<2048;i++){
        sample.data = i;
        sample.user = i % 8;
        sample.last = 0;

        test_data.write(sample);
    }
    
    sound_dma(test_data, outdata);

    // testing
    for(int i=0; i<1024; i++){
    	assert(outdata[(i%8 * 256) + i/8] == i);
    }

    std::cout << "success" << std::endl;

    return 0;
}
