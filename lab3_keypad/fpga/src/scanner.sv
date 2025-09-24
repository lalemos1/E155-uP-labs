// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// This module scans the keypad for inputs one column at a time and debounces valid inputs

module scanner(
				input logic        reset, clk,
				input logic  [3:0] R,
				
				output logic [3:0] C,
				output logic [3:0] R_out,
				output logic       error_led, // FOR DEBUGGING; MAY REMOVE
			  );
	
	// debouncer logic
	logic        db_en; // input
	logic [3:0]  db_criterion; // input
	logic [3:0]  db_fail_criterion; // input
	logic [31:0] db_period; // input
	logic        db_steady; // output
	logic        db_error;  // output
	
	// scanner_fsm logic
	//logic       clk, reset;  		// input
	//logic [3:0] R; 				// input
	//logic       db_steady; 			// input
	//logic       db_error; 			// input
	//logic [3:0] R_out; 				// output
	//logic       col_en; 			// output
	logic       scanner_error_led;	// output
	//logic       db_en; 				// output
	//logic [3:0] db_criterion; 		// output
	//logic [3:0] db_fail_criterion; 	// output
	
	// col_fsm logic
	logic       col_en;			// input
	//logic [3:0] C; 				// output
	logic       col_error_led;	// output
	
	// Instantiate debouncer
	debouncer #( .WIDTH(3'd4) ) db(
		.clk             ( clk ), 
		.reset           ( reset ),             // input
		.en              ( db_en ),             // input
		.in              ( R ),                 // input
		.criterion       ( db_criterion ),      // input
		.fail_criterion    ( db_fail_criterion ), // input
		.debounce_period ( db_period ),         // input [31:0]
				
		.steady ( db_steady ),             // output 
		.error  ( db_error )               // output
	);
	
	// Instantiate scanner FSM
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
	
	// Instantiate column scanner FSM
	col_fsm col_fsm(
		.clk             	( clk ),            // input
		.reset           	( reset ),          // input
		.en					( col_en ),				// input
		
		.C  				( C ),  			// output [3:0] 
		.col_error_led 		( col_error_led )	// output
	);	
	
	assign db_period = 240000; // target: 10 ms (24MHz / 240000 = 100 Hz)
	assign error_led = (col_error_led or scanner_error_led);
endmodule
/*
// state logic
		typedef enum logic [2:0] {S0_C, S1_T, S2_R, S3_S, S4_D, S5_G, S6_V}
	statetype;
		statetype state, nextstate;
		
	// state register
	always_ff @(posedge clk, posedge reset)
		if (reset) state <= S0_C;
		else		  state <= nextstate;
		
	// next state logic
	always_comb begin
		case (state)
			default: 						nextstate = S0_C;
			S0_C:		if (E) 		  		nextstate = S1_T;
						else          		nextstate = state; // loop to self
			
			S1_T: 	if (S)	     		nextstate = S2_R;
						else if (W)   		nextstate = S0_C;
						else          		nextstate = state; // loop to self
			
			S2_R: 	if (N)		  		nextstate = S1_T;
						else if (E)   		nextstate = S4_D;
						else if (W)   		nextstate = S3_S;
						else          		nextstate = state; // loop to self
			
			S3_S: 	if (E) 		  		nextstate = S2_R;
						else          		nextstate = state; // loop to self
			
			S4_D: 	if (~sword)		   nextstate = S5_G;
						else if (E&sword) nextstate = S6_V;
						else if (W&sword) nextstate = S2_R; // edge case of going to the river after killing dragon, might remove
						else              nextstate = state;
			
			S5_G: 	                  nextstate = state; // might have to make automatically reset after 1 CLK to prevent josaphat's bug
			S6_V: 							nextstate = state; // same here
		endcase
	end
	
	// output logic
	assign WIN = (state == S6_V);
	assign DIE = (state == S5_G);
	assign room = (state == S3_S);
	*/