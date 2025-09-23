// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// This module scans the keypad for inputs one column at a time and debounces valid inputs

module scanner(
				input logic        reset, clk,
				input logic  [3:0] R,
				
				output logic [3:0] C,
				output logic [3:0] R_out,
				output logic       db_error // FOR DEBUGGING; MAY REMOVE
			  );
	
	// state logic
	typedef enum logic [3:0] 
		{RESET, SCAN_COL, SYNC_BUFFER, READ, DEBOUNCE_HIGH, ON, DEBOUNCE_LOW, ERROR} 
		statetype;
	statetype state, next_state;
	
	typedef enum logic [2:0]
		{COL_RESET, C0, C1, C2, C3, COL_ERROR}
		colstatetype;
	colstatetype col_state, next_col_state;
	logic        col_en;
	
	// debouncer logic
	logic        db_en;
	logic [3:0]  db_criterion;
	logic [3:0]  db_fail_criterion;
	logic [31:0] db_period;
	logic        db_steady;
	//logic        db_error; // already included above
	
	// instantiate debouncer
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
	
	assign db_period = 240000; // target: 10 ms (24MHz / 240000 = 100 Hz)
	
	
	// state register
	always_ff @(posedge clk) begin
		if ( ~reset ) begin
			state <= RESET; // synchronous reset, active low
		    col_state <= COL_RESET;
		end
		else begin
			state <= next_state;
			col_state <= next_col_state;
		end
	end
	
	// scan column FSM
	// need to make col_state and next_col_state real logic & col_en
	always_comb begin
		if ( col_state == COL_RESET ) begin
								C = 4'b0000;
								next_col_state = C0;
		end
		else if (col_en) begin
			case (col_state)
				C0: 		begin	
								C = 4'b0001;
								next_col_state = C1; // this might transition a tick too late and so when READ reads col, it actually reads one state later than I thought
							end
				C1: 		begin	
								C = 4'b0010;
								next_col_state = C2; 
							end
				C2: 		begin	
								C = 4'b0100;
								next_col_state = C3; 
							end
				C3: 		begin 	
								C = 4'b1000;
								next_col_state = C0; 
							end
				COL_ERROR:  begin
								next_state = ERROR;
								next_col_state = COL_ERROR;
							end
				default:    next_col_state = COL_ERROR;
			endcase
		end
	end
	
	// next state logic
	always_comb begin
		case ( state )
			RESET:          				begin
												  db_en             = 0;
												  db_criterion      = 4'b0000;
												  db_fail_criterion = 4'b0000;
												  next_state        = SCAN_COL;
											end
			SCAN_COL:						begin
												  col_en       = 1;
												  next_state   = SYNC_BUFFER;	
											end
			SYNC_BUFFER:					begin
												  col_en       = 0;
												  next_state   = READ; // ONLY WAITS ONE TICK -- PROB DOESN'T WAIT LONG ENOUGH FOR SYNCHRONIZER, WHICH WILL CAUSE A BUG IF I ADD IT
											end
			READ:           case ( R ) 
								4'b0000: 		  next_state   = SCAN_COL;
								4'b0001: 	begin
												  db_criterion = 4'b0001;
												  next_state   = DEBOUNCE_HIGH;
											end
								4'b0010: 	begin
												  db_criterion = 4'b0010;
												  next_state   = DEBOUNCE_HIGH;
											end
								4'b0100: 	begin
												  db_criterion = 4'b0100;
												  next_state   = DEBOUNCE_HIGH;
											end
								4'b1000: 	begin
												  db_criterion = 4'b1000;
												  next_state   = DEBOUNCE_HIGH;
											end
								default: 		  next_state   = ERROR; // for simulaneous inputs -- MAY CAUSE A BUG
							endcase
			DEBOUNCE_HIGH:      			begin
												  db_en             = 1;  // idk if i want this here or before the state transition to debounce_high
												  db_fail_criterion = 4'b0000; // this too <--^^
							if      ( db_steady ) next_state        = ON;
							else if ( db_error )  next_state        = ERROR;
							else                  next_state        = DEBOUNCE_HIGH; // loop
											end
			ON:      						begin
												  db_en      = 0;
												  //db_fail_criterion = 4'b0000; // idk why this is here
												  R_out      = R;
							if ( R == 4'b0000 )	  next_state = DEBOUNCE_LOW;
							else 				  next_state = ON;
											end
			DEBOUNCE_LOW: 					begin
												  db_en             = 1;
												  R_out             = 4'b0000; 		   // idk if i want this here or in "SCAN_COL" (after debouncing)
												  db_criterion      = 4'b0000; 	   // make sure the button debounces for low
												  db_fail_criterion = 4'b0001; // I can't figure out how to implement this for all R != 4'b0000; MIGHT CAUSE A BUG
							if 		( db_steady ) next_state        = SCAN_COL;
							else if ( db_error )  next_state        = ERROR;
							else				  next_state        = DEBOUNCE_LOW; // loop
											end
			ERROR:      					begin
												  db_error   = 1;
												  next_state = ERROR;
											end
			default:  							  next_state = ERROR;
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