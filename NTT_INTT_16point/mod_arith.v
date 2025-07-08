`timescale 1ns / 1ps

module mod_arith #(
  parameter integer DATA_WIDTH = 16,    // width of x, y, and results
  parameter integer MODULUS    = 17,    // prime modulus
  parameter integer EXP_WIDTH  = 8      // width of exponent
)(
  input  wire [DATA_WIDTH-1:0] x,       // operand 1
  input  wire [DATA_WIDTH-1:0] y,       // operand 2
  input  wire [EXP_WIDTH-1:0]  exp,     // exponent
  output wire [DATA_WIDTH-1:0] add_o,   // (x + y) mod MODULUS
  output wire [DATA_WIDTH-1:0] sub_o,   // (x - y) mod MODULUS
  output wire [DATA_WIDTH-1:0] mul_o,   // (x * y) mod MODULUS
  output wire [DATA_WIDTH-1:0] exp_o    // (x ^ exp) mod MODULUS
);

  // modular addition
  function [DATA_WIDTH-1:0] f_add;
    input [DATA_WIDTH-1:0] a, b;
    integer sum;
    begin
      sum = a + b;
      f_add = (sum >= MODULUS ? sum - MODULUS : sum);
    end
  endfunction

  // modular subtraction
  function [DATA_WIDTH-1:0] f_sub;
    input [DATA_WIDTH-1:0] a, b;
    integer diff;
    begin
      diff = a - b;
      f_sub = (diff < 0 ? diff + MODULUS : diff);
    end
  endfunction

  // modular multiplication
  function [DATA_WIDTH-1:0] f_mul;
    input [DATA_WIDTH-1:0] a, b;
    integer prod;
    begin
      prod = a * b;
      f_mul = prod % MODULUS;
    end
  endfunction

  // modular exponentiation (iterated multiply)
  function [DATA_WIDTH-1:0] f_exp;
    input [DATA_WIDTH-1:0] base;
    input [EXP_WIDTH-1:0]  e;
    integer k;
    reg [DATA_WIDTH-1:0] acc;
    begin
      acc = 1;
      for (k = 0; k < e; k = k + 1)
        acc = f_mul(acc, base);
      f_exp = acc;
    end
  endfunction


  assign add_o = f_add(x, y);
  assign sub_o = f_sub(x, y);
  assign mul_o = f_mul(x, y);
  assign exp_o = f_exp(x, exp);

endmodule
