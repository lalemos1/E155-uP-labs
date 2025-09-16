// Lucas Lemos - llemos@hmc.edu - 9/8/2025
// Tests the valid combinational logic of the 4 bit adder

module adder4_tb;
	// DUT logic
	logic [3:0] a, b; // inputs
	logic [4:0] sum;  // output
	
	// Instantiate device under test
	adder4 DUT(        // implements:   assign sum = a + b;
		.a ( a ),      // input [3:0]
		.b ( b ),      // input [3:0]
		.sum  ( sum )  // output [3:0]
	);
	
	// Begin simulation
	initial begin
		#1; a = 4'b0000; b = 4'b0000; #1; assert(sum == 5'b00000) else $error("fail: 0 + 0 != 0");
		#1; a = 4'b0000; b = 4'b0001; #1; assert(sum == 5'b00001) else $error("fail: 0 + 1 != 1");
		#1; a = 4'b0001; b = 4'b0000; #1; assert(sum == 5'b00001) else $error("fail: 1 + 0 != 1");
		#1; a = 4'b0001; b = 4'b0001; #1; assert(sum == 5'b00010) else $error("fail: 1 + 1 != 2");
		#1; a = 4'b0111; b = 4'b0001; #1; assert(sum == 5'b01000) else $error("fail: 7 + 1 != 8");
		#1; a = 4'b1111; b = 4'b0001; #1; assert(sum == 5'b10000) else $error("fail: f + 1 != 10");
		#1; a = 4'b1111; b = 4'b1111; #1; assert(sum == 5'b11110) else $error("fail: f + f != 1e");
			
		$display("Tests completed.");
			$stop; // end test
		end

endmodule

/*
module adder4(
		  	  input  logic [3:0] a, b,
			  output logic [4:0] sum
			  );
	
	assign sum = a + b;
endmodule
*/