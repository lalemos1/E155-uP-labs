module seven_segment_multiplexed (
    input logic clk,                // System clock
    input logic rst_n,              // Active-low reset
    input logic [3:0] in0,          // First 4-bit input
    input logic [3:0] in1,          // Second 4-bit input
    output logic [6:0] seg_a,       // 7-segment outputs (a-g)
    output logic [1:0] an           // Display enable (active-low)
);

    // Internal signals
    logic toggle;                   // Toggles between 0 and 1 to select input
    logic [3:0] current_input;      // Input selected for decoding
    logic [15:0] clk_div;           // Clock divider for multiplexing speed

    // Clock Divider (adjust top bits to control refresh rate)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;
    end

    // Toggle bit for multiplexing (choose clk_div[15] to get ~500Hz from 50MHz clk)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            toggle <= 0;
        else
            toggle <= clk_div[15]; // Change bit for different refresh rates
    end

    // Select input and active display
    always_comb begin
        case (toggle)
            1'b0: begin
                current_input = in0;
                an = 2'b10; // Enable display 0 (active-low)
            end
            1'b1: begin
                current_input = in1;
                an = 2'b01; // Enable display 1 (active-low)
            end
        endcase
    end

    // 7-Segment Decoder (Common Anode: active-low output)
    always_comb begin
        case (current_input)
            4'h0: seg_a = 7'b0000001;
            4'h1: seg_a = 7'b1001111;
            4'h2: seg_a = 7'b0010010;
            4'h3: seg_a = 7'b0000110;
            4'h4: seg_a = 7'b1001100;
            4'h5: seg_a = 7'b0100100;
            4'h6: seg_a = 7'b0100000;
            4'h7: seg_a = 7'b0001111;
            4'h8: seg_a = 7'b0000000;
            4'h9: seg_a = 7'b0000100;
            4'hA: seg_a = 7'b0001000;
            4'hB: seg_a = 7'b1100000;
            4'hC: seg_a = 7'b0110001;
            4'hD: seg_a = 7'b1000010;
            4'hE: seg_a = 7'b0110000;
            4'hF: seg_a = 7'b0111000;
            default: seg_a = 7'b1111111; // All segments off
        endcase
    end

endmodule
