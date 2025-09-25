// Lucas Lemos - llemos@hmc.edu - 9/24/2025
// Decodes the row and column inputs from the scanner into a dummy 4-throw switche that the two_dig_display expects
module keypad_decoder( 
						input  logic [3:0] R_out,
						input  logic [3:0] C,
						//output logic 	   error_led,
					    output logic [4:0] k);
					  
	// Using a Jameco 152063 4x4 matrix keypad
	// key   - hex - pins  - row & col
	// 1     - 1   - 1 & 5 - R0 & C0
	// 2     - 2   - 1 & 6 - R0 & C1
	// 3     - 3   - 1 & 7 - R0 & C2
	// up    - A   - 1 & 8 - R0 & C3
	// 4     - 4   - 2 & 5 - R1 & C0
	// 5     - 5   - 2 & 6 - R1 & C1
	// 6     - 6   - 2 & 7 - R1 & C2
	// down  - B   - 2 & 8 - R1 & C3
	// 7     - 7   - 3 & 5 - R2 & C0
	// 8     - 8   - 3 & 6 - R2 & C1
	// 9     - 9   - 3 & 7 - R2 & C2
	// 2nd   - C   - 3 & 8 - R2 & C3
	// CLEAR - E   - 4 & 5 - R3 & C0
	// 0     - 0   - 4 & 6 - R3 & C1
	// HELP  - F   - 4 & 7 - R3 & C2
	// ENTER - D   - 4 & 8 - R3 & C3
	// 				 9 GND
	
	always_comb begin
		case ( R_out )
			4'b0000:					k = 5'b10000; // no output (5th bit for no output)
			// R0
			4'b0001: 	case ( C )
							4'b0001:	k = 5'b00001; // 1
							4'b0010: 	k = 5'b00010; // 2
							4'b0100: 	k = 5'b00011; // 3
							4'b1000: 	k = 5'b01010; // A
							default: begin 
										//error_led = 1;
										k = 5'b10000;
									end
						endcase
			// R1
			4'b0010:	case ( C )
							4'b0001:	k = 5'b00100; // 4
							4'b0010: 	k = 5'b00101; // 5
							4'b0100: 	k = 5'b00110; // 6
							4'b1000: 	k = 5'b01011; // B
							default: begin 
										//error_led = 1;
										k = 5'b10000;
									end
						endcase
			// R2
			4'b0100:	case ( C )
							4'b0001:	k = 5'b00111; // 7
							4'b0010: 	k = 5'b01000; // 8
							4'b0100: 	k = 5'b01001; // 9
							4'b1000: 	k = 5'b01100; // C
							default: begin 
										//error_led = 1;
										k = 5'b10000;
									end
						endcase
			// R3
			4'b1000:	case ( C )
							4'b0001:	k = 5'b01110; // E
							4'b0010: 	k = 5'b00000; // 0
							4'b0100: 	k = 5'b01111; // F
							4'b1000: 	k = 5'b01101; // D
							default: begin 
										//error_led = 1;
										k = 5'b10000;
									end
						endcase
			default: 				begin 
										//error_led = 1;
										k = 5'b10000;
									end
						

			/*
						4'b0000:	seg = 7'b1000000; // GFEDCBA on 7-seg display
			4'b0001:	seg = 7'b1111001;
			4'b0010:	seg = 7'b0100100;
			4'b0011:	seg = 7'b0110000;
			4'b0100:	seg = 7'b0011001;
			4'b0101:	seg = 7'b0010010;
			4'b0110:	seg = 7'b0000010;
			4'b0111:	seg = 7'b1111000;
			4'b1000:	seg = 7'b0000000;
			4'b1001:	seg = 7'b0010000;
			4'b1010:	seg = 7'b0001000; // A
			4'b1011:	seg = 7'b0000011; // b
			4'b1100:	seg = 7'b1000110; // C
			4'b1101:	seg = 7'b0100001; // d
			4'b1110:	seg = 7'b0000110; // E
			4'b1111:	seg = 7'b0001110; // F
			default:	seg = 7'b1111111; // off
			*/
		endcase
	end
endmodule