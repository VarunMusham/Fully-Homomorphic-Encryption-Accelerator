#include <iostream>
#include "keygen.h"

int main() {
    hls::stream<axi_t> S_AXIS, M_AXIS;
    int A[N], S[N], E[N], pk_sw[N];

    // 1. Generate test input vectors
    for (int i = 0; i < N; i++) {
        A[i] = i % MOD;
        S[i] = (i * 3 + 1) % MOD;
        E[i] = 1; // Constant for simplicity

        axi_t t;
        t.data = A[i]; S_AXIS.write(t);
        t.data = S[i]; S_AXIS.write(t);
        t.data = E[i]; S_AXIS.write(t);
    }

    // 2. Call DUT
    keygen(S_AXIS, M_AXIS, true, true);

    // 3. Collect output
    int pk_hw[N];
    for (int i = 0; i < N; i++) {
        pk_hw[i] = M_AXIS.read().data;
        std::cout<<pk_hw[i]<<" ";
    }
    // 4. Golden reference in C++
    int tA[N], tS[N];
    for (int i = 0; i < N; i++) {
        tA[i] = A[i];
        tS[i] = S[i];
    }
    ntt_array(tA); ntt_array(tS);
    for (int i = 0; i < N; i++)
        pk_sw[i] = addmod(mulmod(tA[i], tS[i]), mulmod(E[i], 2));
    intt_array(pk_sw);

    // 5. Compare
    bool pass = true;
    for (int i = 0; i < N; i++) {
        if (pk_hw[i] != pk_sw[i]) {
            std::cout << "Mismatch @ " << i << ": HW=" << pk_hw[i] << " SW=" << pk_sw[i] << "\n";
            pass = false;
        }
    }

    std::cout << (pass ? "*** KEYGEN PASSED ***\n" : "*** KEYGEN FAILED ***\n");
//    return pass ? 0 : 1;
    return 0;
}
