#include "ntt_ip.h"
#include <hls_stream.h>

#define N   512
#define MOD 7681
#define ROOT 7146   
int mulmod(int a, int b) {
    return ((long long)a * b) % MOD;
}

int addmod(int a, int b) {
    int res = a + b;
    if (res >= MOD) res -= MOD;
    return res;
}

int submod(int a, int b) {
    int res = a - b;
    if (res < 0) res += MOD;
    return res;
}

int modpow(int x, int e)
{
    int r = 1;
    for(; e; e>>=1, x = mulmod(x,x))
        if(e & 1) r = mulmod(r,x);
    return r;
}

int bit_reverse(int v, int lg)
{
    int r = 0;
    for(int i=0;i<lg;++i)
        if(v & (1<<i)) r |= 1 << (lg-1-i);
    return r;
}

void ntt_ip(hls::stream<axi_t> &S_AXIS,
            hls::stream<axi_t> &M_AXIS,
            bool s_axis_aresetn,
            bool s_axis_aclk)
{
#pragma HLS interface axis port=S_AXIS
#pragma HLS interface axis port=M_AXIS
#pragma HLS interface ap_ctrl_none port=return
#pragma HLS interface ap_none port=s_axis_aresetn
#pragma HLS interface ap_none port=s_axis_aclk

    if (!s_axis_aresetn) return;

    const int LOGN = 9;     
    int x[N], tmp[N];

    
    for(int i=0;i<N;i++){
#pragma HLS PIPELINE II=1
        x[i] = S_AXIS.read().data % MOD;
    }

    
    for(int i=0;i<N;i++)
        tmp[bit_reverse(i,LOGN)] = x[i];
    for(int i=0;i<N;i++)
        x[i] = tmp[i];

    
    for(int len=2; len<=N; len<<=1){
        int wlen = modpow(ROOT, N/len);   
        for(int i=0;i<N; i+=len){
            int w = 1;
            for(int j=0;j<len/2; ++j){
#pragma HLS PIPELINE II=1
                int u = x[i+j];
                int v = mulmod(x[i+j+len/2], w);
                x[i+j]           = addmod(u,v);
                x[i+j+len/2]     = submod(u,v);
                w = mulmod(w, wlen);
            }
        }
    }

    
    for(int i=0;i<N;i++){
#pragma HLS PIPELINE II=1
        axi_t out;
        out.data = x[i];
        out.keep = -1;
        out.last = (i==N-1);
        M_AXIS.write(out);
    }
}
