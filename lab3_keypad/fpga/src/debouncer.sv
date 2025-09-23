// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// This module debounces either an active HIGH or active LOW input

module debouncer #(parameter WIDTH = 4) (
				input  logic             clk, reset, en,
				input  logic [WIDTH-1:0] criterion, // REPLACED HI_OR_LO SO I COULD TARGET 4 BIT R VALUES INSTEAD
				input  logic [WIDTH-1:0] in,
				input  logic [31:0]      debounce_period,
				
				output logic             steady, 
				output logic             error
	);
	
	logic [31:0] steady_cnt;
	logic [31:0] error_cnt;
	logic [31:0] clk_divisor;
	
	
	// Instantiate counter module -- I'LL PROBS NEED TO INSTANTIATE A SECOND COUNTER FOR ERROR
	counter #( 
		.SIZE   ( 7'd32 ),       // counter bus size
		.WIDTH  ( 3'd4 ),        // bus width of signals
		.MAXVAL ( 27'd24000000 ) // frequency of HSOSC
	) steady_counter (
		.clk       ( clk ),             // input
		.reset     ( reset ),           // input
		.en        ( en ),              // input
		.cnt_goal  ( debounce_period ), // input [31:0]
		.in        ( in ),              // input {3:0]
		.criterion ( criterion ),       // input [3:0]
		
		.tick      ( steady )           // output
	
	
	
endmodule
