// Lucas Lemos - llemos@hmc.edu - 9/22/2025
// Tests the col_fsm module that it properly cycles through each of the column scanning states

module col_fsm_tb; 
	// DUT logic
	logic       clk, reset, en;	// input to DUT
	
	logic [3:0] C; 				// output from DUT
	logic       col_error_led;	// output from DUT
	
	// Instantiate device under test
	col_fsm DUT (
		.clk             	( clk ),            // input
		.reset           	( reset ),          // input
		.en					( en ),				// input
		
		.C  				( C ),  			// output [3:0] 
		.col_error_led 		( col_error_led )	// output
	);	
	
	// Generate test clock
	always
		begin
			clk=1; #5; clk=0; #5;
		end
	
	// Begin test by pulsing reset and enabling DUT
	initial
		begin
		reset = 0; #12; reset = 1; #12; en = 1;
		end
	
endmodule