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
	counter #( .SIZE(6'd32), .WIDTH(3'd4) ) steady_counter(
		.clk       ( clk ),             // input
		.reset     ( reset ),           // input
		.en        ( en ),              // input
		.cnt_goal  ( debounce_period ), // input [31:0]
		.in        ( in ),              // input {3:0]
		.criterion ( criterion ),       // input [3:0]
		
		.tick      ( steady )           // output
	);
	/*
		flopr #(.WIDTH(3'd4)) flop_a(
		.clk   ( clk ),   // input
		.reset ( reset ), // input
		.d     ( d_a ),   // input [3:0]
		.q     ( d_mid )  // output [3:0]
	);
	*/
	
	
	
endmodule
