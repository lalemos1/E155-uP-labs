module two_digit_display(
    input  logic clk,             // oscillator clock (from lab1_ll)
    input  logic reset,           // active-high reset
    input  logic [3:0] digitA,    // first 4-bit input
    input  logic [3:0] digitB,    // second 4-bit input
    output logic [6:0] seg,       // seven segment outputs
    output logic [1:0] an         // anode enables (active low if common anode)
);

    // Internal signals
    logic toggle;          // toggles between digit A and digit B
    logic [15:0] counter;  // slow clock divider
    logic [3:0] current_digit;
    logic [6:0] seg_out;

    //------------------------------------------------------------
    // Clock divider: generate slower toggle signal
    //------------------------------------------------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 16'd0;
            toggle  <= 1'b0;
        end else begin
            counter <= counter + 1;
            if (counter == 16'd0) // overflow → toggle
                toggle <= ~toggle;
        end
    end

    //------------------------------------------------------------
    // Choose which digit to show
    //------------------------------------------------------------
    always_comb begin
        if (toggle == 1'b0) begin
            current_digit = digitA;
            an = 2'b10;   // enable digit 0, disable digit 1 (assuming active low)
        end else begin
            current_digit = digitB;
            an = 2'b01;   // enable digit 1, disable digit 0
        end
    end

    //------------------------------------------------------------
    // Use provided seven segment decoder
    //------------------------------------------------------------
    seven_seg_display u_decoder (
        .bin_in(current_digit),
        .seg(seg_out)
    );

    assign seg = seg_out;

endmodule
