// Lucas Lemos - llemos@hmc.edu - 9/22/2025
// Tests the debouncer module that it properly ensures steady state or throws an error if the output never steadies

module debouncer_tb; 
	// DUT logic
	logic        clk, reset, en;  // input to DUT
	logic        R;               // input to DUT
	logic        criterion;       // input to DUT
	logic        fail_criterion;  // input to DUT
	logic [31:0] debounce_period; // input to DUT 
	
	logic        steady;           // output from DUT
	logic        error;            // output from DUT
	
	// Instantiate device under test
	debouncer #( 
		.WIDTH ( 1'b1 )
	) DUT (
		.clk             ( clk ),             // input
		.reset           ( reset ),           // input
		.en              ( en ),              // input
		.in              ( R ),               // input {3:0]
		.criterion       ( criterion ),       // input [3:0]
		.fail_criterion  ( fail_criterion ),  // input [3:0]
		.debounce_period ( debounce_period ), // input [31:0]
	
		.steady          ( steady ),          // output
		.error           ( error )            // output
	);
	
	assign criterion = 1'b1;
	assign fail_criterion = 1'b0;
	assign debounce_period = 31'd4;
	
	// Generate test clock
	always
		begin
			clk=1; #5; clk=0; #5;
		end
	
	// Begin test by pulsing reset & enabling the DUT
	initial
		begin
		reset = 0; #12; reset = 1; #1 en = 1;
		end
	
endmodule