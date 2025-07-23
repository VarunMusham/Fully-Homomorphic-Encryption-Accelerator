#include <iostream>
#include <hls_stream.h>
#include <ap_axi_sdata.h>
#include "ntt_mult.h"
#include "ntt_utils.h"

using AxiWord = ap_axiu<32,0,0,0>;

void test_ntt_mult_print() {
    constexpr int N   = ::N;
    constexpr int MOD = ::MOD;

    
    int P1[N], P2[N], C_ref[N];
    for (int i = 0; i < N; i++) {
        P1[i] = i % MOD;
        P2[i] = (i * 2 + 1) % MOD;
    }

    
    for (int k = 0; k < N; k++) {
        long long acc = 0;
        for (int j = 0; j < N; j++) {
            int idx = (k - j + N) % N;
            acc += (long long)P1[j] * P2[idx];
        }
        C_ref[k] = acc % MOD;
    }

    
    std::cout << "=== Input P1 ===\n";
    for (int i = 0; i < N; i++) {
        std::cout << P1[i] << (i % 16 == 15 ? "\n" : " ");
    }
    std::cout << "\n=== Input P2 ===\n";
    for (int i = 0; i < N; i++) {
        std::cout << P2[i] << (i % 16 == 15 ? "\n" : " ");
    }
    std::cout << std::endl;

    
    hls::stream<AxiWord> in_strm, out_strm;
    for (int i = 0; i < N; i++) {
        AxiWord t; t.data = P1[i]; t.keep = -1; t.last = 0;
        in_strm.write(t);
    }
    for (int i = 0; i < N; i++) {
        AxiWord t; t.data = P2[i]; t.keep = -1; t.last = (i==N-1);
        in_strm.write(t);
    }

    
    ntt_mult(in_strm, out_strm, true, true);

    
    bool pass = true;
    std::cout << "=== Output C (NTT_mult result) ===\n";
    for (int i = 0; i < N; i++) {
        AxiWord o = out_strm.read();
        int got = o.data % MOD;
        std::cout << got << (i % 16 == 15 ? "\n" : " ");
        if (got != C_ref[i] && pass) {
            
            std::cout << "\n-- Mismatch at index " << i
                      << ": got " << got
                      << " expected " << C_ref[i] << " --\n";
            pass = false;
        }
    }
    std::cout << std::endl;

    if (pass) std::cout << "*** TEST PASSED ***\n";
    else      std::cout << "*** TEST FAILED ***\n";
}

int main() {
    test_ntt_mult_print();
    return 0;
}
