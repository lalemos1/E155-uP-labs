// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// This module implements the column scanner FSM

module col_fsm(
				input logic        reset, clk, en,
				
				output logic [3:0] C,
				output logic	   col_error_led
			  );
	
	// state logic
	typedef enum logic [2:0]
		{RESET, C0, C1, C2, C3, ERROR}
		statetype;
	statetype state, next_state;
	
	// state register
	always_ff @(posedge clk) begin
		if ( ~reset ) state <= RESET; // synchronous reset, active low
		else 		  state <= next_state; // i probably should've implemented en here, but oh well
	end
	
	// next state logic
	always_comb begin
		// next state logic depends on en, else next_state = state
		if ( en ) begin
			case ( state )
				RESET:	 next_state = C0;
				C0: 	 next_state = C1; // this might transition a tick too late and so when READ reads col, it actually reads one state later than I thought
				C1: 	 next_state = C2; 
				C2: 	 next_state = C3;
				C3: 	 next_state = C0;
				ERROR:	 next_state = ERROR;
				default: next_state = ERROR;
			endcase
		end
		else if ( state == RESET ) next_state = RESET;
		else next_state = state;
	end
	
	// next state logic
	always_comb begin
		// output logic independent of en
		case ( state )
			RESET:	 C = 4'b0000;
			C0:		 C = 4'b0001;
			C1: 	 C = 4'b0010;
			C2: 	 C = 4'b0100;
			C3:		 C = 4'b1000;
			default: C = 4'b0000;
		endcase
	end
	assign col_error_led = ( state == ERROR );
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