#include "intt_ip.h"
#include <hls_stream.h>

#define N        512
#define MOD      7681
#define ROOT_INV 7480   
#define N_INV    7666  


int mulmod(int a, int b) { return (long long)a * b % MOD; }
int addmod(int a, int b) { int r = a + b; return (r >= MOD) ? r - MOD : r; }
int submod(int a, int b) { int r = a - b; return (r < 0)   ? r + MOD : r; }

int modpow(int base, int exp) {
    int res = 1;
    while (exp) {
        if (exp & 1) res = mulmod(res, base);
        base = mulmod(base, base);
        exp >>= 1;
    }
    return res;
}

int bit_reverse(int x, int logn) {
    int r = 0;
    for (int i = 0; i < logn; i++)
        if (x & (1 << i))
            r |= 1 << (logn - 1 - i);
    return r;
}

void intt_ip(hls::stream<axi_t> &S_AXIS,
             hls::stream<axi_t> &M_AXIS,
             bool s_axis_aresetn,
             bool s_axis_aclk) {
#pragma HLS interface axis         port=S_AXIS
#pragma HLS interface axis         port=M_AXIS
#pragma HLS interface ap_ctrl_none port=return
#pragma HLS interface ap_none      port=s_axis_aresetn
#pragma HLS interface ap_none      port=s_axis_aclk

    if (!s_axis_aresetn) return;

    const int LOGN = 9;
    int x   [N];
    int tmp [N];


    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        x[i] = S_AXIS.read().data % MOD;
    }

    // Gentleman-Sande DIF INTT
    for (int len = N; len >= 2; len >>= 1) {
        int wlen = modpow(ROOT_INV, N / len);
        for (int i = 0; i < N; i += len) {
            int w = 1;
            for (int j = 0; j < len/2; j++) {
            #pragma HLS PIPELINE II=1
                int u = x[i+j];
                int v = x[i+j+len/2];
                x[i+j]         = addmod(u, v);
                x[i+j+len/2]   = mulmod(submod(u, v), w);
                w = mulmod(w, wlen);
            }
        }
    }

    // Scale by N⁻¹
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        x[i] = mulmod(x[i], N_INV);
    }

    
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        tmp[bit_reverse(i, LOGN)] = x[i];
    }
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        x[i] = tmp[i];
    }

    
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        axi_t out;
        out.data = x[i];
        out.keep = -1;
        out.last = (i == N - 1);
        M_AXIS.write(out);
    }
}
