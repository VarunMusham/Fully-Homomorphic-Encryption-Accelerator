#include <iostream>
#include "decrypt.h"

int main() {
    hls::stream<axi_t> S_AXIS, M_AXIS;
    int V[N], W[N], S[N], m_hw[N], m_sw[N];

    
    for (int i = 0; i < N; i++) {
        V[i] = i % MOD;
        W[i] = (V[i] * 3 + 1) % MOD;
        S[i] = 3;

        axi_t t;
        t.data = V[i]; S_AXIS.write(t);
        t.data = W[i]; S_AXIS.write(t);
        t.data = S[i]; S_AXIS.write(t);
    }

    
    decrypt(S_AXIS, M_AXIS, true, true);

    
    for (int i = 0; i < N; i++) {
        m_hw[i] = M_AXIS.read().data & 1;
    }

    
    int tA[N], tB[N], U[N];
    for (int i = 0; i < N; i++) { tA[i] = V[i]; tB[i] = S[i]; }
    ntt_array(tA); ntt_array(tB);
    for (int i = 0; i < N; i++) U[i] = mulmod(tA[i], tB[i]);
    intt_array(U);
    for (int i = 0; i < N; i++)
        m_sw[i] = submod(W[i], U[i]) & 1;

    
    bool pass = true;
    for (int i = 0; i < N; i++) {
        if (m_hw[i] != m_sw[i]) {
            std::cout << "Mismatch @ " << i << ": HW=" << m_hw[i] << " SW=" << m_sw[i] << "\n";
            pass = false;
        }
    }

    std::cout << (pass ? "*** DECRYPT PASSED ***\n" : "*** DECRYPT FAILED ***\n");
    return pass ? 0 : 1;
}
