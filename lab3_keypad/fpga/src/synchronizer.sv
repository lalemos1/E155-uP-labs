// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// This module synchronizes an asynchronous input (e.g. a button press) to the system clock. The input
// is a bus of size WIDTH.

// GOOGLE WAS WARNING ME THAT A MULTI-BIT 2FF SYNCHRONIZER MIGHT NOT WORK
// I WON'T INCLUDE THIS IN THE PROJECT UNTIL I GET MVP WORKING. I HAVEN'T DEBUGGED THIS
module synchronizer #(parameter WIDTH = 3'd4) (
				 input  logic             clk, reset,
				 input  logic [WIDTH-1:0] d_a,
				 output logic [WIDTH-1:0]  q
				 );

	logic [WIDTH-1:0] d_b;
	logic [WIDTH-1:0] d_c;
	
	always_ff @( posedge clk ) begin
		if ( ~reset ) 	d_b <= 0;
		else 			d_b <= d_a;
	end
	
	always_ff @( posedge clk ) begin
		if ( ~reset ) 	d_c <= 0;
		else			d_c <= d_b;
	end
	
	always_ff @( posedge clk ) begin
		if ( ~reset )	q <= 0;
		else			q <= d_c;
	end
endmodule


/*
module flopr #(parameter WIDTH = 8)
              (input  logic             clk, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule
*/
/*
mux2 #(.WIDTH( 3'd4 )) switch_mux(   //implements: assign switch1or2 = clk_div_p44 ? switch1 : switch2;
		.d0 ( switch1 ),     // input [3:0]
		.d1 ( switch2 ),     // input [3:0]
		.s  ( clk_div_p44 ), // input
		.y  ( switch1or2 )  // output [3:0]
	);
	*/