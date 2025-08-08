#include "keygen.h"
void keygen(
    hls::stream<axi_t>& S_AXIS,
    hls::stream<axi_t>& M_AXIS,
    bool s_axis_aresetn,
    bool s_axis_aclk
) {
#pragma HLS interface axis         port=S_AXIS
#pragma HLS interface axis         port=M_AXIS
#pragma HLS interface ap_none      port=s_axis_aresetn
#pragma HLS interface ap_none      port=s_axis_aclk
#pragma HLS interface ap_ctrl_none port=return

    if (!s_axis_aresetn) return;

    static int A[N], S[N], E[N], pk0[N], tA[N], tB[N];

    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        axi_t t;
        t = S_AXIS.read(); A[i] = t.data % MOD;
        t = S_AXIS.read(); S[i] = t.data % MOD;
        t = S_AXIS.read(); E[i] = t.data % MOD;
    }

    for (int i = 0; i < N; i++) { tA[i] = A[i]; tB[i] = S[i]; }
    ntt_array(tA); ntt_array(tB);

      for (int i = 0; i < N; i++) pk0[i] = mulmod(tA[i], tB[i]);
    intt_array(pk0);
    for(int i=0;i<N;i++) pk0[i]=addmod(pk0[i], mulmod(E[i],2));

    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        axi_t t;
        t.data = pk0[i];
        t.keep = -1;
        t.last = (i == N - 1);
        M_AXIS.write(t);
    }
}
