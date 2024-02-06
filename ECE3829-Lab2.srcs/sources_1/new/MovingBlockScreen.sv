`timescale 1ns / 1ps

module MovingBlockScreen(
    input wire CLK25, reset_n,
    output reg [11:0] vgaColor,
    input wire [10:0] vgaX, vgaY
    );

    //VGA Params
    localparam [9:0] VGA_WIDTH = 640;
    localparam [9:0] VGA_HEIGHT = 480;
    localparam [9:0] VGA_MIDDLE_X = VGA_WIDTH >> 1;
    localparam [9:0] VGA_MIDDLE_Y = VGA_HEIGHT >> 1;

    //Colors
    localparam [11:0] RED    = 12'hF00;
    localparam [11:0] BLUE   = 12'h00F;

    //Block
    localparam [5:0] BLOCK_SIZE = 32;
    localparam [4:0] BLOCK_HALF_SIZE = BLOCK_SIZE >> 1;
    localparam [10:0] BLOCK_LEFT_X = VGA_MIDDLE_X - BLOCK_HALF_SIZE - 1;
    localparam [10:0] BLOCK_RIGHT_X = VGA_MIDDLE_X + BLOCK_HALF_SIZE + 1;
    reg [10:0] blockY = VGA_MIDDLE_Y; //center coord
    reg blockMovingUp = 0;

    localparam [23:0] BLOCK_CLOCK_END = 12_500_000-1; //25MHz -> 2Hz
    reg [23:0] blockClockCounter = 0;

    //VGA Color Logic
    always_comb begin
        if (vgaX > BLOCK_LEFT_X &&
            vgaX < BLOCK_RIGHT_X &&
            vgaY >= (blockY - BLOCK_HALF_SIZE) &&
            vgaY <= (blockY + BLOCK_HALF_SIZE)) begin
            vgaColor <= RED;
        end
        else vgaColor <= BLUE;
    end

    //Block Logic
    always_ff @(posedge CLK25 or negedge reset_n) begin
        if (~reset_n) begin
             blockY <= VGA_MIDDLE_Y;
             blockMovingUp <= 0;
             blockClockCounter <= 0;
        end
        else begin
            if (blockClockCounter == BLOCK_CLOCK_END) begin
                blockClockCounter <= 0;

                // Moving Up
                if (blockMovingUp) begin
                    if (blockY > (BLOCK_HALF_SIZE)) begin
                        blockY <= blockY - BLOCK_SIZE;
                    end else begin
                        blockMovingUp <= 0;
                        blockY <= blockY + BLOCK_SIZE;
                    end
                end
                
                // Moving Down
                else begin
                    if (blockY < (VGA_HEIGHT - BLOCK_HALF_SIZE)) begin
                        blockY <= blockY + BLOCK_SIZE;
                    end else begin
                        blockMovingUp <= 1;
                        blockY <= blockY - BLOCK_SIZE;
                    end
                end
            end
            else blockClockCounter <= blockClockCounter + 1;
        end
    end
endmodule