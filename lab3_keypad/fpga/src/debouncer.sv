// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// This module debounces either an active HIGH or active LOW input

module debouncer #(parameter WIDTH = 3'd4) (
				input  logic             clk, reset, en,
				input  logic [WIDTH-1:0] in,
				input  logic [WIDTH-1:0] criterion,
//				input  logic [WIDTH-1:0] criterion1,
	//			input  logic [WIDTH-1:0] criterion2,
		//		input  logic [WIDTH-1:0] criterion3,
			//	input  logic [WIDTH-1:0] criterion4,
				input  logic [WIDTH-1:0] fail_criterion,  // criterion to throw an error
				input  logic [31:0]      debounce_period,
				
				output logic             steady, 
				output logic             error
	);
	/*
	// steady & error logic
	logic btn_high;
	logic btn_low;
	
	
	always_comb begin
		if (in == criterion1 or in == criterion2 or in == criterion3 or in == criterion4) assign b
		*/
	
	// Instantiate counter module to ensure steady state
	counter #( 
		.SIZE   ( 7'd32 ),       // counter bus size
		.WIDTH  ( WIDTH ),        // bus width of signals
		.MAXVAL ( 27'd24000000 ) // frequency of HSOSC
	) steady_counter (
		.clk       ( clk ),             // input
		.reset     ( reset ),           // input
		.en        ( en ),              // input
		.cnt_goal  ( debounce_period ), // input [31:0]
		.in        ( in ),              // input {3:0]
		.criterion ( criterion ),       // input [3:0]
		
		.tick      ( steady )           // output
	);
	
	// Instantiate error counter if debouncing fails
	counter #( 
		.SIZE   ( 7'd32 ),       // counter bus size
		.WIDTH  ( WIDTH ),        // bus width of signals
		.MAXVAL ( 27'd24000000 ) // frequency of HSOSC
	) error_counter (
		.clk       ( clk ),             // input
		.reset     ( reset ),           // input
		.en        ( en ),              // input
		.cnt_goal  ( debounce_period ), // input [31:0]
		.in        ( in ),              // input {3:0]
		.criterion ( fail_criterion ),  // input [3:0]
		
		.tick      ( error )            // output
	);
	
endmodule
