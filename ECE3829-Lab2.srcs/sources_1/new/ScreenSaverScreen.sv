`timescale 1ns / 1ps

module ScreenSaverScreen(
    input wire CLK25, reset_n,
    output reg [11:0] vgaColor,
    input wire [10:0] vgaX, vgaY
    );

    //VGA Params
    localparam [9:0] VGA_WIDTH = 640;
    localparam [9:0] VGA_HEIGHT = 480;
    localparam [9:0] VGA_MIDDLE = VGA_WIDTH >> 1;

    //Colors
    localparam [11:0] BLACK  = {4'h0, 4'h0, 4'h0};
    localparam [11:0] TURQUOISE  = {4'h3, 4'hD, 4'hD}; //#30d5c8

    //Blob
    localparam [5:0] SIZE = 32;
    localparam [4:0] HALF_SIZE = SIZE >> 1;
    localparam [10:0] TOP_BOUND = HALF_SIZE;
    localparam [10:0] BOTTOM_BOUND = VGA_HEIGHT - HALF_SIZE;
    localparam [10:0] RIGHT_BOUND = HALF_SIZE;
    localparam [10:0] LEFT_BOUND = VGA_WIDTH - HALF_SIZE;
    reg [10:0] coordX = 0, coordY = 0; //center
    reg movingLeft = 0, movingUp = 0;

    localparam [15:0] CLOCK_END = 16'hFFFF;
    reg [15:0] clockCounter = 0;

    //VGA Color Logic
    always_comb begin
        if (vgaX >= (coordX - HALF_SIZE) &&
            vgaX <= (coordX + HALF_SIZE) &&
            vgaY >= (coordY - HALF_SIZE) &&
            vgaY <= (coordY + HALF_SIZE)) begin
            vgaColor <= TURQUOISE;
        end
        else vgaColor <= BLACK;
    end

    //Sync Logic
    always_ff @(posedge CLK25 or negedge reset_n) begin
        if (~reset_n) begin
            coordX <= 0;
            coordY <= 0;
            movingLeft <= 0;
            movingUp <= 0;
            clockCounter <= 0;
        end
        else begin
            if (clockCounter == CLOCK_END) begin
                clockCounter <= 0;

                //Horizontal Movement
                if (movingLeft ?
                    (coordX < LEFT_BOUND) :
                    (coordX > RIGHT_BOUND)) begin
                    coordX <= movingLeft ? (coordX - 1) : (coordX + 1);
                end
                else movingLeft <= ~movingLeft;

                //Vertical Movement
                if (movingUp ?
                    (coordY > TOP_BOUND) :
                    (coordY < BOTTOM_BOUND)) begin
                    coordY <= movingUp ? (coordY - 1) : (coordY + 1);
                end
                else movingUp <= ~movingUp;
            end
            else clockCounter <= clockCounter + 1;
        end
    end
endmodule