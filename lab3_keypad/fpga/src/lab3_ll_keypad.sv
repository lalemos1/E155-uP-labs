// Lucas Lemos - llemos@hmc.edu - 9/15/2025
// This top level module scans and reads an asynchronous input from a 4x4 matrix keypad, decodes the result, 
// stores the last two presses in memory, and displays them on a two digit 7-segment display

module lab3_ll_keypad (
		input  logic [3:0] 	R_in,
		input  logic       	reset_p34, // P34 is connected to a pushbutton on the dev board

		output logic [3:0]	C,
		//output logic		error_led_p10,
		output logic 		read_error_led,
		output logic		db_error_led,
		output logic		col_error_led,
		output logic		mem_error_led,
		
		output logic       	clk_div_p44, not_clk_div_p9,
		output logic [6:0] 	seg );
		
	assign db_error_led = 1; // DELETE THIS
	
	// Internal module logic
	logic [3:0] R_out;
	logic [3:0] R;
	logic [4:0] k;
	logic [3:0] dig0;
	logic [3:0] dig1;
	logic		clk;

	// Instantiate synchronizer // I NEED A RESET SYNCHRONIZER
	synchronizer #( .WIDTH ( 3'd4 ) ) synchronizer (
			.clk	( clk ),
			.reset	( reset_p34 ),
			.d_a	( R_in ),
			.q		( R ) );
	
	// Instantiate scanner
	scanner scanner (
		.clk        ( clk ),        	// input
		.reset      ( reset_p34 ),  	// input
		.R			( R ),			// input [3:0] DIRECTLY CONNECTING R_IN WHILE THERE'S NO SYNCHRONIZER
		
		.C  		( C ),  			// output [3:0] 
		.R_out		( R_out ),			// output [3:0]
		.read_error_led ( read_error_led ),
		.col_error_led	( col_error_led ) );// output
		
	
	// Instantiate keypad_decoder
	keypad_decoder keypad_decoder(
		.R_out	( R_out ),	// input [3:0]
		.C		( C ),		// input [3:0]
		//.error_led
		.k		( k ) );	// output [4:0]
		
	// Instantiate digit_mem
	digit_mem digit_mem (
		.clk    ( clk ),    	// input
		.reset  ( reset_p34 ),  // input
		.k		( k ),			// input [4:0]
		
		.mem_error_led ( mem_error_led ), // output
		.dig0  	( dig0 ),  		// output [3:0] 
		.dig1 	( dig1 ) );		// output [3:0] 
		
	// Instantiate two_dig_display
	two_dig_display two_dig_display(
		.switch1        ( dig1 ),       	// input [3:0]
		.switch2        ( dig0 ),       	// input [3:0]
		.reset_p34      ( reset_p34 ),     	// input
		.clk_div_p44    ( clk_div_p44 ),   	// output
		.not_clk_div_p9 ( not_clk_div_p9 ), // output
		//.led_cnt        ( led_cnt ),       	// output [4:0]
		.seg            ( seg ),            // output [6:0]
		.clk			( clk )				// output
	);
	
endmodule