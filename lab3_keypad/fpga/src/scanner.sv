// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// This module scans the keypad for inputs one column at a time and debounces valid inputs

module scanner(
				input logic        reset, clk,
				input logic  [3:0] R,
				
				output logic [3:0] C,
				output logic [3:0] R_out,
				output logic       error_led // FOR DEBUGGING; MAY REMOVE
			  );
	
	// debouncer logic
	logic        db_en; // input
	logic [3:0]  db_criterion; // input
	logic [3:0]  db_fail_criterion; // input
	logic [31:0] db_period; // input
	logic        db_steady; // output
	logic        db_error;  // output
	
	// scanner_fsm logic
	logic       scanner_error_led;	// output
	
	// col_fsm logic
	logic       col_en;			// input
	logic       col_error_led;	// output
	
	// Instantiate debouncer
	debouncer #( .WIDTH(3'd4) ) db(
		.clk             ( clk ), 
		.reset           ( reset ),             // input
		.en              ( db_en ),             // input
		.in              ( R ),                 // input
		.criterion       ( db_criterion ),      // input
		.fail_criterion  ( db_fail_criterion ), // input
		.debounce_period ( db_period ),         // input [31:0]
				
		.steady ( db_steady ),             // output 
		.error  ( db_error )               // output
	);
	
	// Instantiate scanner FSM
	scanner_fsm scanner_fsm (
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
	
	// Instantiate column scanner FSM
	col_fsm col(
		.clk             	( clk ),            // input
		.reset           	( reset ),          // input
		.en					( col_en ),				// input
		
		.C  				( C ),  			// output [3:0] 
		.col_error_led 		( col_error_led )	// output
	);	
	
	assign db_period = 240000; // target: 10 ms (24MHz / 240000 = 100 Hz)
	assign error_led = (col_error_led || scanner_error_led);
endmodule