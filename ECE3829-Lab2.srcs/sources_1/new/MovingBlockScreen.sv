`timescale 1ns / 1ps

module MovingBlockScreen(
    input wire CLK25, reset_n,
    input wire blockBoost,
    output reg [11:0] vgaColor,
    input wire [10:0] vgaX, vgaY
    );

    //VGA Params
    localparam [9:0] VGA_WIDTH = 640;
    localparam [9:0] VGA_HEIGHT = 480;
    localparam [9:0] VGA_MIDDLE = VGA_WIDTH >> 1;

    //Colors
    localparam [11:0] RED    = {4'hF, 4'h0, 4'h0};
    localparam [11:0] BLUE   = {4'h0, 4'h0, 4'hF};

    //Block
    localparam [5:0] BLOCK_SIZE = 32;
    localparam [4:0] BLOCK_HALF_SIZE = BLOCK_SIZE >> 1;
    localparam [9:0] BLOCK_LEFT_X = VGA_MIDDLE - BLOCK_HALF_SIZE - 1;
    localparam [9:0] BLOCK_RIGHT_X = VGA_MIDDLE + BLOCK_HALF_SIZE + 1;
    localparam [9:0] BLOCK_BOTTOM_Y = VGA_HEIGHT - BLOCK_SIZE - 1;
    reg [9:0] blockY = 0;
    reg blockMovingDown = 0;

    localparam [23:0] BLOCK_SLOW_CLOCK_END = 12_500_000-1; //25MHz -> 2Hz
    localparam [23:0] BLOCK_FAST_CLOCK_END = 1_562_500-1; //25MHz -> 16Hz
    reg [23:0] blockClockCounter = 0;

    //VGA Color Logic
    always_ff @(posedge CLK25) begin
        if (vgaX > BLOCK_LEFT_X &&
            vgaX < BLOCK_RIGHT_X &&
            vgaY >= blockY &&
            vgaY <= blockY + BLOCK_SIZE) begin
            vgaColor <= RED;
        end
        else vgaColor <= BLUE;
    end

    //Block Logic
    always_ff @(posedge CLK25 or negedge reset_n) begin
        if (~reset_n) begin
             blockY <= 0;
             blockMovingDown <= 0;
             blockClockCounter <= 0;
        end
        else begin
            if (blockClockCounter == (blockBoost ? BLOCK_FAST_CLOCK_END : BLOCK_SLOW_CLOCK_END)) begin
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