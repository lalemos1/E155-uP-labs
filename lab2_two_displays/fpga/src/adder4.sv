// Lucas Lemos - llemos@hmc.edu - 9/8/2025
// Implements an adder which accepts two 4-bit inputs and outputs one 5-bit output

module adder4(
		  	  input  logic [3:0] a, b,
			  output logic [4:0] sum
			  );
	
	assign sum = a + b;
endmodule



/*
// alu for reference from E85 lab 11 multicycle processor
module alu( input  logic [31:0] a, b,
            input  logic [2:0]  alucontrol,
            output logic [31:0] result,
            output logic        zero); 

  logic [31:0] condinvb, sum;
  logic        sub;
  
  assign sub = (alucontrol[1:0] == 2'b01);
  assign condinvb = sub ? ~b : b; // for subtraction or slt
  assign sum = a + condinvb + sub;

  always_comb
    case (alucontrol)
      3'b000: result = sum;          // addition
      3'b001: result = sum;          // subtraction
      3'b010: result = a & b;        // and
      3'b011: result = a | b;        // or
      3'b101: result = sum[31];      // slt
      default: result = 0;
  endcase

  assign zero = (result == 32'b0);
endmodule
*/