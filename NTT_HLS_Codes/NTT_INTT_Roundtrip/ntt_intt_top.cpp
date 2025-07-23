#include "ntt_intt_top.h"

#include <hls_stream.h>



#define N        512
#define MOD      7681
#define ROOT     7146  
#define ROOT_INV 7480 
#define N_INV    7666 
#define LOGN     9     



static inline int mulmod(int a, int b) {
    return (long long)a * b % MOD;
}

static inline int addmod(int a, int b) {
    int r = a + b;
    return (r >= MOD) ? r - MOD : r;
}

static inline int submod(int a, int b) {
    int r = a - b;
    return (r < 0) ? r + MOD : r;
}

static inline int modpow(int base, int exp) {
    int result = 1;
    while (exp > 0) {
        if (exp & 1) result = mulmod(result, base);
        base = mulmod(base, base);
        exp >>= 1;
    }
    return result;
}

static inline int bit_reverse(int v, int lg) {
    int r = 0;
    for (int i = 0; i < lg; i++) {
        if (v & (1 << i))
            r |= 1 << (lg - 1 - i);
    }
    return r;
}


void ntt_array(int x[N]) {
#pragma HLS INLINE
    int tmp[N];
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        tmp[ bit_reverse(i, LOGN) ] = x[i];
    }
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        x[i] = tmp[i];
    }

    for (int len = 2; len <= N; len <<= 1) {
        int wlen = modpow(ROOT, N / len);
        for (int i = 0; i < N; i += len) {
            int w = 1;
            for (int j = 0; j < len/2; j++) {
            #pragma HLS PIPELINE II=1
                int u = x[i + j];
                int v = mulmod(x[i + j + len/2], w);
                x[i + j]             = addmod(u, v);
                x[i + j + len/2]     = submod(u, v);
                w = mulmod(w, wlen);
            }
        }
    }
}

void intt_array(int x[N]) {
#pragma HLS INLINE
    for (int len = N; len >= 2; len >>= 1) {
        int wlen = modpow(ROOT_INV, N / len);
        for (int i = 0; i < N; i += len) {
            int w = 1;
            for (int j = 0; j < len/2; j++) {
            #pragma HLS PIPELINE II=1
                int u = x[i + j];
                int v = x[i + j + len/2];
                x[i + j] = addmod(u, v);
                x[i + j + len/2] = mulmod(submod(u, v), w);
                w = mulmod(w, wlen);
            }
        }
    }

    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        x[i] = mulmod(x[i], N_INV);
    }

    int tmp[N];
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        tmp[ bit_reverse(i, LOGN) ] = x[i];
    }
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        x[i] = tmp[i];
    }
}


void ntt_intt_top(
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


    int buf[N];
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        buf[i] = S_AXIS.read().data % 7681;
    }


    ntt_array(buf);

    intt_array(buf);

    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        axi_t o;
        o.data = buf[i];
        o.keep = -1;
        o.last = (i == N-1);
        M_AXIS.write(o);
    }
}

