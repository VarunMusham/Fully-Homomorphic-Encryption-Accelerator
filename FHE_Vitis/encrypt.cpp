#include "encrypt.h"
void encrypt(
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

    static int A[N], pk0[N], R[N], M0[N], V[N], W[N], tA[N], tB[N];

    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        axi_t t;
        t = S_AXIS.read(); A[i] = t.data % MOD;
        t = S_AXIS.read(); pk0[i] = t.data % MOD;
        t = S_AXIS.read(); R[i] = t.data % MOD;
        t = S_AXIS.read(); M0[i] = t.data % MOD;
    }

    // 3) Encrypt → V = A⋆R
    for(int i=0;i<N;i++){ tA[i]=A[i]; tB[i]=R[i]; }
    ntt_array(tA); ntt_array(tB);
    for(int i=0;i<N;i++) V[i]=mulmod(tA[i],tB[i]);
    intt_array(V);

    //    W = pk0⋆R + M
    for(int i=0;i<N;i++){ tA[i]=pk0[i]; tB[i]=R[i]; }
    ntt_array(tA); ntt_array(tB);
    for(int i=0;i<N;i++) W[i]=mulmod(tA[i],tB[i]);
    intt_array(W);
    for(int i=0;i<N;i++) W[i]=addmod(W[i], M0[i]);

    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        axi_t t;
        t.data = V[i];
        t.keep = -1;
        t.last = false;
        M_AXIS.write(t);
        t.data = W[i];
        t.last = (i == N - 1);
        M_AXIS.write(t);
    }
}
