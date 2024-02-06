`timescale 1ns / 1ps

module ShapesScreen(
    input wire [1:0] state,
    output reg [11:0] vgaColor,
    input wire [10:0] vgaX, vgaY
    );

    //VGA Params
    localparam [9:0] VGA_WIDTH = 640;
    localparam [9:0] VGA_HEIGHT = 480;
    localparam [9:0] VGA_MIDDLE = VGA_WIDTH >> 1;

    //State
    localparam [1:0] YELLOW_SCREEN = 2'b00; //completely yellow screen
    localparam [1:0] RED_WHITE_BARS = 2'b01; //vertical alternating red white bars (16 wide)
    localparam [1:0] GREEN_BLOCK = 2'b10; //black screen w/ green block (128x128) in top right
    localparam [1:0] BLUE_STRIPE = 2'b11; //black screen w/ hori blue stripe (32 high) at bottom

    //Colors
    localparam [11:0] WHITE  = 12'hFFF;
    localparam [11:0] BLACK  = 12'h000;
    localparam [11:0] RED    = 12'hF00;
    localparam [11:0] GREEN  = 12'h0F0;
    localparam [11:0] BLUE   = 12'h00F;
    localparam [11:0] YELLOW = 12'hFF0;

    //VGA Color Logic
    always_comb begin
        case (state)
            YELLOW_SCREEN: vgaColor <= YELLOW;
            RED_WHITE_BARS: vgaColor <= (~vgaX[4]) ? RED : WHITE;
            GREEN_BLOCK: vgaColor <= (vgaY < 128 && vgaX > (VGA_WIDTH - 128)) ? GREEN : BLACK; 
            BLUE_STRIPE: vgaColor <= (vgaY > (VGA_HEIGHT - 32)) ? BLUE : BLACK;
        endcase
    end
endmodule