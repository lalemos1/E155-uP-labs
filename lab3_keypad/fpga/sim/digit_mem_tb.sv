// Lucas Lemos - llemos@hmc.edu - 9/24/2025
// Tests the digit_mem module that it properly updates the output digits only upon receiving a new k value from the keypad

module digit_mem_tb; 
	// DUT logic
	logic       clk, reset;	// input to DUT
	logic [4:0] k;			// input to DUT
	
	logic [3:0] dig0;		// output from DUT
	logic [3:0] dig1;		// output from DUT

	
	// Instantiate device under test
	digit_mem DUT (
		.clk    ( clk ),    // input
		.reset  ( reset ),  // input
		.k		( k ),		// input [4:0]
	
		.dig0  	( dig0 ),  	// output [3:0] 
		.dig1 	( dig1 )	// output [3:0] 
	);	
	
	// Generate test clock
	always
		begin
			clk=1; #5; clk=0; #5;
		end
	
	// Begin test by pulsing reset
	initial
		begin
		reset = 0; #12; reset = 1;
		k = 5'b10000;
		end
	
endmodule