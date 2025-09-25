// Lucas Lemos - llemos@hmc.edu - 9/22/2025
// Tests the scanner_fsm module that it properly cycles through each of the scanning states

module scanner_fsm_tb; 
	// DUT logic
	logic       clk, reset;  		// input to DUT
	logic [3:0] R; 					// input to DUT
	logic       db_steady; 			// input to DUT
	logic       db_error; 			// input to DUT
	
	logic [3:0] R_out; 				// output from DUT
	logic       col_en; 			// output from DUT
	logic       scanner_error_led;	// output from DUT
	logic       db_en; 				// output from DUT
	logic [3:0] db_criterion; 		// output from DUT
	logic [3:0] db_fail_criterion; 	// output from DUT
	
	// Instantiate device under test
	scanner_fsm DUT (
		.clk             	( clk ),             	// input
		.reset           	( reset ),           	// input
		.R					( R ),					// input [3:0]
		.db_steady     		( db_steady ),          // input
		.db_error       	( db_error ),       	// input
		
		.R_out  			( R_out ),  			// output [3:0] 
		.col_en 			( col_en ), 			// output
		.scanner_error_led  ( scanner_error_led ),          // output
		.db_en           	( db_en ),            	// output
		.db_criterion		( db_criterion ),      	// output [3:0]
		.db_fail_criterion 	( db_fail_criterion )	// output [3:0]
	);
	
	assign R = 4'b0001;
	assign db_steady = 0;
	assign db_error = 0;
	
	// Generate test clock
	always
		begin
			clk=1; #5; clk=0; #5;
		end
	
	// Begin test by pulsing reset
	initial
		begin
		reset = 0; #12; reset = 1;
		end
	
endmodule