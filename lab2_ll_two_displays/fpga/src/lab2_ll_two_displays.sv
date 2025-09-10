// Lucas Lemos - llemos@hmc.edu - 9/6/2025
// This top level module implements three major functions: 1) generate an 80 Hz clock signal,
// 2) time multiplex two seven segment displays, and 3) sum the values of these two displays

module lab2_ll_two_displays(
							input   logic [3:0] switch1, switch2,
							input   logic       reset_p34,         // P34 is connected to a pushbutton on the dev board
				
							output  logic       clk_div_p2,
							output  logic [4:0] led_cnt,
							output  logic [6:0] seg
							);
				
	logic [3:0]  switch1or2; // output of the mux
	logic        clk; // HSOSC to clk_divider
	logic        clk_div; // Divided clk from counter ~= 80Hz
	logic [31:0] divisor; // 48MHz / (2*divisor) = clk_div frequency
	
	// Generate clk by instantiating high speed oscillator module from iCE40 library
	HSOSC #(.CLKHF_DIV(2'b01)) hf_osc(  // dividing HSOSC clock by 1
		.CLKHFPU(1'b1), // input
		.CLKHFEN(1'b1), // input
		.CLKHF(clk)     // output
	);
	
	// Instantiate clock divider module
	clk_divider clk_divider(
		.clk        ( clk ),        // input
		.reset      ( reset_p34 ),  // input
		.divisor    ( divisor ),    // input [31:0]
		.clk_div    ( clk_div )     // output
	);
	
	// Instantiate 7-segment display decoder module
	seven_seg_display seven_seg_display(
		.s   ( switch1or2 ),  // input [3:0]
		.seg ( seg )          // output [6:0]
	);
	
	// LED count adder
	assign led_cnt = switch1 + switch2;
	
	// Mux for switch input to seven-seg decoder. Switches at the frequency of clk_div
	assign switch1or2 = clk_div ? switch1 : switch2; 
	
	// Set clk divisor to target clk_div @ 80 Hz
	assign divisor = 32'd300000  // divisor = 48,000,000 Hz / 2 (b/c posedge) / 80 Hz = 300,000
	
	// Assign clk_div output a name according to the output pin
	assign clk_div_p2 = clk_div;
endmodule