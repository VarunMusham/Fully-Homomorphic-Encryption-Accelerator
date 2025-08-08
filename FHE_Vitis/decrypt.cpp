#include "decrypt.h"
void decrypt(
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

    static int V[N], W[N], S[N], U[N], tA[N], tB[N];

    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        axi_t t;
        t = S_AXIS.read(); V[i] = t.data % MOD;
        t = S_AXIS.read(); W[i] = t.data % MOD;
        t = S_AXIS.read(); S[i] = t.data % MOD;
    }

    // U = V ⋆ S
    for (int i = 0; i < N; i++) { tA[i] = V[i]; tB[i] = S[i]; }
    ntt_array(tA); ntt_array(tB);
    for (int i = 0; i < N; i++) U[i] = mulmod(tA[i], tB[i]);
    intt_array(U);

    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        axi_t t;
        t.data = submod(W[i], U[i]) & 1;
        t.keep = -1;
        t.last = (i == N - 1);
        M_AXIS.write(t);
    }
}
