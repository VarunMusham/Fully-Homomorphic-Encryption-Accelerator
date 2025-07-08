`timescale 1ns / 1ps

module ram16 #(
  parameter integer DATA_WIDTH = 16,
  parameter integer N          = 16
)(
  input  wire                   clk,   
  input  wire                   load,  // when high, load inputs on rising edge
  input  wire [DATA_WIDTH-1:0]  din0,  din1,  din2,  din3,
  input  wire [DATA_WIDTH-1:0]  din4,  din5,  din6,  din7,
  input  wire [DATA_WIDTH-1:0]  din8,  din9,  din10, din11,
  input  wire [DATA_WIDTH-1:0]  din12, din13, din14, din15,
  output wire [DATA_WIDTH-1:0]  dout0, dout1, dout2, dout3,
  output wire [DATA_WIDTH-1:0]  dout4, dout5, dout6, dout7,
  output wire [DATA_WIDTH-1:0]  dout8, dout9, dout10, dout11,
  output wire [DATA_WIDTH-1:0]  dout12, dout13, dout14, dout15
);

  // internal memory array
  reg [DATA_WIDTH-1:0] mem [0:N-1];

  integer i;
  // synchronous load on rising edge
  always @(posedge clk) begin
    if (load) begin
      mem[0]  <= din0;  mem[1]  <= din1;
      mem[2]  <= din2;  mem[3]  <= din3;
      mem[4]  <= din4;  mem[5]  <= din5;
      mem[6]  <= din6;  mem[7]  <= din7;
      mem[8]  <= din8;  mem[9]  <= din9;
      mem[10] <= din10; mem[11] <= din11;
      mem[12] <= din12; mem[13] <= din13;
      mem[14] <= din14; mem[15] <= din15;
    end
  end

  // combinational read
  assign dout0  = mem[0];   assign dout1  = mem[1];
  assign dout2  = mem[2];   assign dout3  = mem[3];
  assign dout4  = mem[4];   assign dout5  = mem[5];
  assign dout6  = mem[6];   assign dout7  = mem[7];
  assign dout8  = mem[8];   assign dout9  = mem[9];
  assign dout10 = mem[10];  assign dout11 = mem[11];
  assign dout12 = mem[12];  assign dout13 = mem[13];
  assign dout14 = mem[14];  assign dout15 = mem[15];

endmodule
