`timescale 1ns / 1ps

module Display(
    input wire CLK25, reset_n,
    input wire [1:0] state,
    input wire blockEnabled,
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
    localparam [11:0] WHITE  = {4'hF, 4'hF, 4'hF};
    localparam [11:0] BLACK  = {4'h0, 4'h0, 4'h0};
    localparam [11:0] RED    = {4'hF, 4'h0, 4'h0};
    localparam [11:0] GREEN  = {4'h0, 4'hF, 4'h0};
    localparam [11:0] BLUE   = {4'h0, 4'h0, 4'hF};
    localparam [11:0] YELLOW = {4'hF, 4'hF, 4'h0};

    //Block
    localparam [5:0] BLOCK_SIZE = 32;
    localparam [4:0] BLOCK_HALF_SIZE = BLOCK_SIZE >> 1;
    localparam [9:0] BLOCK_LEFT_X = VGA_MIDDLE - BLOCK_HALF_SIZE - 1;
    localparam [9:0] BLOCK_RIGHT_X = VGA_MIDDLE + BLOCK_HALF_SIZE + 1;
    localparam [9:0] BLOCK_BOTTOM_Y = VGA_HEIGHT - BLOCK_SIZE - 1;
    reg [9:0] blockY = 0;
    reg blockMovingDown = 0;

    localparam [23:0] BLOCK_SLOW_CLOCK_END = 12_500_000-1; //25MHz -> 2Hz
    reg [23:0] blockClockCounter = 0;

    //VGA Color Logic
    always_ff @(posedge CLK25) begin
        if (blockEnabled) begin
            if (vgaX > BLOCK_LEFT_X &&
                vgaX < BLOCK_RIGHT_X &&
                vgaY >= blockY &&
                vgaY <= blockY + BLOCK_SIZE) begin
                vgaColor <= RED;
            end
            else vgaColor <= BLUE;
        end
        else case (state)
            YELLOW_SCREEN: vgaColor <= YELLOW;
            RED_WHITE_BARS: vgaColor <= (~vgaX[4]) ? RED : WHITE;
            GREEN_BLOCK: vgaColor <= (vgaY < 128 && vgaX > (VGA_WIDTH - 128)) ? GREEN : BLACK; 
            BLUE_STRIPE: vgaColor <= (vgaY > (VGA_HEIGHT - 32)) ? BLUE : BLACK;
        endcase
    end

    //Block Logic
    always_ff @(posedge CLK25 or negedge reset_n) begin
        if (~reset_n) begin
             blockY <= 0;
             blockMovingDown <= 0;
             blockClockCounter <= 0;
        end
        else if (blockEnabled) begin
            //2Hz Slow Clock
            if (blockClockCounter == BLOCK_SLOW_CLOCK_END) begin
                blockClockCounter <= 0;

                //Move block in its direction
                if (blockMovingDown ?
                    (blockY < BLOCK_BOTTOM_Y) :
                    (blockY > 1)) begin
                    blockY <= blockMovingDown ? (blockY + 1) : (blockY - 1);
                end

                //Swap block direction
                else begin
                    blockMovingDown <= ~blockMovingDown;
                end
            end else blockClockCounter <= blockClockCounter + 1;
        end
    end
endmodule