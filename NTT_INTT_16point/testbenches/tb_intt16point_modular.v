`timescale 1ns / 1ps


module tb_intt16point_modular;
  reg         clk, rst;
  reg  [15:0] in0,  in1,  in2,  in3;
  reg  [15:0] in4,  in5,  in6,  in7;
  reg  [15:0] in8,  in9,  in10, in11;
  reg  [15:0] in12, in13, in14, in15;
  wire [15:0] out0,  out1,  out2,  out3;
  wire [15:0] out4,  out5,  out6,  out7;
  wire [15:0] out8,  out9,  out10, out11;
  wire [15:0] out12, out13, out14, out15;
  integer     i;

  
  intt16point_modular dut (
    .clk   (clk),  .rst   (rst),
    .in0   (in0),  .in1   (in1),  .in2  (in2),  .in3  (in3),
    .in4   (in4),  .in5   (in5),  .in6  (in6),  .in7  (in7),
    .in8   (in8),  .in9   (in9),  .in10 (in10), .in11 (in11),
    .in12  (in12), .in13  (in13), .in14 (in14), .in15 (in15),
    .out0  (out0), .out1  (out1), .out2 (out2), .out3 (out3),
    .out4  (out4), .out5  (out5), .out6 (out6), .out7 (out7),
    .out8  (out8), .out9  (out9), .out10(out10),.out11(out11),
    .out12 (out12),.out13 (out13),.out14(out14),.out15(out15)
  );

  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    // -- Test vector: a = 	[15, 2, 16, 10, 7, 5, 6, 16, 10, 4, 0, 5, 8, 11, 2, 8]
    //    Its unscaled NTT(a) (root=3 mod17) is:
    //    [6,9,8,8,16,8,15,15,3,9,16,2,16,10,1,13]
    {in0, in1,  in2, in3,
     in4, in5,  in6, in7,
     in8, in9,  in10,in11,
     in12,in13, in14,in15}
      = {16'd6, 16'd9,  16'd8,  16'd8,
         16'd16,16'd8,  16'd15, 16'd15,
         16'd3, 16'd9,  16'd16, 16'd2,
         16'd16,16'd10, 16'd1,  16'd13};
    
    
    rst = 1;
    #10;
    
    rst = 0;
    #20;    
    
    
    $display("\nRecovered time-domain:");
    for (i = 0; i < 16; i = i + 1) begin
      $display("[%0d] = %0d", i,
        (i==0) ? out0  :
        (i==1) ? out1  :
        (i==2) ? out2  :
        (i==3) ? out3  :
        (i==4) ? out4  :
        (i==5) ? out5  :
        (i==6) ? out6  :
        (i==7) ? out7  :
        (i==8) ? out8  :
        (i==9) ? out9  :
        (i==10)? out10 :
        (i==11)? out11 :
        (i==12)? out12 :
        (i==13)? out13 :
        (i==14)? out14 : out15
      );
    end

    
    if ({out0,out1, out2,out3,
         out4,out5, out6,out7,
         out8,out9,out10,out11,
         out12,out13,out14,out15}
        == {16'd15,16'd2, 16'd16, 16'd10,
            16'd7, 16'd5, 16'd6,  16'd16,
            16'd10,16'd4,16'd0, 16'd5,
            16'd8, 16'd11,16'd2,16'd8})
      $display(">>> PASS: recovered original vector! <<<");
    else
      $display(">>> FAIL: output does not match original. <<<");

    $finish;
  end

endmodule
