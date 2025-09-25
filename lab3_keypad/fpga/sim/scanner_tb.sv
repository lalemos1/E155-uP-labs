// Lucas Lemos - llemos@hmc.edu - 9/22/2025
// Tests the scanner module that it properly scans the keypad, debounces any inputs, and outputs the keypad value

module scanner_tb; 
	// DUT logic
	logic       clk, reset;	// input to DUT
	logic [3:0] R; 			// input to DUT
	
	logic [3:0] C; 			// output from DUT
	logic [3:0] R_out;		// output from DUT
	logic       error_led;	// output from DUT
	
	// Instantiate device under test
	scanner DUT (
		.clk        ( clk ),            // input
		.reset      ( reset ),          // input
		.R			( R ),				// input [3:0]
		
		.C  		( C ),  		// output [3:0] 
		.R_out		( R_out ),		// output [3:0]
		.error_led	( error_led )	// output
	);	
	
	
	// Generate test clock
	always
		begin
			clk=1; #5; clk=0; #5;
		end
	
	// Begin test by pulsing reset and enabling DUT
	initial
		begin
		R = 4'b0000;
		reset = 0; #12; reset = 1;
		#60; R = 4'b0100; //#2400100; R = 4'b0000; #60;
		end
	
endmodule