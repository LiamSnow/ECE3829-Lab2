`timescale 1ns / 1ps

module Display(
    input wire CLK25, reset_n,
    input wire [1:0] state,
    input wire stateOverride,
    output reg [11:0] vgaColor,
    input wire vgaX, vgaY
);

    //State
    localparam YELLOW_SCREEN = 2'b00; //completely yellow screen
    localparam RED_WHITE_BARS = 2'b01; //vertical alternating red white bars (16 wide)
    localparam GREEN_BLOCK = 2'b10; //black screen w/ green block (128x128) in top right
    localparam BLUE_STRIPE = 2'b11; //black screen w/ hori blue stripe (32 wide) at bottom

    //Colors
    localparam [11:0] WHITE  = {4'hF, 4'hF, 4'hF};
    localparam [11:0] BLACK  = {4'h0, 4'h0, 4'h0};
    localparam [11:0] RED    = {4'hF, 4'h0, 4'h0};
    localparam [11:0] GREEN  = {4'h0, 4'hF, 4'h0};
    localparam [11:0] BLUE   = {4'h0, 4'h0, 4'hF};
    localparam [11:0] YELLOW = {4'hF, 4'hF, 4'h0};

    always_ff @(posedge CLK25 or reset_n) begin
        if (~reset_n) begin
        
        end
        else if (stateOverride) begin
            //blue screen w/ red block (32x32) that moves down at 2hz
        end
        else case (state)
            YELLOW_SCREEN: begin
                vgaColor <= YELLOW;
            end
            RED_WHITE_BARS: begin
                //vertical alternating red white bars (16 wide)
            end
            GREEN_BLOCK: begin
                //black screen w/ green block (128x128) in top right
            end
            BLUE_STRIPE: begin
                //black screen w/ hori blue stripe (32 wide) at bottom
            end
        endcase
    end

endmodule

