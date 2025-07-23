#include "ntt_utils.h"

#include <hls_stream.h>

void ntt_mult(
    hls::stream<axi_t> &S_AXIS,   
    hls::stream<axi_t> &M_AXIS,   
    bool s_axis_aresetn,
    bool s_axis_aclk
) {
#pragma HLS interface axis         port=S_AXIS
#pragma HLS interface axis         port=M_AXIS
#pragma HLS interface ap_ctrl_none port=return
#pragma HLS interface ap_none      port=s_axis_aresetn
#pragma HLS interface ap_none      port=s_axis_aclk

    if (!s_axis_aresetn) return;

    static int A[N], B[N], C[N];

    
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        A[i] = S_AXIS.read().data % MOD;
    }

    
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        B[i] = S_AXIS.read().data % MOD;
    }

    
    ntt_array(A);
    ntt_array(B);

    
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        C[i] = mulmod(A[i], B[i]);
    }

    
    intt_array(C);

    
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        axi_t o;
        o.data = C[i];
        o.keep = -1;
        o.last = (i == N-1);
        M_AXIS.write(o);
    }
}