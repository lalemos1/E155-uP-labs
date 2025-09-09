// Lucas Lemos - llemos@hmc.edu - 9/6/2025
// The HSOSC module implements the high speed oscillator from the iCE40 library


module HSOSC(
				output clk);
	HSOSC #(.CLKHF_DIV(2'b01)) // dividing clock by 1
		 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));