#ifndef NTT_INTT_TOP_H
#define NTT_INTT_TOP_H

#include <hls_stream.h>
#include "ap_axi_sdata.h"   

typedef ap_axiu<32,0,0,0> axi_t;

void ntt_mult(
    hls::stream<axi_t> &S_AXIS,
    hls::stream<axi_t> &M_AXIS,
    bool s_axis_aresetn,
    bool s_axis_aclk
);

#endif 