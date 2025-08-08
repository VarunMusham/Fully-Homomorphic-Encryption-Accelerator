#ifndef KEYGEN_H
#define KEYGEN_H

#include <hls_stream.h>
#include "ap_axi_sdata.h"
#include "ntt_utils.h"

typedef ap_axiu<32,0,0,0> axi_t;

void keygen(
    hls::stream<axi_t>& S_AXIS,
    hls::stream<axi_t>& M_AXIS,
    bool s_axis_aresetn,
    bool s_axis_aclk
);

#endif
