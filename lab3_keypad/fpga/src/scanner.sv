// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// This module scans the keypad for inputs one column at a time and debounces valid inputs

module scanner(
				input logic        reset, clk,
				input logic  [3:0] R,
				
				output logic [3:0] C,
				output logic [3:0] R_out
			  );
	
	// instantiate debouncer
	debouncer #( .WIDTH(3'd4) ) (
		
	);
	
	// state logic
	typedef enum logic [3:0] 
		{RESET, SCAN_C0, SCAN_C1, SCAN_C2, SCAN_C3, DEBOUNCE_HIGH, ON, DEBOUNCE_LOW, ERROR} 
		statetype;
	statetype state, next_state;
	
	// state register
	always_ff @(posedge clk, posedge reset)
		if (reset)    state <= RESET;
		else		  state <= nextstate;
	
	// next state logic
	always_comb begin
		case ( state )
			RESET:                       next_state = SCAN_C0;
			SCAN_C0:        C <= 0001; // DOESN'T WAIT FOR SYNCHRONIZER -- WILL CAUSE BUG IF/WHEN I ADD IT
							case( R ) begin
								4'b0001: target <= 4'b0001; // I'm basically trying to enable the debouncer with target = R and wait for the debouncer to provide steady to move on, rather than have a dedicated DEBOUNCE state . I have no idea how to implement ERROR now, tho
										 debounce_en <= 1; 
										 if (steady) next_state = ON; // I wonder if I can replace this with a ternary statement
										 else        next_state = SCAN_C0;
								4'b0010:    
								4'b0100:    
								4'b1000:    
								4'b0000:    
								default: next_state = SCAN_C0; // for simulaneous inputs -- MAY CAUSE A BUG
							end
			/*
			SCAN_C1:        C <= 0010; // DOESN'T WAIT FOR SYNCHRONIZER -- WILL CAUSE BUG IF/WHEN I ADD IT     
							case( R ) begin
								0001:    next_state = DEBOUNCE_HIGH;
								0010:    next_state = DEBOUNCE_HIGH;
								0100:    next_state = DEBOUNCE_HIGH;
								1000:    next_state = DEBOUNCE_HIGH;
								0000:    next_state = SCAN_C2;
								default: next_state = SCAN_C1; // for simulaneous inputs -- MAY CAUSE A BUG
							end
			SCAN_C2:        C <= 0100; // DOESN'T WAIT FOR SYNCHRONIZER -- WILL CAUSE BUG IF/WHEN I ADD IT    
							case( R ) begin
								0001:    next_state = DEBOUNCE_HIGH;
								0010:    next_state = DEBOUNCE_HIGH;
								0100:    next_state = DEBOUNCE_HIGH;
								1000:    next_state = DEBOUNCE_HIGH;
								0000:    next_state = SCAN_C3;
								default: next_state = SCAN_C2; // for simulaneous inputs -- MAY CAUSE A BUG
							end
			SCAN_C3:        C <= 1000; // DOESN'T WAIT FOR SYNCHRONIZER -- WILL CAUSE BUG IF/WHEN I ADD IT
							case( R ) begin
								0001:    next_state = DEBOUNCE_HIGH;
								0010:    next_state = DEBOUNCE_HIGH;
								0100:    next_state = DEBOUNCE_HIGH;
								1000:    next_state = DEBOUNCE_HIGH;
								0000:    next_state = SCAN_C0;
								default: next_state = SCAN_C3; // for simulaneous inputs -- MAY CAUSE A BUG
							end
							*/
			DEBOUNCE_HIGH: // enable debouncer
			ON:      
			DEBOUNCE_LOW: 
			ERROR:      
			
			default:  next_state = ERROR;


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