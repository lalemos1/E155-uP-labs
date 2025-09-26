// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// This module implements the moore machine scanner FSM

module scanner_fsm(
				input logic        	reset, clk,
				input logic  [3:0] 	R,
				input  logic       	db_steady,
				input  logic       	db_error,
				
				output logic [3:0] 	R_out,
				output logic       	col_en, // enable signal for columns fsm
				output logic	   	on_led,
				output logic       	read_error_led, // FOR DEBUGGING; MAY REMOVE
				output logic		db_lo_error_led, // output
				output logic		db_hi_error_led, // output
				output logic		dbing_led,		// output
				//output logic	   	db_error_led,
				output logic       	db_en,
				output logic [3:0] 	db_criterion,
				output logic [3:0] 	db_fail_criterion
			  );
	
	// Internal logic
	logic 		sync_en;
	logic 		synced;
	logic [3:0]	R_db;
	
	// Instantiate counter module to delay reading for synchronizer
	counter #( 
		.DEPTH   ( 3'd4 ),      // counter bit depth
		.WIDTH  ( 1'b1 ),       // bus width of in & criterion
		.MAXCNT ( 4'd10 ) 		
	) sync_counter (
		.clk       ( clk ),  	// input
		.reset     ( reset ),   // input
		.en        ( sync_en ), // input
		.cnt_goal  ( 4'd10 ), 	// input [31:0]
		.in        ( 1'b1 ),    // input
		.criterion ( 1'b1 ),    // input
		
		.tick      ( synced )   // output
	);
	
	// state logic
	typedef enum logic [4:0] 
		{RESET, SCAN_COL, SYNC_BUFFER, READ, DEBOUNCE_HIGH, ON, DEBOUNCE_LOW, READ_ERROR, DB_LO_ERROR, DB_HI_ERROR, STATE_ERROR} 
		statetype;
	statetype state, next_state;
	
	// state register
	always_ff @(posedge clk) begin
		if ( ~reset ) state <= RESET; // synchronous reset, active low
		else 		  state <= next_state;
	end
	
	// next state logic
	always_comb begin
		case ( state )
			RESET:          						next_state = SCAN_COL;
			SCAN_COL:	   							next_state = SYNC_BUFFER;
			SYNC_BUFFER:   begin
							if		( synced )		next_state = READ;
							else					next_state = SYNC_BUFFER;
						   end
			READ:          begin
							case ( R ) 
								4'b0000: 		  	next_state = SCAN_COL;
								4'b0001: 		  	next_state = DEBOUNCE_HIGH;
								4'b0010: 		  	next_state = DEBOUNCE_HIGH;
								4'b0100: 		  	next_state = DEBOUNCE_HIGH;
								4'b1000: 		  	next_state = DEBOUNCE_HIGH;
								default: 		  	next_state = READ_ERROR;  // for simulaneous inputs
							endcase
						   end
			DEBOUNCE_HIGH: begin
							if      ( db_steady ) 	next_state = ON;
							else if ( db_error )  	next_state = DB_HI_ERROR; // CHANGED THIS FROM ERROR. MAYBE TO SCAN_COL?
							else                  	next_state = DEBOUNCE_HIGH; // loop
						   end
			ON:      	   begin
							if ( R == 4'b0000 )	  	next_state = DEBOUNCE_LOW;
							else 				  	next_state = ON;
						   end
			DEBOUNCE_LOW:  begin
							if 		( db_steady ) 	next_state = SCAN_COL;
							else if ( db_error )  	next_state = DB_LO_ERROR; // CHANGED THIS FROM ERROR
							else				  	next_state = DEBOUNCE_LOW; // loop
						   end
			READ_ERROR:      						next_state = SCAN_COL; // bad input, go back to scanning
			DB_HI_ERROR:							next_state = SCAN_COL; // failed to debounce, go back to scanning
			DB_LO_ERROR:							next_state = SCAN_COL; // failed to debounce, go back to scanning
			STATE_ERROR:							next_state = SCAN_COL;
			default:  							  	next_state = STATE_ERROR;
		endcase
	end
	
	//// output logic ////
	// Update R_on only from the R value which was debounced
	always_ff @( posedge clk ) begin
		if		( state == RESET )			R_db <= 4'b0000;
		else if ( state == DEBOUNCE_HIGH ) 	R_db <= R;
		else								R_db <= R_db;
	end
	assign R_out			= ( state == ON ) ? R_db : 4'b0000;
	assign col_en			= ( state == SCAN_COL );
	assign on_led 			= ( state == ON );
	//assign read_error_led	= ( state == READ_ERROR );
	assign dbing_led		= db_en;
	//assign db_hi_error_led	= ( state == DB_HI_ERROR );
	//assign db_lo_error_led	= ( state == DB_LO_ERROR );
	//assign db_error_led 	= ( state == DB_ERROR );
	assign db_en			= ( state == DEBOUNCE_HIGH || state == DEBOUNCE_LOW );
	assign db_fail_criterion = ( state == DEBOUNCE_LOW ) ? 4'b0001 : 4'b0000; // idk how to properly implement db_fail_criterion = ~4'b0000 (4'b0001 for now -- MAY CAUSE A BUG)
	assign sync_en 			= ( state == SYNC_BUFFER );
	
	// Update db_criterion only during READ or DEBOUNCE_LOW
	always_ff @( posedge clk ) begin
		if		( state == RESET )			db_criterion <= 4'b0000;
		else if ( state == READ ) 			db_criterion <= R; 		// I should move this to the output logic section
		else if ( state == DEBOUNCE_LOW ) 	db_criterion <= 4'b0000;
		else								db_criterion <= db_criterion;
	end
	
	// Debugging: update error LEDs if they catch an error even once
	always_ff @( posedge clk ) begin
		if 		( state == RESET ) 			db_hi_error_led <= 0;
		else if ( state == DB_HI_ERROR )	db_hi_error_led <= 1;
		else								db_hi_error_led <= db_hi_error_led;
			
		if 		( state == RESET ) 			db_lo_error_led <= 0;
		else if ( state == DB_LO_ERROR )	db_lo_error_led <= 1;
		else								db_lo_error_led <= db_lo_error_led;
		
		if 		( state == RESET ) 			read_error_led <= 0;
		else if ( state == DB_LO_ERROR )	read_error_led <= 1;
		else								read_error_led <= read_error_led;
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