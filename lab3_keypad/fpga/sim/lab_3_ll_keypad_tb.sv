// Lucas Lemos - llemos@hmc.edu - 9/24/2025
// Tests the top module lab3_ll_keypad that it properly scans, reads, and displays an input from a keypad

// Questasim requires a timescale directive
`timescale 1 us / 1 us

module lab_3_ll_keypad_tb; 
	//// DUT logic ////
	// Inputs to DUT
	logic [3:0] R_in;
	logic       reset_p34;
	
	// Outputs from DUT
	logic [3:0]	C;
	logic		error_led_pXX;
	logic       clk_div_p44, not_clk_div_p9;
	logic [4:0] led_cnt; // FOR DEBUGGING, WILL REMOVE LATER
	logic [6:0] seg;
	
	// Instantiate device under test
	lab3_ll_keypad DUT (
		.R_in        	( R_in ),           // input [3:0]
		.reset_p34      ( reset_p34 ),      // input
		
		.C  			( C ),  			// output [3:0] 
		.error_led_pXX	( error_led_pXX ),	// output
		.clk_div_p44	( clk_div_p44 ),	// output
		.not_clk_div_p9 ( not_clk_div_p9 ), // output
		.led_cnt		( led_cnt ), 		// output [4:0]
		.seg			( seg ) ); 			// output [6:0]	
	
	/*
	// Generate test clock
	always
		begin
			clk=1; #5; clk=0; #5;
		end
	*/
	// Begin test by pulsing reset and enabling DUT
	initial
		begin
		R_in = 4'b0000;
		reset_p34 = 0; //#1000; reset_p34 = 1;
		//#60; R_in = 4'b0100; //#2400100; R = 4'b0000; #60;
		end
	
endmodule