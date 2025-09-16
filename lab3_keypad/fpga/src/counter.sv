// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// This module implements a moore machine clock counter

module counter #(parameter SIZE = 32) (
	input             logic clk, reset, en,
	input  [SIZE-1:0] logic cnt_goal,       // value to count to before setting "tick" high (sets duty cycle of 24MHz clock)
	input  [SIZE-1:0] logic criterion,      // criterion necessary to iterate counter
	input  [SIZE-1:0] logic target,         // the value the criterion must meet
	
	output            logic tick            // "on" period of the counter
	);
	
	logic [SIZE-1:0] count;
	
	always_ff @(posedge clk, posedge reset, posedge en) begin
		if ( en ) begin // counter must be enabled to keep counting. count retains value if disabled
			if ( criterion == target ) count <= count + 1;
			else             count <= 0;         // if criterion fails to be met, RESET the counter
		end
		if ( reset ) count <= 0;
		if ( count == cnt_goal ) tick <= 1;
	end
	
	
endmodule

/*
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
*/
	