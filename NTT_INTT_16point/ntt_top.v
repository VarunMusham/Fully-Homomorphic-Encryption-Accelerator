`timescale 1ns / 1ps

module ntt_top #(
  parameter integer DATA_WIDTH = 16,
  parameter integer N          = 16,
  parameter integer MODULUS    = 17,
  parameter integer ROOT       = 3
)(
  input  wire                       clk,
  input  wire                       rst,
  input  wire                       start,
  // 16-point input
  input  wire [DATA_WIDTH-1:0]      din0,  din1,  din2,  din3,
  input  wire [DATA_WIDTH-1:0]      din4,  din5,  din6,  din7,
  input  wire [DATA_WIDTH-1:0]      din8,  din9,  din10, din11,
  input  wire [DATA_WIDTH-1:0]      din12, din13, din14, din15,
  // 16-point output
  output wire [DATA_WIDTH-1:0]      dout0,  dout1,  dout2,  dout3,
  output wire [DATA_WIDTH-1:0]      dout4,  dout5,  dout6,  dout7,
  output wire [DATA_WIDTH-1:0]      dout8,  dout9,  dout10, dout11,
  output wire [DATA_WIDTH-1:0]      dout12, dout13, dout14, dout15,
  output wire                       done
);

  // FSM states
  localparam [2:0]
    IDLE   = 3'd0,
    LOAD   = 3'd1,
    BITREV = 3'd2,
    STG1   = 3'd3,
    STG2   = 3'd4,
    STG3   = 3'd5,
    STG4   = 3'd6,
    DONE_ST= 3'd7;

  reg [2:0] state, next_state;
  reg       load;
  // RAM I/O
  wire [DATA_WIDTH-1:0] ram_dout0,  ram_dout1,  ram_dout2,  ram_dout3;
  wire [DATA_WIDTH-1:0] ram_dout4,  ram_dout5,  ram_dout6,  ram_dout7;
  wire [DATA_WIDTH-1:0] ram_dout8,  ram_dout9,  ram_dout10, ram_dout11;
  wire [DATA_WIDTH-1:0] ram_dout12, ram_dout13, ram_dout14, ram_dout15;
  reg  [DATA_WIDTH-1:0] ram_din0,   ram_din1,   ram_din2,   ram_din3;
  reg  [DATA_WIDTH-1:0] ram_din4,   ram_din5,   ram_din6,   ram_din7;
  reg  [DATA_WIDTH-1:0] ram_din8,   ram_din9,   ram_din10,  ram_din11;
  reg  [DATA_WIDTH-1:0] ram_din12,  ram_din13,  ram_din14,  ram_din15;

  // bit-reversal outputs
  wire [DATA_WIDTH-1:0] rev0,  rev1,  rev2,  rev3;
  wire [DATA_WIDTH-1:0] rev4,  rev5,  rev6,  rev7;
  wire [DATA_WIDTH-1:0] rev8,  rev9,  rev10, rev11;
  wire [DATA_WIDTH-1:0] rev12, rev13, rev14, rev15;

  // stage outputs
  wire [DATA_WIDTH-1:0] s10,  s11,  s12,  s13;
  wire [DATA_WIDTH-1:0] s14,  s15,  s16,  s17;
  wire [DATA_WIDTH-1:0] s18,  s19,  s110, s111;
  wire [DATA_WIDTH-1:0] s112, s113, s114, s115;

  wire [DATA_WIDTH-1:0] s20,  s21,  s22,  s23;
  wire [DATA_WIDTH-1:0] s24,  s25,  s26,  s27;
  wire [DATA_WIDTH-1:0] s28,  s29,  s210, s211;
  wire [DATA_WIDTH-1:0] s212, s213, s214, s215;

  wire [DATA_WIDTH-1:0] s30,  s31,  s32,  s33;
  wire [DATA_WIDTH-1:0] s34,  s35,  s36,  s37;
  wire [DATA_WIDTH-1:0] s38,  s39,  s310, s311;
  wire [DATA_WIDTH-1:0] s312, s313, s314, s315;

  wire [DATA_WIDTH-1:0] s40,  s41,  s42,  s43;
  wire [DATA_WIDTH-1:0] s44,  s45,  s46,  s47;
  wire [DATA_WIDTH-1:0] s48,  s49,  s410, s411;
  wire [DATA_WIDTH-1:0] s412, s413, s414, s415;


  // 1) FSM
  always @(posedge clk) begin
    if (rst) state <= IDLE;
    else      state <= next_state;
  end

  always @(*) begin
    next_state = state;
    load       = 1'b0;
    case(state)
      IDLE:    if (start)        next_state = LOAD;
      LOAD:                       begin load = 1'b1; next_state = BITREV; end
      BITREV:                     begin load = 1'b1; next_state = STG1;  end
      STG1:                       begin load = 1'b1; next_state = STG2;  end
      STG2:                       begin load = 1'b1; next_state = STG3;  end
      STG3:                       begin load = 1'b1; next_state = STG4;  end
      STG4:                       begin load = 1'b1; next_state = DONE_ST; end
      DONE_ST:                   next_state = IDLE;
    endcase
  end

  // 2) RAM-input multiplexer
  always @(*) begin
    case(state)
      LOAD:   {ram_din0,ram_din1,ram_din2,ram_din3,
               ram_din4,ram_din5,ram_din6,ram_din7,
               ram_din8,ram_din9,ram_din10,ram_din11,
               ram_din12,ram_din13,ram_din14,ram_din15}
              = {din0, din1, din2, din3,
                 din4, din5, din6, din7,
                 din8, din9, din10, din11,
                 din12, din13, din14, din15};

      BITREV: {ram_din0,ram_din1,ram_din2,ram_din3,
               ram_din4,ram_din5,ram_din6,ram_din7,
               ram_din8,ram_din9,ram_din10,ram_din11,
               ram_din12,ram_din13,ram_din14,ram_din15}
              = {rev0, rev1, rev2, rev3,
                 rev4, rev5, rev6, rev7,
                 rev8, rev9, rev10,rev11,
                 rev12,rev13,rev14,rev15};

      STG1:   {ram_din0,ram_din1,ram_din2,ram_din3,
               ram_din4,ram_din5,ram_din6,ram_din7,
               ram_din8,ram_din9,ram_din10,ram_din11,
               ram_din12,ram_din13,ram_din14,ram_din15}
              = {s10, s11, s12, s13,
                 s14, s15, s16, s17,
                 s18, s19, s110,s111,
                 s112,s113,s114,s115};

      STG2:   {ram_din0,ram_din1,ram_din2,ram_din3,
               ram_din4,ram_din5,ram_din6,ram_din7,
               ram_din8,ram_din9,ram_din10,ram_din11,
               ram_din12,ram_din13,ram_din14,ram_din15}
              = {s20, s21, s22, s23,
                 s24, s25, s26, s27,
                 s28, s29, s210,s211,
                 s212,s213,s214,s215};

      STG3:   {ram_din0,ram_din1,ram_din2,ram_din3,
               ram_din4,ram_din5,ram_din6,ram_din7,
               ram_din8,ram_din9,ram_din10,ram_din11,
               ram_din12,ram_din13,ram_din14,ram_din15}
              = {s30, s31, s32, s33,
                 s34, s35, s36, s37,
                 s38, s39, s310,s311,
                 s312,s313,s314,s315};

      STG4:   {ram_din0,ram_din1,ram_din2,ram_din3,
               ram_din4,ram_din5,ram_din6,ram_din7,
               ram_din8,ram_din9,ram_din10,ram_din11,
               ram_din12,ram_din13,ram_din14,ram_din15}
              = {s40, s41, s42, s43,
                 s44, s45, s46, s47,
                 s48, s49, s410,s411,
                 s412,s413,s414,s415};

      default:  // IDLE & DONE_ST
        {ram_din0,ram_din1,ram_din2,ram_din3,
         ram_din4,ram_din5,ram_din6,ram_din7,
         ram_din8,ram_din9,ram_din10,ram_din11,
         ram_din12,ram_din13,ram_din14,ram_din15}
        = {ram_dout0,ram_dout1,ram_dout2,ram_dout3,
           ram_dout4,ram_dout5,ram_dout6,ram_dout7,
           ram_dout8,ram_dout9,ram_dout10,ram_dout11,
           ram_dout12,ram_dout13,ram_dout14,ram_dout15};
    endcase
  end

  // 3) The single 16-word RAM
  ram16 #(.DATA_WIDTH(DATA_WIDTH), .N(N)) ram_u (
    .clk   (clk),    .load  (load),
    .din0  (ram_din0),  .din1 (ram_din1),  .din2 (ram_din2),  .din3 (ram_din3),
    .din4  (ram_din4),  .din5 (ram_din5),  .din6 (ram_din6),  .din7 (ram_din7),
    .din8  (ram_din8),  .din9 (ram_din9),  .din10(ram_din10),.din11(ram_din11),
    .din12 (ram_din12), .din13(ram_din13), .din14(ram_din14), .din15(ram_din15),
    .dout0  (ram_dout0),  .dout1  (ram_dout1),
    .dout2  (ram_dout2),  .dout3  (ram_dout3),
    .dout4  (ram_dout4),  .dout5  (ram_dout5),
    .dout6  (ram_dout6),  .dout7  (ram_dout7),
    .dout8  (ram_dout8),  .dout9  (ram_dout9),
    .dout10 (ram_dout10), .dout11 (ram_dout11),
    .dout12 (ram_dout12), .dout13 (ram_dout13),
    .dout14 (ram_dout14), .dout15 (ram_dout15)
  );

  // 4) bit-reverse reads RAM
  bitrev #(.DATA_WIDTH(DATA_WIDTH), .N(N)) br_u (
    .din0(ram_dout0),  .din1(ram_dout1),  .din2(ram_dout2),  .din3(ram_dout3),
    .din4(ram_dout4),  .din5(ram_dout5),  .din6(ram_dout6),  .din7(ram_dout7),
    .din8(ram_dout8),  .din9(ram_dout9),  .din10(ram_dout10),.din11(ram_dout11),
    .din12(ram_dout12),.din13(ram_dout13),.din14(ram_dout14),.din15(ram_dout15),
    .dout0(rev0),      .dout1(rev1),      .dout2(rev2),      .dout3(rev3),
    .dout4(rev4),      .dout5(rev5),      .dout6(rev6),      .dout7(rev7),
    .dout8(rev8),      .dout9(rev9),      .dout10(rev10),    .dout11(rev11),
    .dout12(rev12),    .dout13(rev13),    .dout14(rev14),    .dout15(rev15)
  );

  // 5) Four stages, *all* reading RAM directly, but with different STAGE params
  ntt_stage #(.STAGE(1), .DATA_WIDTH(DATA_WIDTH), .MODULUS(MODULUS)) s1_u (
    .din0(ram_dout0),  .din1(ram_dout1),  .din2(ram_dout2),  .din3(ram_dout3),
    .din4(ram_dout4),  .din5(ram_dout5),  .din6(ram_dout6),  .din7(ram_dout7),
    .din8(ram_dout8),  .din9(ram_dout9),  .din10(ram_dout10),.din11(ram_dout11),
    .din12(ram_dout12),.din13(ram_dout13),.din14(ram_dout14),.din15(ram_dout15),
    .dout0(s10),       .dout1(s11),       .dout2(s12),       .dout3(s13),
    .dout4(s14),       .dout5(s15),       .dout6(s16),       .dout7(s17),
    .dout8(s18),       .dout9(s19),       .dout10(s110),     .dout11(s111),
    .dout12(s112),     .dout13(s113),     .dout14(s114),     .dout15(s115)
  );

  ntt_stage #(.STAGE(2), .DATA_WIDTH(DATA_WIDTH), .MODULUS(MODULUS)) s2_u (
    .din0(ram_dout0),  .din1(ram_dout1),  .din2(ram_dout2),  .din3(ram_dout3),
    .din4(ram_dout4),  .din5(ram_dout5),  .din6(ram_dout6),  .din7(ram_dout7),
    .din8(ram_dout8),  .din9(ram_dout9),  .din10(ram_dout10),.din11(ram_dout11),
    .din12(ram_dout12),.din13(ram_dout13),.din14(ram_dout14),.din15(ram_dout15),
    .dout0(s20),       .dout1(s21),       .dout2(s22),       .dout3(s23),
    .dout4(s24),       .dout5(s25),       .dout6(s26),       .dout7(s27),
    .dout8(s28),       .dout9(s29),       .dout10(s210),     .dout11(s211),
    .dout12(s212),     .dout13(s213),     .dout14(s214),     .dout15(s215)
  );

  ntt_stage #(.STAGE(3), .DATA_WIDTH(DATA_WIDTH), .MODULUS(MODULUS)) s3_u (
    .din0(ram_dout0),  .din1(ram_dout1),  .din2(ram_dout2),  .din3(ram_dout3),
    .din4(ram_dout4),  .din5(ram_dout5),  .din6(ram_dout6),  .din7(ram_dout7),
    .din8(ram_dout8),  .din9(ram_dout9),  .din10(ram_dout10),.din11(ram_dout11),
    .din12(ram_dout12),.din13(ram_dout13),.din14(ram_dout14),.din15(ram_dout15),
    .dout0(s30),       .dout1(s31),       .dout2(s32),       .dout3(s33),
    .dout4(s34),       .dout5(s35),       .dout6(s36),       .dout7(s37),
    .dout8(s38),       .dout9(s39),       .dout10(s310),     .dout11(s311),
    .dout12(s312),     .dout13(s313),     .dout14(s314),     .dout15(s315)
  );

  ntt_stage #(.STAGE(4), .DATA_WIDTH(DATA_WIDTH), .MODULUS(MODULUS)) s4_u (
    .din0(ram_dout0),  .din1(ram_dout1),  .din2(ram_dout2),  .din3(ram_dout3),
    .din4(ram_dout4),  .din5(ram_dout5),  .din6(ram_dout6),  .din7(ram_dout7),
    .din8(ram_dout8),  .din9(ram_dout9),  .din10(ram_dout10),.din11(ram_dout11),
    .din12(ram_dout12),.din13(ram_dout13),.din14(ram_dout14),.din15(ram_dout15),
    .dout0(s40),       .dout1(s41),       .dout2(s42),       .dout3(s43),
    .dout4(s44),       .dout5(s45),       .dout6(s46),       .dout7(s47),
    .dout8(s48),       .dout9(s49),       .dout10(s410),     .dout11(s411),
    .dout12(s412),     .dout13(s413),     .dout14(s414),     .dout15(s415)
  );

  
  assign dout0  = ram_dout0;   assign dout1  = ram_dout1;
  assign dout2  = ram_dout2;   assign dout3  = ram_dout3;
  assign dout4  = ram_dout4;   assign dout5  = ram_dout5;
  assign dout6  = ram_dout6;   assign dout7  = ram_dout7;
  assign dout8  = ram_dout8;   assign dout9  = ram_dout9;
  assign dout10 = ram_dout10;  assign dout11 = ram_dout11;
  assign dout12 = ram_dout12;  assign dout13 = ram_dout13;
  assign dout14 = ram_dout14;  assign dout15 = ram_dout15;

  
  assign done = (state == DONE_ST);

endmodule
