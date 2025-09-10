// Lucas Lemos - llemos@hmc.edu - 9/8/2025
// Tests the valid combinational logic of the 2:1 mux, assuming a bus width of 4

module mux2_tb;
	// DUT logic
	logic [3:0] d0, d1; // inputs
	logic       s;      // input
	logic [3:0] y;      // output
	
	// Instantiate device under test
	mux2 #(.WIDTH( 3'd4 )) DUT(  // implements:   assign y = s ? d1 : d0; 
		.d0 ( d0 ), // input [3:0]
		.d1 ( d1 ), // input [3:0]
		.s  ( s ),  // input
		.y  ( y )  // output [3:0]
	);
	
	// Begin simulation
	initial begin
		#1; d0 = 4'b0000; d1 = 4'b0000; s = 0; #1; assert(y == 4'b0000) else $error("fail: 0 ? 0 : 0 != 0");
		#1; d0 = 4'b0000; d1 = 4'b0000; s = 1; #1; assert(y == 4'b0000) else $error("fail: 1 ? 0 : 0 != 0");
		#1; d0 = 4'b0001; d1 = 4'b0000; s = 0; #1; assert(y == 4'b0001) else $error("fail: 0 ? 0 : 1 != 1");
		#1; d0 = 4'b0001; d1 = 4'b0000; s = 1; #1; assert(y == 4'b0000) else $error("fail: 1 ? 0 : 1 != 0");
		#1; d0 = 4'b1111; d1 = 4'b1010; s = 0; #1; assert(y == 4'b1111) else $error("fail: 0 ? a : f != f");
		#1; d0 = 4'b1111; d1 = 4'b1010; s = 1; #1; assert(y == 4'b1010) else $error("fail: 1 ? a : f != a");
			
		$display("Tests completed.");
			$stop; // end test
		end
	
	
endmodule

/*
module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y
			  );

  assign y = s ? d1 : d0; 
endmodule
*/
/*
	// DUT logic
	logic [3:0] s;   // input
	logic [6:0] seg; // output
	
	// Instantiate device under test
	seven_seg_display DUT(
		.s   ( s ),  // input
		.seg ( seg ) // output
	);
	
	// Begin simulation
	initial begin
		#1; s = 4'b0000; #1; assert(seg == 7'b1000000) else $error("fail 0.");
		#1; s = 4'b0001; #1; assert(seg == 7'b1111001) else $error("fail 1.");
		#1; s = 4'b0010; #1; assert(seg == 7'b0100100) else $error("fail 2.");
		#1; s = 4'b0011; #1; assert(seg == 7'b0110000) else $error("fail 3.");	
		#1; s = 4'b0100; #1; assert(seg == 7'b0011001) else $error("fail 4.");
		#1; s = 4'b0101; #1; assert(seg == 7'b0010010) else $error("fail 5.");			
		#1; s = 4'b0110; #1; assert(seg == 7'b0000010) else $error("fail 6.");			
		#1; s = 4'b0111; #1; assert(seg == 7'b1111000) else $error("fail 7.");				
		#1; s = 4'b1000; #1; assert(seg == 7'b0000000) else $error("fail 8.");	
		#1; s = 4'b1001; #1; assert(seg == 7'b0010000) else $error("fail 9.");	
		#1; s = 4'b1010; #1; assert(seg == 7'b0001000) else $error("fail A.");	
		#1; s = 4'b1011; #1; assert(seg == 7'b0000011) else $error("fail B.");	
		#1; s = 4'b1100; #1; assert(seg == 7'b1000110) else $error("fail C.");	
		#1; s = 4'b1101; #1; assert(seg == 7'b0100001) else $error("fail D.");	
		#1; s = 4'b1110; #1; assert(seg == 7'b0000110) else $error("fail E.");	
		#1; s = 4'b1111; #1; assert(seg == 7'b0001110) else $error("fail F.");	
		#1; s = 4'bxxxx; #1; assert(seg == 7'b1111111) else $error("fail default.");
			
		$display("Tests completed.");
			$stop; // end test
		end
		*/