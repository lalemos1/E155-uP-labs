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


/* 
// old, digitally controlled oscillator clk_div
module clk_divider (
				 input  logic  clk, reset,
				 input  logic  multiplier,
				 output logic  clk_div
				 );

	logic [24:0] counter; // 25 bit counter buffer
	
	always_ff @(posedge clk) begin
	 if(reset == 0)  counter <= 0;
	 else            counter <= counter + multiplier;
	end
	
	assign clk_div = counter[24]; // Divides clock to 0.715 Hz (assuming multiplier=1)
	
endmodule
*/

/*
// old, parameterized clk_div
module clk_divider #(parameter step_size = 1) (
				 input  logic clk, reset,
				 output logic clk_div
				 );

	logic [24:0] counter; // 25 bit counter buffer
	logic [step_size-1:0] step;
	
	assign step = step_size;
	
	always_ff @(posedge clk) begin
	 if(reset == 0)  counter <= 0;
	 else            counter <= counter + step;
	end
	
	assign clk_div = counter[24]; // Divides clock to 0.715 Hz (assuming step=1)
	
endmodule
*/