`timescale 1ns / 1ps

module bitrev #(
  parameter integer DATA_WIDTH = 16,  
  parameter integer N          = 16    
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

  function [3:0] f_bitrev;
    input [3:0] idx;
    begin
      f_bitrev = { idx[0], idx[1], idx[2], idx[3] };
    end
  endfunction

  wire [DATA_WIDTH-1:0] A [0:N-1];
  wire [DATA_WIDTH-1:0] B [0:N-1];

  assign A[0]=din0;   assign A[1]=din1;   assign A[2]=din2;   assign A[3]=din3;
  assign A[4]=din4;   assign A[5]=din5;   assign A[6]=din6;   assign A[7]=din7;
  assign A[8]=din8;   assign A[9]=din9;   assign A[10]=din10; assign A[11]=din11;
  assign A[12]=din12; assign A[13]=din13; assign A[14]=din14; assign A[15]=din15;

  generate
    genvar i;
    for (i = 0; i < N; i = i + 1) begin : REV
      localparam [3:0] R = f_bitrev(i[3:0]);
      assign B[R] = A[i];
    end
  endgenerate

  assign dout0  = B[0];   assign dout1  = B[1];
  assign dout2  = B[2];   assign dout3  = B[3];
  assign dout4  = B[4];   assign dout5  = B[5];
  assign dout6  = B[6];   assign dout7  = B[7];
  assign dout8  = B[8];   assign dout9  = B[9];
  assign dout10 = B[10];  assign dout11 = B[11];
  assign dout12 = B[12];  assign dout13 = B[13];
  assign dout14 = B[14];  assign dout15 = B[15];

endmodule
