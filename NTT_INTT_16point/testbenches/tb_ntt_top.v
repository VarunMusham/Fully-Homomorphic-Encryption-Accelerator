`timescale 1ns / 1ps


module tb_ntt_top;
  localparam integer DATA_WIDTH = 16;
  localparam integer MODULUS    = 17;

  
  reg                       clk;
  reg                       rst;
  reg                       start;
  reg  [DATA_WIDTH-1:0]     din0,  din1,  din2,  din3;
  reg  [DATA_WIDTH-1:0]     din4,  din5,  din6,  din7;
  reg  [DATA_WIDTH-1:0]     din8,  din9,  din10, din11;
  reg  [DATA_WIDTH-1:0]     din12, din13, din14, din15;

  
  wire [DATA_WIDTH-1:0] dout0,  dout1,  dout2,  dout3;
  wire [DATA_WIDTH-1:0] dout4,  dout5,  dout6,  dout7;
  wire [DATA_WIDTH-1:0] dout8,  dout9,  dout10, dout11;
  wire [DATA_WIDTH-1:0] dout12, dout13, dout14, dout15;
  wire                  done;

  
  wire [DATA_WIDTH-1:0] rev0,  rev1,  rev2,  rev3;
  wire [DATA_WIDTH-1:0] rev4,  rev5,  rev6,  rev7;
  wire [DATA_WIDTH-1:0] rev8,  rev9,  rev10, rev11;
  wire [DATA_WIDTH-1:0] rev12, rev13, rev14, rev15;

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

  
  ntt_top #(
    .DATA_WIDTH(DATA_WIDTH),
    .N         (16),
    .MODULUS   (MODULUS),
    .ROOT      (3)
  ) dut (
    .clk    (clk),
    .rst    (rst),
    .start  (start),
    .din0   (din0),   .din1   (din1),   .din2   (din2),   .din3   (din3),
    .din4   (din4),   .din5   (din5),   .din6   (din6),   .din7   (din7),
    .din8   (din8),   .din9   (din9),   .din10  (din10),  .din11  (din11),
    .din12  (din12),  .din13  (din13),  .din14  (din14),  .din15  (din15),
    .dout0  (dout0),  .dout1  (dout1),  .dout2  (dout2),  .dout3  (dout3),
    .dout4  (dout4),  .dout5  (dout5),  .dout6  (dout6),  .dout7  (dout7),
    .dout8  (dout8),  .dout9  (dout9),  .dout10 (dout10), .dout11 (dout11),
    .dout12 (dout12), .dout13 (dout13), .dout14 (dout14), .dout15 (dout15),
    .done   (done)
  );

  
  bitrev #(.DATA_WIDTH(DATA_WIDTH), .N(16)) ref_br (
    .din0(din0), .din1(din1), .din2(din2), .din3(din3),
    .din4(din4), .din5(din5), .din6(din6), .din7(din7),
    .din8(din8), .din9(din9), .din10(din10), .din11(din11),
    .din12(din12), .din13(din13), .din14(din14), .din15(din15),
    .dout0(rev0), .dout1(rev1), .dout2(rev2), .dout3(rev3),
    .dout4(rev4), .dout5(rev5), .dout6(rev6), .dout7(rev7),
    .dout8(rev8), .dout9(rev9), .dout10(rev10), .dout11(rev11),
    .dout12(rev12), .dout13(rev13), .dout14(rev14), .dout15(rev15)
  );

  ntt_stage #(.STAGE(1), .DATA_WIDTH(DATA_WIDTH), .MODULUS(MODULUS)) ref_s1 (
    .din0(rev0),  .din1(rev1),  .din2(rev2),  .din3(rev3),
    .din4(rev4),  .din5(rev5),  .din6(rev6),  .din7(rev7),
    .din8(rev8),  .din9(rev9),  .din10(rev10),.din11(rev11),
    .din12(rev12),.din13(rev13),.din14(rev14),.din15(rev15),
    .dout0(s10),  .dout1(s11),  .dout2(s12),  .dout3(s13),
    .dout4(s14),  .dout5(s15),  .dout6(s16),  .dout7(s17),
    .dout8(s18),  .dout9(s19),  .dout10(s110),.dout11(s111),
    .dout12(s112),.dout13(s113),.dout14(s114),.dout15(s115)
  );

  ntt_stage #(.STAGE(2), .DATA_WIDTH(DATA_WIDTH), .MODULUS(MODULUS)) ref_s2 (
    .din0(s10),  .din1(s11),  .din2(s12),  .din3(s13),
    .din4(s14),  .din5(s15),  .din6(s16),  .din7(s17),
    .din8(s18),  .din9(s19),  .din10(s110),.din11(s111),
    .din12(s112),.din13(s113),.din14(s114),.din15(s115),
    .dout0(s20),  .dout1(s21),  .dout2(s22),  .dout3(s23),
    .dout4(s24),  .dout5(s25),  .dout6(s26),  .dout7(s27),
    .dout8(s28),  .dout9(s29),  .dout10(s210),.dout11(s211),
    .dout12(s212),.dout13(s213),.dout14(s214),.dout15(s215)
  );

  ntt_stage #(.STAGE(3), .DATA_WIDTH(DATA_WIDTH), .MODULUS(MODULUS)) ref_s3 (
    .din0(s20),  .din1(s21),  .din2(s22),  .din3(s23),
    .din4(s24),  .din5(s25),  .din6(s26),  .din7(s27),
    .din8(s28),  .din9(s29),  .din10(s210),.din11(s211),
    .din12(s212),.din13(s213),.din14(s214),.din15(s215),
    .dout0(s30),  .dout1(s31),  .dout2(s32),  .dout3(s33),
    .dout4(s34),  .dout5(s35),  .dout6(s36),  .dout7(s37),
    .dout8(s38),  .dout9(s39),  .dout10(s310),.dout11(s311),
    .dout12(s312),.dout13(s313),.dout14(s314),.dout15(s315)
  );

  ntt_stage #(.STAGE(4), .DATA_WIDTH(DATA_WIDTH), .MODULUS(MODULUS)) ref_s4 (
    .din0(s30),  .din1(s31),  .din2(s32),  .din3(s33),
    .din4(s34),  .din5(s35),  .din6(s36),  .din7(s37),
    .din8(s38),  .din9(s39),  .din10(s310),.din11(s311),
    .din12(s312),.din13(s313),.din14(s314),.din15(s315),
    .dout0(s40),  .dout1(s41),  .dout2(s42),  .dout3(s43),
    .dout4(s44),  .dout5(s45),  .dout6(s46),  .dout7(s47),
    .dout8(s48),  .dout9(s49),  .dout10(s410),.dout11(s411),
    .dout12(s412),.dout13(s413),.dout14(s414),.dout15(s415)
  );

  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  integer i, errors;
  reg [DATA_WIDTH-1:0] DUTv [0:15];
  reg [DATA_WIDTH-1:0] REFv [0:15];

  initial begin
    
    { din0, din1, din2, din3,
      din4, din5, din6, din7,
      din8, din9, din10, din11,
      din12, din13, din14, din15 }
    = {16'd12,16'd15,16'd2,16'd3,
       16'd4,16'd5,16'd6,16'd7,
       16'd8,16'd9,16'd10,16'd11,
       16'd12,16'd13,16'd14,16'd15};

    
    rst   = 1;
    start = 0;
    #10 rst = 0;
    #10 start = 1;
    #10 start = 0;

    
    wait(done);
    #1;  

    
    DUTv[0]  = dout0;  DUTv[1]  = dout1;  DUTv[2]  = dout2;  DUTv[3]  = dout3;
    DUTv[4]  = dout4;  DUTv[5]  = dout5;  DUTv[6]  = dout6;  DUTv[7]  = dout7;
    DUTv[8]  = dout8;  DUTv[9]  = dout9;  DUTv[10] = dout10; DUTv[11] = dout11;
    DUTv[12] = dout12; DUTv[13] = dout13; DUTv[14] = dout14; DUTv[15] = dout15;

    
    REFv[0]  = s40;  REFv[1]  = s41;  REFv[2]  = s42;  REFv[3]  = s43;
    REFv[4]  = s44;  REFv[5]  = s45;  REFv[6]  = s46;  REFv[7]  = s47;
    REFv[8]  = s48;  REFv[9]  = s49;  REFv[10] = s410; REFv[11] = s411;
    REFv[12] = s412; REFv[13] = s413; REFv[14] = s414; REFv[15] = s415;

    
    $display("\n*** Checking ntt_top outputs against reference chain ***\n");
    errors = 0;
    for (i = 0; i < 16; i = i + 1) begin
      if (DUTv[i] !== REFv[i]) begin
        $display(" FAIL: index %0d: DUT=%0d, REF=%0d", i, DUTv[i], REFv[i]);
        errors = errors + 1;
      end else begin
        $display(" PASS: index %0d: %0d", i, DUTv[i]);
      end
    end

    if (errors == 0)
      $display("\n>>> PASS: ntt_top matches reference NTT! <<<\n");
    else
      $display("\n>>> FAIL: %0d mismatches in ntt_top <<<\n", errors);

    #5 $finish;
  end
endmodule
