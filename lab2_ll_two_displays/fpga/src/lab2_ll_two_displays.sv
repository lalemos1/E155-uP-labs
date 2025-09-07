// Lucas Lemos - llemos@hmc.edu - 9/6/2025
// This top level module implements three major functions: to generate an 80 Hz clock signal,
// to time multiplex two seven segment displays, and to sum the values of these two displays

module lab2_ll_two_displays(input   logic [3:0] s1,
							input   logic [3:0] s2,
							input   logic       reset_p34,
				
							output  logic       clk_p,
							output  logic [4:0] led_cnt,
							output  logic [6:0] seg);
				
	logic [3:0] s; // output of the mux
	logic       osc; // HSOSC to counter
	
	// Instantiate 7-segment display decoder submodule
	seven_seg_display seven_seg_display(s, seg);
	
	//led_mux mux(