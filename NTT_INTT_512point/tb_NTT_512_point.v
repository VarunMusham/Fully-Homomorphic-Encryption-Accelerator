`timescale 1ns/1ps
module tb_NTT_512_point;
  // Must match DUT parameters
  localparam N          = 512;
  localparam DATA_WIDTH = 16;
  localparam ADDR_WIDTH = 9;
  localparam MODULUS    = 7681;
  localparam ROOT       = 7146;
  localparam CLK_PERIOD = 10;

  // Clock
  reg clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  // DUT I/Os
  reg                          rst_n, start;
  reg  [N*DATA_WIDTH-1:0]      data_in;
  wire                         done;
  wire [N*DATA_WIDTH-1:0]      data_out;

  // Instantiate DUT with correct parameter names
  NTT_512_point #(
    .N(N),
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .MODULUS(MODULUS),
    .ROOT(ROOT)
  ) dut (
    .clk      (clk),
    .rst_n    (rst_n),
    .start    (start),
    .done     (done),
    .data_in  (data_in),
    .data_out (data_out)
  );

  // Unpack data_out into an array for waveform viewing
  wire [DATA_WIDTH-1:0] data_out_arr [0:N-1];
  genvar idx;
  generate
    for (idx = 440; idx < N; idx = idx + 1) begin : UNPACK
      assign data_out_arr[idx] = data_out[(idx+1)*DATA_WIDTH-1 -: DATA_WIDTH];
    end
  endgenerate

  integer i, out_f;
  initial begin
    // Reset
    rst_n   = 0; start = 0; data_in = 0;
    #(CLK_PERIOD*5);
    rst_n   = 1;
    #(CLK_PERIOD*2);

    // Load ramp 0..511
    for (i = 0; i < N; i = i + 1)
      data_in[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] = i;

    // Pulse start
    #(CLK_PERIOD);
    start = 1;
    @(posedge clk);
    start = 0;

    // Wait for done, then two clocks to let data_out settle
    @(posedge done);
    @(posedge clk);
    @(posedge clk);
    #1;

    // Display first 8 outputs
    $display("=== NTT complete at time %0t ===", $time);
    for (i = 0; i < 8; i = i + 1)
      $display("out[%0d] = %04h", i, data_out_arr[i]);

    // Dump full 512-point vector to file
    out_f = $fopen("ntt_out.txt", "w");
    for (i = 0; i < N; i = i + 1)
      $fdisplay(out_f, "out[%0d] = %04h", i, data_out_arr[i]);
    $fclose(out_f);
    $display("Full output in ntt_out.txt");

    $finish;
  end
endmodule
