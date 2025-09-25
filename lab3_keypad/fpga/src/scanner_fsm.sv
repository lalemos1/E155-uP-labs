// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// This module implements the moore machine scanner FSM

module scanner_fsm(
				input logic        reset, clk,
				input logic  [3:0] R,
				input  logic       db_steady,
				input  logic       db_error,
				
				output logic [3:0] R_out,
				output logic       col_en, // enable signal for columns fsm
				output logic       scanner_error_led, // FOR DEBUGGING; MAY REMOVE
				output logic       db_en,
				output logic [3:0] db_criterion,
				output logic [3:0] db_fail_criterion
			  );
	
	// state logic
	typedef enum logic [3:0] 
		{RESET, SCAN_COL, SYNC_BUFFER, READ, DEBOUNCE_HIGH, ON, DEBOUNCE_LOW, ERROR} 
		statetype;
	statetype state, next_state;
	
	// state register
	always_ff @(posedge clk) begin
		if ( ~reset ) state <= RESET; // synchronous reset, active low
		else 		  state <= next_state;
			
		// Update db_criterion only during READ or DEBOUNCE_LOW
		// I should move this to the output logic section
		if ( state == READ ) 				db_criterion <= R;
		else if ( state == DEBOUNCE_LOW ) 	db_criterion <= 4'b0000;
		else								db_criterion <= db_criterion;
		//db_criterion <= ( state == READ ) ? R : db_criterion;  // UPDATING DB_CRITERION INSTEAD OF OUTPUT LOGIC
	end
	
	// next state logic
	always_comb begin
		case ( state )
			RESET:          						next_state = SCAN_COL;
			SCAN_COL:								next_state = SYNC_BUFFER;	
			SYNC_BUFFER:						  	next_state = READ; // ONLY WAITS ONE TICK -- PROB DOESN'T WAIT LONG ENOUGH FOR SYNCHRONIZER, WHICH WILL CAUSE A BUG IF I ADD IT
			READ:          begin
							case ( R ) 
								4'b0000: 		  	next_state = SCAN_COL;
								4'b0001: 		  	next_state = DEBOUNCE_HIGH;
								4'b0010: 		  	next_state = DEBOUNCE_HIGH;
								4'b0100: 		  	next_state = DEBOUNCE_HIGH;
								4'b1000: 		  	next_state = DEBOUNCE_HIGH;
								default: 		  	next_state = ERROR; // for simulaneous inputs -- MAY CAUSE A BUG
							endcase
						   end
			DEBOUNCE_HIGH: begin
							if      ( db_steady ) 	next_state = ON;
							else if ( db_error )  	next_state = ERROR;
							else                  	next_state = DEBOUNCE_HIGH; // loop
						   end
			ON:      	   begin
							if ( R == 4'b0000 )	  	next_state = DEBOUNCE_LOW;
							else 				  	next_state = ON;
						   end
			DEBOUNCE_LOW:  begin
							if 		( db_steady ) 	next_state = SCAN_COL;
							else if ( db_error )  	next_state = ERROR;
							else				  	next_state = DEBOUNCE_LOW; // loop
						   end
			ERROR:      							next_state = ERROR;
			default:  							  	next_state = ERROR;
		endcase
	end
	
	// output logic
	always_comb begin
		case ( state )
			RESET:      begin  
							R_out			 = 4'b0000;
							col_en 			 = 0;
							scanner_error_led= 0;
							db_en 			 = 0;
							//db_criterion      = 4'b0000; // actually updated in state register
							db_fail_criterion = 4'b0000;
						end
			SCAN_COL:	begin  
							col_en 			 = 1;
							
							R_out			 = 4'b0000;
							scanner_error_led= 0;
							db_en 			 = 0;
							//db_criterion      = 4'b0000; // actually updated in state register
							db_fail_criterion = 4'b0000;
						end	
			SYNC_BUFFER: begin  
							col_en 			 = 0;
							
							R_out			 = 4'b0000;
							scanner_error_led= 0;
							db_en 			 = 0;
							//db_criterion      = 4'b0000; // actually updated in state register
							db_fail_criterion = 4'b0000;
						end
			READ:	begin  
						/* case ( R )  // db_criterion actually updated in state register
							4'b0001:	db_criterion = 4'b0001;
							4'b0010: 	db_criterion = 4'b0010;
							4'b0100: 	db_criterion = 4'b0100;
							4'b1000: 	db_criterion = 4'b1000;
							default: 	db_criterion = 4'b1111; // for simulaneous inputs, intended to cause a debouncer error -- MAY CAUSE A BUG
						endcase */
							R_out			  = 4'b0000;
							col_en 			  = 0;
							scanner_error_led = 0;
							db_en 			  = 0;
							db_fail_criterion = 4'b0000;
						end
			DEBOUNCE_HIGH: begin
							db_en             = 1;  // idk if i want this here or before the state transition to debounce_high
							db_fail_criterion = 4'b0000; // this too <--^^
						  
							R_out			  = 4'b0000; // MIGHT WANNA UPDATE R_OUT HERE INSTEAD OF "ON"
							col_en 			  = 0;
							scanner_error_led = 0;
						end
			ON:      	begin
							db_en = 0;
							R_out = R;
							
							col_en 			  = 0;
							scanner_error_led = 0;
							db_fail_criterion = 4'b0000;
						end
			DEBOUNCE_LOW: begin
							db_en             = 1;
							R_out             = 4'b0000; // idk if i want this here or in "SCAN_COL" (after debouncing)
							db_fail_criterion = 4'b0001; // I can't figure out how to implement this for all R != 4'b0000; MIGHT CAUSE A BUG
							
							col_en 			 = 0;
							scanner_error_led= 0;
						end
			ERROR:	begin  
						scanner_error_led = 1;
						
						R_out			 = 4'b0000;
						col_en 			 = 0;
						db_en 			 = 0;
						db_fail_criterion = 4'b0000;
					end			  
			default: begin  
						scanner_error_led = 1;
						
						R_out			 = 4'b0000;
						col_en 			 = 0;
						db_en 			 = 0;
						db_fail_criterion = 4'b0000;
					end
		endcase
	end
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