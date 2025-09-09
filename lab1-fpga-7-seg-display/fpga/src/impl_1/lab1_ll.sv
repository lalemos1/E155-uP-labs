// Lucas Lemos - llemos@hmc.edu - 9/2/2025
// Decodes 7 segment display and 3 LEDs, including one blinking LED at ~2.8 Hz


module lab1_ll( input   logic [3:0] s,
				input   logic reset_p34,
				
				output  logic led0_p42,
				output  logic led1_p38,
				output  logic led2_p28,
				output  logic [6:0] seg);
				
	// Instantiate 7-segment display decoder submodule
	seven_seg_display seven_seg_display(s, seg);
	
	// Blinking LED variables
	logic clk;
	logic [24:0] counter;
	logic [2:0] step;
	assign step = 3'b100; // multiplying clock by 4
   
	// Internal high-speed oscillator
	HSOSC #(.CLKHF_DIV(2'b01)) // dividing clock by 1
		 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

	// Counter
	always_ff @(posedge clk) begin
	 if(reset_p34 == 0)  counter <= 0;
	 else            counter <= counter + step;
	end

	// Assign LED outputs
	assign led0_p42 = counter[24];
	assign led1_p38 = s[0] ^ s[1];
	assign led2_p28 = s[2] && s[3];
			
endmodule



/*
module top(
     input   logic reset,
	 output  logic led0_p42,
     output  logic led1_p38,
	 output  logic led2_p28
);

   logic clk;
   logic [24:0] counter;
  
   // Internal high-speed oscillator
   HSOSC #(.CLKHF_DIV(2'b01)) 
         hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));
  
   // Counter
   always_ff @(posedge clk) begin
     if(reset == 0)  counter <= 0;
     else            counter <= counter + 1;
   end
  
   // Assign LED output
   assign led = counter[24];
  
endmodule
*/