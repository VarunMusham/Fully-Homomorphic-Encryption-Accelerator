`timescale 1ns/1ps

module INTT_512_point #(
    parameter N           = 512,
    parameter DATA_WIDTH  = 16,
    parameter ADDR_WIDTH  = 9,       // log2(N)
    parameter MODULUS     = 7681,
    parameter ROOT_INV    = 7480,    // inverse of primitive root mod 7681
    parameter N_INV       = 7666     // inverse of N mod 7681
) (
    input  wire                        clk,
    input  wire                        rst_n,
    input  wire                        start,
    output wire                        done,
    input  wire [N*DATA_WIDTH-1:0]     data_in,
    output reg  [N*DATA_WIDTH-1:0]     data_out
);

    // Internal arrays
    reg [DATA_WIDTH-1:0] vec [0:N-1];
    reg [DATA_WIDTH-1:0] out [0:N-1];

    // Done flag
    reg done_reg;
    assign done = done_reg;

    // Work variables
    integer k, n, j;
    reg [2*DATA_WIDTH-1:0] term;
    reg [2*DATA_WIDTH-1:0] scaled;
    reg [DATA_WIDTH-1:0]   accumulator;
    reg [DATA_WIDTH-1:0]   omega_pow;      // (ROOT_INV)^k
    reg [DATA_WIDTH-1:0]   omega_nk;       // ((ROOT_INV)^k)^n

    // Wait for reset, then forever on start do the O(N^2) INTT
    initial begin
        done_reg = 1'b0;
        wait(rst_n == 1);

        forever begin
            @(posedge start);

            // 1) unpack input flatten ? vec[]
            for (n = 0; n < N; n = n + 1) begin
                vec[n] = data_in[(n+1)*DATA_WIDTH-1 -: DATA_WIDTH];
            end

            // 2) brute-force INTT
            for (k = 0; k < N; k = k + 1) begin
                // Compute (ROOT_INV)^k by repeated multiply
                omega_pow = 1;
                for (j = 0; j < k; j = j + 1) begin
                    term      = omega_pow * ROOT_INV;
                    omega_pow = term % MODULUS;
                end

                // Sum: X[k] = N_INV * ? vec[n] * ((ROOT_INV)^k)^n mod p
                accumulator = 0;
                omega_nk    = 1;  // starts ((ROOT_INV)^k)^0

                for (n = 0; n < N; n = n + 1) begin
                    // term = vec[n] * omega_nk
                    term        = vec[n] * omega_nk;
                    accumulator = (accumulator + (term % MODULUS)) % MODULUS;

                    // omega_nk *= omega_pow
                    term     = omega_nk * omega_pow;
                    omega_nk = term % MODULUS;
                end

                // Final multiply by N_INV
                scaled = accumulator * N_INV;
                out[k] = scaled % MODULUS;
            end

            // 3) pack out[] ? data_out flatten
            for (k = 0; k < N; k = k + 1) begin
                data_out[(k+1)*DATA_WIDTH-1 -: DATA_WIDTH] = out[k];
            end

            // 4) pulse done
            done_reg = 1'b1;
            #100;
            done_reg = 1'b0;
        end
    end
endmodule
