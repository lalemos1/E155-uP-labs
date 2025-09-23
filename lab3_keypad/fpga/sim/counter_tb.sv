// Lucas Lemos - llemos@hmc.edu - 9/16/2025
// Tests the counter module that it outputs the proper duty cycle relative to the clk from the HSOSC

module counter_tb;  // BUG: fails tv=32'b0 when it actually works
	// DUT logic
	logic        clk, reset, en;  // input to DUT
	logic [31:0] cnt_goal;        // input to DUT (value to count to before setting "tick" high (sets duty cycle of 24MHz clock))
	logic [3:0]  in;              // input to DUT (input necessary to iterate counter)
	logic [3:0]  criterion;       // input to DUT (the value the input must meet)
	logic        tick;            // output from DUT (the "on" period of the counter)
	
	// Testing logic unique to this DUT
	logic [31:0] expected_count;       // expected clock ticks before clk_div changes. Value derived from test vectors
	logic [31:0] clk_counter;          // counter of test clock
	
	// General testbench logic
	logic [31:0] vectornum;            // index value of test vectors 
	logic [31:0] errors;               // number of errors
	logic [31:0] testvectors[10000:0]; // create space for 10,000 32-bit wide test vectors
	
	// Instantiate device under test
	counter #( 
		.SIZE   ( 7'd32 ), 
		.WIDTH  ( 3'd4 ),
		.MAXVAL ( 26'd4 ) // 3'd2
	) DUT (
		.clk       ( clk ),             // input
		.reset     ( reset ),           // input
		.en        ( en ),              // input
		.cnt_goal  ( cnt_goal ),        // input [31:0]
		.in        ( in ),              // input {3:0]
		.criterion ( criterion ),       // input [3:0]
		
		.tick      ( tick )             // output
	);
	
	// Accounts for offset of divisor*2 in the implementation
	assign expected_count = cnt_goal + 1; // offset b/c moore machine (not mealy)
	assign in = 4'b0001;
	assign criterion = 4'b0001;
	
	// Generate test clock
	always
		begin
			clk=1; #5; clk=0; #5;
		end
	
	// Begin test by loading vectors, pulsing reset, & enabling the DUT
	initial
		begin
			$readmemb("counter_vectors.tv", testvectors);
			vectornum = 0; errors = 0; reset = 0; #12; reset = 1; #1 en = 1; // RESETTING BEFORE EN HAS A DEFINED VALUE MIGHT CAUSE A BUG
		end
	
	// Load next test vector
	always @(posedge clk)
		begin
			#1; {cnt_goal} = testvectors[vectornum]; //in, criterion // cnt_goal is both the input and the expected value ("output") of the counter 
		end 
	
	// Clock counter for checking against clk_div
	always @(posedge clk) begin
		if (reset == 0) clk_counter = 0;
		else            clk_counter = clk_counter + 1;
	end
	
	// Check counter output against counts of the test clock
	always @(posedge tick) begin
		assert (clk_counter == expected_count) else begin
				$display("Error: clk_div frequency incorrect.");
				$display(" clk_counter = %b (%b expected)", clk_counter, expected_count);
				errors = errors + 1;
			end
		#1; reset = 0; #12 reset = 1;
		vectornum = vectornum + 1;
		clk_counter = 0; // THIS IS BEHAVING WRONG FOR THE EXPECTED FUNCTIONALITY
		
		// Check if simulation has ended
		if (testvectors[vectornum] === 32'bx) begin
				$display("%d tests completed with %d errors", vectornum, errors);
				$stop;	// End the simulation
			end
	end
endmodule