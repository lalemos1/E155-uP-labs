// Lucas Lemos - llemos@hmc.edu - 9/8/2025
// Implements a counter up to 25-bits. Since counter[24] is output, this gives a divided clock of 0.715 Hz. 
// Increasing "step_size" multiplies clk_div.

module clk_divider #(parameter step_size = 1)
				(input  logic                 reset,
				 input  logic                 clk,
				 input  logic [step_size-1:0] step,
				 
				 output logic                 clk_div
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