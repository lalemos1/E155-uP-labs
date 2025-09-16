// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// This module debounces either an active HIGH or active LOW input

module debouncer #(parameter WIDTH = 4) (
				input  logic             clk, reset, en,
				input  logic [WIDTH-1:0] target, // REPLACED HI_OR_LO SO I COULD TARGET 4 BIT R VALUES INSTEAD
				input  logic [WIDTH-1:0] in,
				
				output logic             steady, 
				output logic             error
	);
	
	logic [31:0] steady_cnt;
	logic [31:0] error_cnt;
	logic [31:0] clk_divisor;
	
	assign debounce_period = 240000; // target: 10 ms (24MHz / 240000 = 100 Hz)
	
	
	
	// Instantiate counter module
	counter #( .SIZE(6'd32) ) (
		.clk       ( clk ), 
		.reset     ( reset ),
		.en        ( en ),
		.cnt_goal      ( debounce_period ),
		.criterion ( x )
		.target    ( x )
		.tick      ( x )
		
	);
	/*
		flopr #(.WIDTH(3'd4)) flop_a(
		.clk   ( clk ),   // input
		.reset ( reset ), // input
		.d     ( d_a ),   // input [3:0]
		.q     ( d_mid )  // output [3:0]
	);
	*/
	output            logic tick
	
	
	
endmodule
