module lab1_ll( input  logic       clk,
				input  logic       reset, // I'm not sure if this is necessary
				input  logic [3:0] s,
				output logic [6:0] seg);
				// Instantiate display submodules
				
				// Maybe i don't need to do that above^
				always_comb begin
					case (s)
						default: 
						4'b0001: 
						4'b0010: 
						4'b0011: 
						4'b0100:
						4'b0101: 
						4'b0110:
						4'b0111:
						4'b1000:
						4'b1001:
endmodule

//module 