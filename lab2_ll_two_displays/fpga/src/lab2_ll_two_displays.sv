// Lucas Lemos - llemos@hmc.edu - 9/6/2025
// This top level module implements three major functions: to generate an 80 Hz clock signal,
// to time multiplex two seven segment displays, and to sum the values of these two displays

module lab2_ll_two_displays(
							input   logic [3:0] switch1, switch2,
							input   logic       reset_p34,
				
							output  logic       clk_div_p##,
							output  logic [4:0] led_cnt,
							output  logic [6:0] seg
							);
				
	logic [3:0] switch1or2; // output of the mux
	logic       clk; // HSOSC to clk_divider
	logic       clk_div; // Divided clk from counter ~= 80Hz
	
	// Instantiate 7-segment display decoder submodule
	seven_seg_display seven_seg_display(s, seg);
	
	// Instantiate high speed oscillator module from iCE40 library which outputs clk
	HSOSC #(.CLKHF_DIV(2'b01)) // dividing clock by 1
	 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));
		 
	//led_mux mux(
	
	
	// Outputs 
	assign clk_div_p## = clk_div;