// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// ASYNCHRONOUS!!! Resettable and enableable flip flop I borrowed from E85

module flopenr #(parameter WIDTH = 8)
                (input  logic             clk, reset, en,
                 input  logic [WIDTH-1:0] d, 
                 output logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset)	  q <= 0;
    else if (en) q <= d;
endmodule