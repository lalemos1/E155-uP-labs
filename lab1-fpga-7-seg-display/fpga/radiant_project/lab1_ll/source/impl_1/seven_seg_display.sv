// Lucas Lemos - llemos@hmc.edu - 9/2/2025
// 7-segment LED display decoder using combinational logic 
module seven_seg_display( input   logic [3:0] s,
					  output  logic [6:0] seg);
					  
	always_comb begin
		case (s)
			default:	seg = 7'b1111111;
			4'b0000:	seg = 7'b1111110;
			4'b0001:	seg = 7'b1001111;
			4'b0010:	seg = 7'b0010010;
			4'b0011:	seg = 7'b0000110;
			4'b0100:	seg = 7'b1001100;
			4'b0101:	seg = 7'b0100100;
			4'b0110:	seg = 7'b0100000;
			4'b0111:	seg = 7'b0001111;
			4'b1000:	seg = 7'b0000000;
			4'b1001:	seg = 7'b0000100;
		endcase
	end
endmodule