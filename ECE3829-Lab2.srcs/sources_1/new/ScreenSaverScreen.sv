`timescale 1ns / 1ps

module ScreenSaverScreen(
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
    localparam [11:0] BLACK = 12'hFFF;
    localparam [11:0] COLORS [0:3] = {
        12'h0E9,
        12'h9E0,
        12'hE90,
        12'hE09
    };

    //Blob
    localparam [5:0] SIZE = 32;
    localparam [4:0] HALF_SIZE = SIZE >> 1;
    reg [10:0] coordX = VGA_MIDDLE_X, coordY = VGA_MIDDLE_Y; //center
    reg movingLeft = 0, movingUp = 0;
    reg [1:0] currentColorIndex = 0;
    wire [11:0] currentColor = COLORS[currentColorIndex];

    localparam [15:0] CLOCK_END = 16'hFFFF;
    reg [15:0] clockCounter = 0;

    //VGA Color Logic
    always_comb begin
        if (vgaX >= (coordX - HALF_SIZE) &&
            vgaX <= (coordX + HALF_SIZE) &&
            vgaY >= (coordY - HALF_SIZE) &&
            vgaY <= (coordY + HALF_SIZE)) begin
            vgaColor <= currentColor;
        end
        else vgaColor <= BLACK;
    end

    //Sync Logic
    always_ff @(posedge CLK25 or negedge reset_n) begin
        if (~reset_n) begin
            coordX <= VGA_MIDDLE_X;
            coordY <= VGA_MIDDLE_Y;
            movingLeft <= 0;
            movingUp <= 0;
            clockCounter <= 0;
        end
        else begin
            if (clockCounter == CLOCK_END) begin
                clockCounter <= 0;

                //X-Movement
                if (movingLeft) begin
                    if (coordX > HALF_SIZE) begin
                        coordX <= coordX - 1;
                    end else begin
                        movingLeft <= 0;
                        currentColorIndex <= currentColorIndex + 1;
                    end
                end else begin
                    if (coordX < (VGA_WIDTH - HALF_SIZE)) begin
                        coordX <= coordX + 1;
                    end else begin
                        movingLeft <= 1;
                        currentColorIndex <= currentColorIndex + 1;
                    end
                end

                //Y-Movement
                if (movingUp) begin
                    if (coordY > HALF_SIZE) begin
                        coordY <= coordY - 1;
                    end else begin
                        movingUp <= 0;
                        currentColorIndex <= currentColorIndex + 1;
                    end
                end else begin
                    if (coordY < (VGA_HEIGHT - HALF_SIZE)) begin
                        coordY <= coordY + 1;
                    end else begin
                        movingUp <= 1;
                        currentColorIndex <= currentColorIndex + 1;
                    end
                end
            end
            else clockCounter <= clockCounter + 1;
        end
    end
endmodule