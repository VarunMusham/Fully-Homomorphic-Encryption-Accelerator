module prng_512bit_lfsr (
    input wire clk,
    input wire rst,
    input wire [8:0] seed,
    input wire load_seed,          // signal to load random or normal seed
    output reg [511:0] prng_out,
    output reg done
);

    reg [8:0] lfsr;
    wire feedback;
    reg [8:0] bit_counter;

    assign feedback = lfsr[8] ^ lfsr[3];

    always @(posedge clk) begin
        if (rst) begin
            lfsr <= 9'b0;
            prng_out <= 0;
            bit_counter <= 0;
            done <= 0;
        end else if (load_seed) begin
            lfsr <= seed;                  // load manual seed
        end else if (!done) begin
            lfsr <= {lfsr[7:0], feedback};
            prng_out <= {prng_out[510:0], lfsr[0]};
            bit_counter <= bit_counter + 1;

            if (bit_counter == 511)
                done <= 1;
        end
    end

endmodule
