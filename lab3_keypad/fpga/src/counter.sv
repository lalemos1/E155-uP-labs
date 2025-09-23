// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// This module implements a moore machine clock counter

module counter #(
				parameter SIZE = 7'd32, 
				parameter WIDTH = 1'b1,
				parameter MAXVAL = 26'd24000000 // HSOSC frequency
				) (
				input  logic             clk, reset, en,
				input  logic [SIZE-1:0]  cnt_goal,       // value to count to before setting "tick" high (sets duty cycle of 24MHz clock)
				input  logic [WIDTH-1:0] in,             // input necessary to iterate counter
				input  logic [WIDTH-1:0] criterion,      // the value the input must meet
	
				output logic             tick            // the "on" period of the counter
	);
	
	logic [SIZE-1:0] count;
	
	always_ff @(posedge clk) begin
		if ( ~reset ) count <= 0; // synchronous reset, active low
		else if ( en ) begin                                // counter must be enabled to count
			if ( in == criterion ) count <= count + 1;
			else                   count <= 0;         // if criterion fails to be met, RESET the counter
		end
		else count <= 0; // if ~en, reset the counter (IDK IF THIS IS THE BEST WAY TO IMPLEMENT THIS)
	end
	
	// output
	assign tick = ( count < MAXVAL ) ? ( count > cnt_goal ) : 0;
	//assign tick = count > cnt_goal; // this might not be behaving like i'd expect for a clock divider, but I think this might actually work for the debouncer...
	// to make periodic, I think i'd make the counter reset after some max value maybe?
	
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
	