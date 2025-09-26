// Lucas Lemos - llemos@hmc.edu - 9/6/2025
// This module implements three major functions: 1) generate an 80 Hz clock signal,
// 2) time multiplex two seven segment displays, and 3) sum the values of these two displays

module two_dig_display(
							input   logic [3:0] switch1, switch2,
							input   logic       reset_p34,         // P34 is connected to a pushbutton on the dev board
				
							output  logic       clk_div_p44, not_clk_div_p9,
							//output  logic [4:0] led_cnt,
							output  logic [6:0] seg,
							output	logic		clk
							);
				
	logic [3:0]  switch1or2; // output of the mux
	logic [31:0] divisor; // 48MHz / (2*divisor) = clk_div_p44 frequency
	
	// Generate clk by instantiating high speed oscillator module from iCE40 library
	HSOSC #(.CLKHF_DIV( 2'b01 )) hf_osc(  // dividing HSOSC clock by 1
		.CLKHFPU ( 1'b1 ), // input
		.CLKHFEN ( 1'b1 ), // input
		.CLKHF   ( clk )     // output
	);
	
	// Set clk divisor to target clk_div_p44 @ 80 Hz
	assign divisor = 32'd150000;  // divisor = 24,000,000 Hz / 2 (b/c moore machine) / 80 Hz = 150,000
	
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

// Lucas Lemos - llemos@hmc.edu - 9/8/2025
// Implements a clock divider which can divide an input clock by 2*"divisor"
module clk_divider (
				 input  logic        clk, reset,
				 input  logic [31:0] divisor,
				 output logic        clk_div  // clk_div is necessarily clk/2 since the counter only triggers on posedge
				 );

	logic [31:0] counter; // 32 bit counter of clock ticks (allows for dividing by up to 4.3e9)
	logic [31:0] divisor_shifted;
	
	assign divisor_shifted = divisor ? divisor - 32'd1 : 32'd0; // shifts divisor to align with clock counter & prevents overflow when divisor=0
	always_ff @(posedge clk) begin
		if (reset == 0)  begin   // synchronous reset
			  counter <= 0;
			  clk_div <= 0;
		end
		else if (counter == divisor_shifted) begin
			  clk_div <= ~clk_div;
			  counter <= 0;
	    end
		else  counter <= counter + 1;
	end
endmodule

// Lucas Lemos - llemos@hmc.edu - 9/2/2025
// 7-segment LED display decoder using combinational logic 
module seven_seg_display( input   logic [3:0] s,
					      output  logic [6:0] seg);
					  
	always_comb begin
		case (s)
			4'b0000:	seg = 7'b1000000; // GFEDCBA on 7-seg display
			4'b0001:	seg = 7'b1111001;
			4'b0010:	seg = 7'b0100100;
			4'b0011:	seg = 7'b0110000;
			4'b0100:	seg = 7'b0011001;
			4'b0101:	seg = 7'b0010010;
			4'b0110:	seg = 7'b0000010;
			4'b0111:	seg = 7'b1111000;
			4'b1000:	seg = 7'b0000000;
			4'b1001:	seg = 7'b0010000;
			4'b1010:	seg = 7'b0001000; // A
			4'b1011:	seg = 7'b0000011; // b
			4'b1100:	seg = 7'b1000110; // C
			4'b1101:	seg = 7'b0100001; // d
			4'b1110:	seg = 7'b0000110; // E
			4'b1111:	seg = 7'b0001110; // F
			default:	seg = 7'b1111111; // off
		endcase
	end
endmodule

// Lucas Lemos - llemos@hmc.edu - 9/8/2025
// Implements an adder which accepts two 4-bit inputs and outputs one 5-bit output
module adder4(
		  	  input  logic [3:0] a, b,
			  output logic [4:0] sum
			  );
	
	assign sum = a + b;
endmodule

// Lucas Lemos - llemos@hmc.edu - 9/8/2025
// This module implements a 2 bus input, 1 bus output mux, where the bus size is determined by WIDTH.
// The module is borrowed from the Multicycle processor in E85
module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y
			  );

  assign y = s ? d1 : d0; 
endmodule

