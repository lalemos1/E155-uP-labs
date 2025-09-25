// Lucas Lemos - llemos@hmc.edu - 9/24/2025
// This module stores the last two digits pressed by the keypad and updates whenever there is a change from the keypad

module digit_mem(
		input  logic       reset, clk,
		input  logic [4:0] k,
		
		output logic	   mem_error_led,
		output logic [3:0] dig0,
		output logic [3:0] dig1 );
		
		// internal logic
		logic [3:0] k_in;
		logic 		no_k;
		
		assign k_in = k[3:0];
		assign no_k = k[4];
		
		// state logic
		typedef enum logic [2:0]
			{RESET, IDLE, NEXT_DIG, ON, ERROR}
			statetype;
		statetype state, next_state;
		
		// state register
		always_ff @( posedge clk ) begin
			if ( ~reset ) 	state <= RESET; // synchronous reset, activelow
			else			state <= next_state;
		end
		
		// next state logic
		always_comb begin
			case ( state )
				RESET: 		next_state = IDLE;
				IDLE: 		begin
								if ( no_k ) next_state = IDLE;
								else		next_state = NEXT_DIG;
							end
				NEXT_DIG:	next_state = ON;
				ON:			begin
								if ( k_in != dig0 ) next_state = IDLE; // should it be k_in == 4'b0000 instead of dig0? Might cause bug.
								else 				next_state = ON;
							end
				ERROR:		next_state = ERROR;
				default:	next_state = ERROR;
			endcase
		end
		
		// output logic
		always_ff @( posedge clk ) begin
			if ( state == RESET ) begin
				dig0 <= 4'b0000;
				dig1 <= 4'b0000;
			end
			else if ( state == NEXT_DIG ) begin
				dig1 <= dig0;
				dig0 <= k_in;
			end
			else begin
				dig1 <= dig1;
				dig0 <= dig0;
			end
		end
		assign mem_error_led = (state == ERROR);
		
		/*
		// state logic
	typedef enum logic [2:0]
		{RESET, C0, C1, C2, C3, ERROR}
		statetype;
	statetype state, next_state;
	
	// state register
	always_ff @(posedge clk) begin
		if ( ~reset ) state <= RESET; // synchronous reset, active low
		else 		  state <= next_state;
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
*/
		
endmodule