`timescale 1ns / 1ps
module butterfly #(
  parameter integer DATA_WIDTH = 16,   
  parameter integer MODULUS    = 17    // prime modulus
)(
  input  wire [DATA_WIDTH-1:0] u,        
  input  wire [DATA_WIDTH-1:0] v,        
  input  wire [DATA_WIDTH-1:0] twiddle,  
  output wire [DATA_WIDTH-1:0] out_sum,  
  output wire [DATA_WIDTH-1:0] out_diff  
);

  wire [DATA_WIDTH-1:0] v_mul;
  mod_arith #(
    .DATA_WIDTH(DATA_WIDTH),
    .MODULUS   (MODULUS),
    .EXP_WIDTH (1)           
  ) mul_unit (
    .x    (v),
    .y    (twiddle),
    .exp  (1'b0),           
    .add_o(),               
    .sub_o(),               
    .mul_o(v_mul),          
    .exp_o()                
  );

  // Now compute out_sum = (u + v_mul) mod M
  //         and out_diff = (u - v_mul) mod M
  mod_arith #(
    .DATA_WIDTH(DATA_WIDTH),
    .MODULUS   (MODULUS),
    .EXP_WIDTH (1)
  ) addsub_unit (
    .x    (u),
    .y    (v_mul),
    .exp  (1'b0),
    .add_o(out_sum),
    .sub_o(out_diff),
    .mul_o(),               
    .exp_o()                
  );

endmodule
