module prng_16bit (
input wire clk, //clock input
input wire rst, //reset
input wire en,  //enable
input wire start,
input wire loadseed, //if loadseed=1 -> manual seed , if loadseed=0 -> default seed 4'b1010 
input wire [3:0] seed,
output reg done,
output reg [15:0] prng_gen );

reg [3:0]lfsr ;
reg [2:0] counter ;
wire feedback ;

assign feedback = lfsr[3]^lfsr[0] ;

always @(posedge clk)
begin
if (rst)begin
	lfsr<=4'b1010;   //default seed
	counter<=0;
	prng_gen<=0;
	done <=0;
	end
	else if ( loadseed )begin	//manual seeding
	lfsr<=seed ;  //manual 4bitseed
	counter<=0;
	prng_gen<=0;
	done <=0;
	end
	else if (en&&start&&!done)begin
	lfsr <= {lfsr[2:0],feedback};
	prng_gen<= (prng_gen<<4)| lfsr ;
	counter <= counter + 1 ;
	
	if(counter==3)
		done <=1 ;
	end
end

endmodule