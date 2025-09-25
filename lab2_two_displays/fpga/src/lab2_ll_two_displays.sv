// Lucas Lemos - llemos@hmc.edu - 9/6/2025
// This top level module implements three major functions: 1) generate an 80 Hz clock signal,
// 2) time multiplex two seven segment displays, and 3) sum the values of these two displays

module lab2_ll_two_displays(
							input   logic [3:0] switch1, switch2,
							input   logic       reset_p34,         // P34 is connected to a pushbutton on the dev board
				
							output  logic       clk_div_p44, not_clk_div_p9,
							output  logic [4:0] led_cnt,
							output  logic [6:0] seg
							);
				
	logic [3:0]  switch1or2; // output of the mux
	logic        clk; // HSOSC to clk_divider
	logic [31:0] divisor; // 48MHz / (2*divisor) = clk_div_p44 frequency
	
	// Generate clk by instantiating high speed oscillator module from iCE40 library
	HSOSC #(.CLKHF_DIV( 2'b01 )) hf_osc(  // dividing HSOSC clock by 1
		.CLKHFPU ( 1'b1 ), // input
		.CLKHFEN ( 1'b1 ), // input
		.CLKHF   ( clk )     // output
	);
	
	// Set clk divisor to target clk_div_p44 @ 80 Hz
	assign divisor = 32'd150000;  // divisor = 48,000,000 Hz / 2 (b/c posedge) / 80 Hz = 300,000
	
	// Create inverse clock for time multiplexing
	assign not_clk_div_p9 = ~clk_div_p44;
	
	// Instantiate clock divider module
	clk_divider clk_divider(
		.clk     ( clk ),        // input
		.reset   ( reset_p34 ),  // input
		.divisor ( divisor ),    // input [31:0]
		.clk_div ( clk_div_p44 )  // output
	);
	
	// Instantiate 7-segment display decoder module
	seven_seg_display seven_seg_display(
		.s   ( switch1or2 ),  // input [3:0]
		.seg ( seg )          // output [6:0]
	);
	
	// Instantiate LED count adder
	adder4 led_cnt_adder(  // implements: assign led_cnt = switch1 + switch2;
		.a   ( switch1 ),  // input [3:0]
		.b   ( switch2 ),  // input [3:0]
		.sum ( led_cnt )   // output [4:0]
	);
	
	// Insantiate mux for switch input to seven-seg decoder. Switches at the frequency of clk_div_p44
	mux2 #(.WIDTH( 3'd4 )) switch_mux(   //implements: assign switch1or2 = clk_div_p44 ? switch1 : switch2;
		.d0 ( switch1 ),     // input [3:0]
		.d1 ( switch2 ),     // input [3:0]
		.s  ( clk_div_p44 ), // input
		.y  ( switch1or2 )  // output [3:0]
	);
	
endmodule