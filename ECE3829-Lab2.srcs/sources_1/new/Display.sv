`timescale 1ns / 1ps

module Display(
    input wire CLK25, reset_n,
    output wire [3:0] red, blue, green,
    input wire x, y
);

    /*
    0 -> 0
    640 -> 15
    */

    assign red = x << 5;
    assign blue = y << 5;


endmodule

