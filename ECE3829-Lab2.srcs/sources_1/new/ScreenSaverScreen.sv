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
    localparam [11:0] WHITE  = {4'hF, 4'hF, 4'hF};
    localparam [11:0] BLACK  = {4'h0, 4'h0, 4'h0};

    //VGA Color Logic
    always_ff @(posedge CLK25) begin
        vgaColor <= WHITE;
    end
endmodule