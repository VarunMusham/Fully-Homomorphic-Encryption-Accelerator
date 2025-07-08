`timescale 1ns / 1ps


module intt16point_modular(
  input               clk,
  input               rst,    // synchronous load when 1, transform when 0
  input      [15:0]   in0,  in1,  in2,  in3,
  input      [15:0]   in4,  in5,  in6,  in7,
  input      [15:0]   in8,  in9,  in10, in11,
  input      [15:0]   in12, in13, in14, in15,
  output reg [15:0]   out0,  out1,  out2,  out3,
  output reg [15:0]   out4,  out5,  out6,  out7,
  output reg [15:0]   out8,  out9,  out10, out11,
  output reg [15:0]   out12, out13, out14, out15
);
  
  localparam integer N        = 16;
  localparam      [15:0] MOD      = 16'd17;
  localparam      [15:0] INV_ROOT = 16'd6;   
  localparam      [15:0] INV_N    = 16'd16;  
  

  reg [15:0] a0,  a1,  a2,  a3;
  reg [15:0] a4,  a5,  a6,  a7;
  reg [15:0] a8,  a9,  a10, a11;
  reg [15:0] a12, a13, a14, a15;

  
  wire [15:0] rev0,  rev1,  rev2,  rev3;
  wire [15:0] rev4,  rev5,  rev6,  rev7;
  wire [15:0] rev8,  rev9,  rev10, rev11;
  wire [15:0] rev12, rev13, rev14, rev15;

  wire [15:0] s1_0,  s1_1,  s1_2,  s1_3,  s1_4,  s1_5,  s1_6,  s1_7;
  wire [15:0] s1_8,  s1_9,  s1_10, s1_11, s1_12, s1_13, s1_14, s1_15;

  wire [15:0] s2_0,  s2_1,  s2_2,  s2_3,  s2_4,  s2_5,  s2_6,  s2_7;
  wire [15:0] s2_8,  s2_9,  s2_10, s2_11, s2_12, s2_13, s2_14, s2_15;

  wire [15:0] s3_0,  s3_1,  s3_2,  s3_3,  s3_4,  s3_5,  s3_6,  s3_7;
  wire [15:0] s3_8,  s3_9,  s3_10, s3_11, s3_12, s3_13, s3_14, s3_15;

  wire [15:0] s4_0,  s4_1,  s4_2,  s4_3,  s4_4,  s4_5,  s4_6,  s4_7;
  wire [15:0] s4_8,  s4_9,  s4_10, s4_11, s4_12, s4_13, s4_14, s4_15;

  wire [15:0] sc0,  sc1,  sc2,  sc3;
  wire [15:0] sc4,  sc5,  sc6,  sc7;
  wire [15:0] sc8,  sc9,  sc10, sc11;
  wire [15:0] sc12, sc13, sc14, sc15;

  bitrev #(
    .DATA_WIDTH(16),
    .N(N)
  ) br (
    .din0 (a0),   .din1 (a1),   .din2 (a2),   .din3 (a3),
    .din4 (a4),   .din5 (a5),   .din6 (a6),   .din7 (a7),
    .din8 (a8),   .din9 (a9),   .din10(a10),  .din11(a11),
    .din12(a12),  .din13(a13),  .din14(a14),  .din15(a15),
    .dout0(rev0), .dout1(rev1), .dout2(rev2), .dout3(rev3),
    .dout4(rev4), .dout5(rev5), .dout6(rev6), .dout7(rev7),
    .dout8(rev8), .dout9(rev9), .dout10(rev10),.dout11(rev11),
    .dout12(rev12),.dout13(rev13),.dout14(rev14),.dout15(rev15)
  );

  ntt_stage #(.STAGE(1), .DATA_WIDTH(16), .MODULUS(MOD), .ROOT(INV_ROOT)) s1 (
    .din0(rev0),  .din1(rev1),  .din2(rev2),  .din3(rev3),
    .din4(rev4),  .din5(rev5),  .din6(rev6),  .din7(rev7),
    .din8(rev8),  .din9(rev9),  .din10(rev10),.din11(rev11),
    .din12(rev12),.din13(rev13),.din14(rev14),.din15(rev15),
    .dout0(s1_0), .dout1(s1_1), .dout2(s1_2), .dout3(s1_3),
    .dout4(s1_4), .dout5(s1_5), .dout6(s1_6), .dout7(s1_7),
    .dout8(s1_8), .dout9(s1_9), .dout10(s1_10),.dout11(s1_11),
    .dout12(s1_12),.dout13(s1_13),.dout14(s1_14),.dout15(s1_15)
  );

  ntt_stage #(.STAGE(2), .DATA_WIDTH(16), .MODULUS(MOD), .ROOT(INV_ROOT)) s2 (
    .din0(s1_0),  .din1(s1_1),  .din2(s1_2),  .din3(s1_3),
    .din4(s1_4),  .din5(s1_5),  .din6(s1_6),  .din7(s1_7),
    .din8(s1_8),  .din9(s1_9),  .din10(s1_10),.din11(s1_11),
    .din12(s1_12),.din13(s1_13),.din14(s1_14),.din15(s1_15),
    .dout0(s2_0), .dout1(s2_1), .dout2(s2_2), .dout3(s2_3),
    .dout4(s2_4), .dout5(s2_5), .dout6(s2_6), .dout7(s2_7),
    .dout8(s2_8), .dout9(s2_9), .dout10(s2_10),.dout11(s2_11),
    .dout12(s2_12),.dout13(s2_13),.dout14(s2_14),.dout15(s2_15)
  );

  ntt_stage #(.STAGE(3), .DATA_WIDTH(16), .MODULUS(MOD), .ROOT(INV_ROOT)) s3 (
    .din0(s2_0),  .din1(s2_1),  .din2(s2_2),  .din3(s2_3),
    .din4(s2_4),  .din5(s2_5),  .din6(s2_6),  .din7(s2_7),
    .din8(s2_8),  .din9(s2_9),  .din10(s2_10),.din11(s2_11),
    .din12(s2_12),.din13(s2_13),.din14(s2_14),.din15(s2_15),
    .dout0(s3_0), .dout1(s3_1), .dout2(s3_2), .dout3(s3_3),
    .dout4(s3_4), .dout5(s3_5), .dout6(s3_6), .dout7(s3_7),
    .dout8(s3_8), .dout9(s3_9), .dout10(s3_10),.dout11(s3_11),
    .dout12(s3_12),.dout13(s3_13),.dout14(s3_14),.dout15(s3_15)
  );

  ntt_stage #(.STAGE(4), .DATA_WIDTH(16), .MODULUS(MOD), .ROOT(INV_ROOT)) s4 (
    .din0(s3_0),  .din1(s3_1),  .din2(s3_2),  .din3(s3_3),
    .din4(s3_4),  .din5(s3_5),  .din6(s3_6),  .din7(s3_7),
    .din8(s3_8),  .din9(s3_9),  .din10(s3_10),.din11(s3_11),
    .din12(s3_12),.din13(s3_13),.din14(s3_14),.din15(s3_15),
    .dout0(s4_0), .dout1(s4_1), .dout2(s4_2), .dout3(s4_3),
    .dout4(s4_4), .dout5(s4_5), .dout6(s4_6), .dout7(s4_7),
    .dout8(s4_8), .dout9(s4_9), .dout10(s4_10),.dout11(s4_11),
    .dout12(s4_12),.dout13(s4_13),.dout14(s4_14),.dout15(s4_15)
  );

  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m0  (.x(s4_0),  .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc0),  .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m1  (.x(s4_1),  .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc1),  .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m2  (.x(s4_2),  .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc2),  .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m3  (.x(s4_3),  .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc3),  .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m4  (.x(s4_4),  .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc4),  .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m5  (.x(s4_5),  .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc5),  .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m6  (.x(s4_6),  .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc6),  .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m7  (.x(s4_7),  .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc7),  .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m8  (.x(s4_8),  .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc8),  .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m9  (.x(s4_9),  .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc9),  .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m10 (.x(s4_10), .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc10), .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m11 (.x(s4_11), .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc11), .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m12 (.x(s4_12), .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc12), .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m13 (.x(s4_13), .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc13), .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m14 (.x(s4_14), .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc14), .exp_o());
  mod_arith #(.DATA_WIDTH(16), .MODULUS(MOD), .EXP_WIDTH(1))
    m15 (.x(s4_15), .y(INV_N), .exp(1'b0), .add_o(), .sub_o(), .mul_o(sc15), .exp_o());

  always @(posedge clk) begin
    if (rst) begin
      a0  <= in0;   a1  <= in1;   a2  <= in2;   a3  <= in3;
      a4  <= in4;   a5  <= in5;   a6  <= in6;   a7  <= in7;
      a8  <= in8;   a9  <= in9;   a10 <= in10;  a11 <= in11;
      a12 <= in12;  a13 <= in13;  a14 <= in14;  a15 <= in15;
    end else begin
      a0  <= sc0;   a1  <= sc1;   a2  <= sc2;   a3  <= sc3;
      a4  <= sc4;   a5  <= sc5;   a6  <= sc6;   a7  <= sc7;
      a8  <= sc8;   a9  <= sc9;   a10 <= sc10;  a11 <= sc11;
      a12 <= sc12;  a13 <= sc13;  a14 <= sc14;  a15 <= sc15;
    end
  end

  always @(posedge clk) begin
    out0  <= a0;   out1  <= a1;   out2  <= a2;   out3  <= a3;
    out4  <= a4;   out5  <= a5;   out6  <= a6;   out7  <= a7;
    out8  <= a8;   out9  <= a9;   out10 <= a10;  out11 <= a11;
    out12 <= a12;  out13 <= a13;  out14 <= a14;  out15 <= a15;
  end

endmodule
