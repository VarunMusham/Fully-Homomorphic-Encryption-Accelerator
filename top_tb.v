`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2025 11:48:52
// Design Name: 
// Module Name: top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps

module top_tb;

    // Inputs and Outputs for DUT
    reg clk;
    reg rst;
    reg start_sim;
    wire [511:0] recovered_message;
    wire final_done;
    
    // Expected message for self-verification
    localparam [511:0] EXPECTED_MESSAGE = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    // Instantiate the DUT (Device Under Test)
    top_module dut (
        .clk(clk),
        .rst(rst),
        .start_sim(start_sim),
        .recovered_message(recovered_message),
        .final_done(final_done)
    );

    // Clock Generation: 100MHz. THIS IS THE CRITICAL PART.
    initial clk = 0;
    always #5 clk = ~clk;

    // Simulation procedure
    initial begin
        // 1. Initialize and Reset
        rst = 1;
        start_sim = 0;
        #20;
        rst = 0;
        #10;
        
        // 2. Start the pipeline
        start_sim = 1;
        #10;
        start_sim = 0;

        $display("=============================================");
        $display("=== [BV-FHE System Simulation Started]    ===");
        $display("=== Waiting for pipeline to complete...   ===");
        $display("=============================================");

        // 3. Wait for completion
        wait (final_done);

        // 4. Verification
        #10; // Allow one cycle for final values to settle
        $display("=== [Pipeline Complete] ===");
        if (recovered_message === EXPECTED_MESSAGE) begin
            $display(">>> TEST PASSED! Recovered message matches expected message.");
        end else begin
            $display(">>> TEST FAILED! Mismatch found.");
            $display("    Expected:  %h", EXPECTED_MESSAGE);
            $display("    Recovered: %h", recovered_message);
        end

        // 5. Finish
        $display("=============================================");
        #20;
        $finish;
    end

endmodule

