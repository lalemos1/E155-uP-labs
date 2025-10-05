// Lucas Lemos - llemos@hmc.edu - 9/24/2025
// Tests the combinational logic of the keypad decoder

module keybad_decoder_tb;
	logic [3:0] R_out;
	logic [3:0] C;
	//logic 	 error_led;
	logic [4:0] k;
	
	// Instantiate device under test
	keypad_decoder DUT(
		.R_out	( R_out ),
		.C		( C ),
		//.error_led
		.k		( k ) );
	
	initial begin
		R_out = 4'b0000; 
			C = 4'b0001; #5; 
			C = 4'b0010; #5; 
			C = 4'b0100; #5; 
			C = 4'b1000; #5;
		R_out = 4'b0001; 
			C = 4'b0001; #5; 
			C = 4'b0010; #5; 
			C = 4'b0100; #5; 
			C = 4'b1000; #5;
		R_out = 4'b0010; 
			C = 4'b0001; #5; 
			C = 4'b0010; #5; 
			C = 4'b0100; #5; 
			C = 4'b1000; #5;
		R_out = 4'b0100; 
			C = 4'b0001; #5; 
			C = 4'b0010; #5; 
			C = 4'b0100; #5; 
			C = 4'b1000; #5;
		R_out = 4'b1000; 
			C = 4'b0001; #5; 
			C = 4'b0010; #5; 
			C = 4'b0100; #5; 
			C = 4'b1000; #5;
	end
	/*
	initial begin
		for ( int i = 0; i < 4; i++ )
			for ( int j = 0; j < 4; j++ )
				R_out = 
	end
	*/
endmodule