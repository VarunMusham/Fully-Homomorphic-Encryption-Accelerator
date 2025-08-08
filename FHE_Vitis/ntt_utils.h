// ntt_utils.h
#ifndef NTT_UTILS_H
#define NTT_UTILS_H

#include "ap_axi_sdata.h"  


static const int N        = 512;
static const int MOD      = 7681;
static const int ROOT     = 7146;
static const int ROOT_INV = 7480;
static const int N_INV    = 7666;
static const int LOGN     = 9;
typedef ap_axiu<32,0,0,0> axi_t;


static inline int mulmod(int a, int b) {
    return (long long)a * b % MOD;
}

static inline int addmod(int a, int b) {
    int r = a + b;  return (r >= MOD) ? r - MOD : r;
}

static inline int submod(int a, int b) {
    int r = a - b;  return (r < 0)   ? r + MOD : r;
}

static inline int modpow(int base, int exp) {
    int result = 1;
    while (exp) {
        if (exp & 1) result = mulmod(result, base);
        base = mulmod(base, base);
        exp >>= 1;
    }
    return result;
}

static inline int bit_reverse(int v, int lg) {
    int r = 0;
    for (int i = 0; i < lg; i++)
        if (v & (1 << i))
            r |= 1 << (lg - 1 - i);
    return r;
}


static inline void ntt_array(int x[N]) {
    int tmp[N];
    // 
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        tmp[ bit_reverse(i, LOGN) ] = x[i];
    }
    for (int i = 0; i < N; i++) {
    #pragma HLS PIPELINE II=1
        x[i] = tmp[i];
    }

    // Cooley-Tukey NTT
    for (int len = 2; len <= N; len <<= 1) {
        int wlen = modpow(ROOT, N / len);
        for (int i = 0; i < N; i += len) {
            int w = 1;
            for (int j = 0; j < len/2; j++) {
            #pragma HLS PIPELINE II=1
                int u = x[i+j];
                int v = mulmod(x[i+j+len/2], w);
                x[i+j]           = addmod(u,v);
                x[i+j+len/2]     = submod(u,v);
                w = mulmod(w, wlen);
            }
        }
    }
}



static inline void intt_array(int x[N]) {
    
    for (int len = N; len >= 2; len >>= 1) {
        int wlen = modpow(ROOT_INV, N / len);
        for (int i = 0; i < N; i += len) {
            int w = 1;
            for (int j = 0; j < len/2; j++) {
            #pragma HLS PIPELINE II=1
                int u = x[i+j];
                int v = x[i+j+len/2];
                x[i+j]           = addmod(u,v);
                x[i+j+len/2]     = mulmod(submod(u,v), w);
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

#endif 
