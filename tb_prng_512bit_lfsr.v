`timescale 1ns/1ps

module tb_prng_512bit_lfsr;

    reg clk;
    reg rst;
    reg [8:0] seed;
    reg load_seed;

    wire [511:0] prng_out;
    wire done;

    prng_512bit_lfsr uut (
        .clk(clk),
        .rst(rst),
        .seed(seed),
        .load_seed(load_seed),
        .prng_out(prng_out),
        .done(done)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Step 1: Reset
        rst = 1;
        load_seed = 0;
        seed = 9'b0;
        #20;

        rst = 0;

        // Step 2: Randomize and load the seed
        seed = $urandom % 512;  // random 9-bit value
        load_seed = 1;
        $display("Random Seed Used: %b (%0d)", seed, seed);

        #10;
        load_seed = 0;

        // Step 3: Wait for done
        wait(done);

        $display("PRNG 512-bit Output:\n%h", prng_out);
        $finish;
    end

endmodule
