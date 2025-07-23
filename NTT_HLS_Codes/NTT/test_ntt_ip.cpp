#include <hls_stream.h>
#include <ap_axi_sdata.h>
#include <iostream>
#include "ntt_ip.h"

#define N 512

typedef ap_axiu<32,0,0,0> axi_t;

void test_ntt_ip() {
    hls::stream<axi_t> in_stream, out_stream;

    
    for (int i = 0; i < N; i++) {
        axi_t in;
        in.data = i;
        in.keep = -1;
        in.last = (i == N-1);
        in_stream.write(in);
    }

    
    ntt_ip(in_stream, out_stream, true, true);

    
    std::cout << "NTT output:" << std::endl;
    for (int i = 0; i < N; i++) {
        axi_t out = out_stream.read();
        std::cout << out.data << (out.last ? " (last)" : "") << std::endl;
    }
}

int main() {
    test_ntt_ip();
    return 0;
}
