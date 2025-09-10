// Lucas Lemos - llemos@hmc.edu - 9/2/2025
// Tests the top level module of the lab_2_ll_two_displays project.
// Tests that the HSOSC outputs a valid clock, the LED count adder computes the right value based on the two input switches,
// the switch select mux properly oscillates according to the divided clock, and that the project exhibits the proper overall behavior.

module lab_2_ll_tb;
	// DUT logic
	logic [3:0] switch1, switch2, // input
	logic       reset_p34,        // input
	logic       clk_div_p2,       // output
	logic [4:0] led_cnt,          // output
	logic [6:0] seg               // output
	
	// Testing logic unique to this DUT	
	
	
	// General testbench logic	
	//logic [31:0] vectornum;            // index value of test vectors 
	//logic [31:0] errors;               // number of errors
	//logic [31:0] testvectors[10000:0]; // create space for 10,000 32-bit wide test vectors
	
	// Instantiate device under test	
	lab2_ll_two_displays DUT(
		.switch1 ( switch1 ),       // input [3:0]
		.switch2 ( switch2 ),       // input [3:0]
		.reset_p34 ( reset_p34 ),   // input
		.clk_div_p2 ( clk_div_p2 ), // output
		.led_cnt ( led_cnt ),       // output [4:0]
		.seg ( seg ),               // output [6:0]
	);
	
	// Simulate 
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
	
	
	
	// Generate test clock	
	
	
	// Begin test by loading vectors & pulsing reset
	
	
	// Load next test vector	
	
	
	// Check divided clock against counts of the test clock
	
	
		// Check if simulation has ended