`timescale 1ns/1ps

module prng_16bit_tb;

reg clk;
reg rst;
reg en;
reg start;
reg loadseed;
reg [3:0]seed;

wire done;
wire [15:0] prng_gen;

prng_16bit uut(.clk(clk) , .rst(rst) , .en(en) ,.start(start),.loadseed(loadseed),.seed(seed),.done(done),.prng_gen(prng_gen));

always #5 clk=~clk ;

initial begin
clk = 0;
rst = 1;
en = 0 ;
start = 0 ;
loadseed = 0;
seed = 4'b0001;

#20
rst = 0 ;

//loading a custom seed 
loadseed = 1; 
seed = $random % 16;
#10; 
loadseed = 0;

//start the prng 
en = 1;
start = 1 ;


//waiting enough time for 4 cycles of output ( 40ns )
#60
$display("Random seed chosen = %b (%0d)", seed, seed);
$display("PRNG OUTPUT: %b",prng_gen);

$finish;
end

endmodule