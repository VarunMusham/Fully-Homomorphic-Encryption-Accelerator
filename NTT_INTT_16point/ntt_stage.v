`timescale 1ns / 1ps

module ntt_stage #(
  parameter integer STAGE      = 1,
  parameter integer N          = 16,
  parameter integer DATA_WIDTH = 16,
  parameter integer MODULUS    = 17,
  parameter integer ROOT       = 3
)(
  input  wire [DATA_WIDTH-1:0] din0,  din1,  din2,  din3,
  input  wire [DATA_WIDTH-1:0] din4,  din5,  din6,  din7,
  input  wire [DATA_WIDTH-1:0] din8,  din9,  din10, din11,
  input  wire [DATA_WIDTH-1:0] din12, din13, din14, din15,
  output wire [DATA_WIDTH-1:0] dout0, dout1, dout2, dout3,
  output wire [DATA_WIDTH-1:0] dout4, dout5, dout6, dout7,
  output wire [DATA_WIDTH-1:0] dout8, dout9, dout10, dout11,
  output wire [DATA_WIDTH-1:0] dout12, dout13, dout14, dout15
);

  // number of points in this stage
  localparam integer LEN  = 1 << STAGE;
  localparam integer HALF = LEN >> 1;
  // precompute WLEN = ROOT^(N/LEN) mod MODULUS
  function [DATA_WIDTH-1:0] f_const_exp;
    input integer base, expn;
    integer k;
    reg [DATA_WIDTH-1:0] acc;
    begin
      acc = 1;
      for (k = 0; k < expn; k = k + 1)
        acc = (acc * base) % MODULUS;
      f_const_exp = acc;
    end
  endfunction

  localparam [DATA_WIDTH-1:0] WLEN = f_const_exp(ROOT, N/LEN);


  wire [DATA_WIDTH-1:0] a [0:N-1];
  wire [DATA_WIDTH-1:0] b [0:N-1];

  assign a[0]  = din0;   assign a[1]  = din1;
  assign a[2]  = din2;   assign a[3]  = din3;
  assign a[4]  = din4;   assign a[5]  = din5;
  assign a[6]  = din6;   assign a[7]  = din7;
  assign a[8]  = din8;   assign a[9]  = din9;
  assign a[10] = din10;  assign a[11] = din11;
  assign a[12] = din12;  assign a[13] = din13;
  assign a[14] = din14;  assign a[15] = din15;


  generate
    genvar base_idx, j;
    for (base_idx = 0; base_idx < N; base_idx = base_idx + LEN) begin : BASE
      for (j = 0; j < HALF; j = j + 1) begin : BFY
        localparam integer IDX0 = base_idx + j;
        localparam integer IDX1 = base_idx + j + HALF;
        localparam [DATA_WIDTH-1:0] WJ = f_const_exp(WLEN, j);

        butterfly #(
          .DATA_WIDTH(DATA_WIDTH),
          .MODULUS   (MODULUS)
        ) u_bfly (
          .u        (a[IDX0]),
          .v        (a[IDX1]),
          .twiddle  (WJ),
          .out_sum  (b[IDX0]),
          .out_diff (b[IDX1])
        );
      end
    end
  endgenerate


  assign dout0  = b[0];   assign dout1  = b[1];
  assign dout2  = b[2];   assign dout3  = b[3];
  assign dout4  = b[4];   assign dout5  = b[5];
  assign dout6  = b[6];   assign dout7  = b[7];
  assign dout8  = b[8];   assign dout9  = b[9];
  assign dout10 = b[10];  assign dout11 = b[11];
  assign dout12 = b[12];  assign dout13 = b[13];
  assign dout14 = b[14];  assign dout15 = b[15];

endmodule
