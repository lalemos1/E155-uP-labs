// Lucas Lemos - llemos@hmc.edu - 9/6/2025
// Tests the clk_divider that it properly divides the high speed oscillator
// down by divisor*2.

module clk_divider_testbench;  // BUG: fails tv=32'b0 when it actually works
	// DUT logic
	logic        clk, reset; // input to DUT
	logic [31:0] divisor;    // input to DUT
	logic        clk_div;    // output from DUT
	
	// Testing logic unique to this DUT
	logic [31:0] expected_count;       // expected clock ticks before clk_div changes. Value derived from test vectors
	logic [31:0] clk_counter;          // counter of test clock
	
	// General testbench logic
	logic [31:0] vectornum;            // index value of test vectors 
	logic [31:0] errors;               // number of errors
	logic [31:0] testvectors[10000:0]; // create space for 10,000 32-bit wide test vectors
	
	// Instantiate device under test
	clk_divider DUT(
		.clk        ( clk ),        // input
		.reset      ( reset ),      // input
		.divisor    ( divisor ),    // input
		.clk_div    ( clk_div )     // output
	);
	
	// Accounts for offset of divisor*2 in the implementation
	assign expected_count = divisor<<1;
	
	// Generate test clock
	always
		begin
			clk=1; #5; clk=0; #5;
		end
	
	// Begin test by loading vectors & pulsing reset
	initial
		begin
			$readmemb("clk_divider_vectors.tv", testvectors);
			vectornum = 0; errors = 0; reset = 0; #22; reset = 1;
		end
	
	// Load next test vector
	always @(posedge clk)
		begin
			#1; {divisor} = testvectors[vectornum]; // divisor is both the input and the expected value of the counter
		end 
	
	// Clock counter for checking against clk_div
	always @(posedge clk) begin
		if (reset == 0) clk_counter = 0;
		else            clk_counter = clk_counter + 1;
	end
	
	// Check divided clock against counts of the test clock
	always @(posedge clk_div) begin
		assert (clk_counter == expected_count) else begin
				$display("Error: clk_div frequency incorrect.");
				$display(" clk_counter = %b (%b expected)", clk_counter, expected_count);
				errors = errors + 1;
			end
			
		vectornum = vectornum + 1;
		clk_counter = 0;
		
		// Check if simulation has ended
		if (testvectors[vectornum] === 32'bx) begin
				$display("%d tests completed with %d errors", vectornum, errors);
				$stop;	// End the simulation
			end
	end
endmodule

/*
// old testbench (assumed test vectors)
module clk_divider_testbench();
	logic clk, reset; // input to dut
	logic multiplier; // input to dut
	logic clk_div;    // output to dut
	
	logic [##:0] expected;             // expected value from test vectors
	logic [31:0] vectornum, errors;    // index value of test vectors and number of errors
	logic [##:0]  testvectors[10000:0]; // create 10,000 ##+1 wide test vectors
	
	// Instantiate device under test
	clk_divider dut(
		.clk        ( clk ),        // input
		.reset      ( reset ),      // input
		.multiplier ( multiplier ), // input
		.clk_div    ( clk_div )     // output
	);
	
	// Generate clock
	always
		begin
			clk=1; #2083; clk=0; #2083; // generates 48 MHz clock (assuming #1 = 10 ps)
		end
	
	// Begin test by loading vectors & pulsing reset
	initial
		begin
			$readmemb("clk_divider_vectors.tv", testvectors);
			vectornum = 0; errors = 0; reset = 1; #22; reset = 0;
		end
		
	// I'D FORGOTTEN TO LOAD TEST VECTORS HERE
	
	// Check results on falling edge of clk
	always @(nededge clk)
		if (~reset) begin // skip during reset
			if (clk_div !== expected) begin // if the clock division is wrong
				$display("Error: multiplier = %b", multiplier);
				$display(" clk_div = %b (%b expected)", clk_div, expected);
				errors = errors + 1;
			end
			vectornum = vectornum + 1;
			if (testvectors[vectornum] === ##'bx) begin // If sim ended
				%display("%d tests completed with %d errors", vectornum, errors);
				$stop;	
			end
		end
endmodule
*/


// the clk_divider, for reference
/*
module clk_divider (
				 input  logic  clk, reset,
				 input  logic  divisor,
				 output logic  clk_div
				 );

	logic [31:0] counter; // 32 bit counter of clock ticks (allows for dividing by up to 4.3e9)
	
	always_ff @(posedge clk) begin
		if (reset == 0)  begin
			  counter <= 0;
			  clk_div <= 0;
		end
		else if (counter == divisor) begin
			  clk_div <= ~clk_div;
			  counter <= 0;
		else  counter <= counter + 1;
	end
endmodule
*/