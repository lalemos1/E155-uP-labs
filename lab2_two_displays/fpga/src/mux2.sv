// Lucas Lemos - llemos@hmc.edu - 9/8/2025
// This module implements a 2 bus input, 1 bus output mux, where the bus size is determined by WIDTH.
// The module is borrowed from the Multicycle processor in E85


module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y
			  );

  assign y = s ? d1 : d0; 
endmodule

/*
// Spare 3to1 mux also from the multicycle processor in E85
module mux3 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);

  assign y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule
*/