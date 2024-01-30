`timescale 1ns / 1ps

module VGASync(
    input wire CLK25, reset_n,
    output reg hsync, vsync,
    output reg x, y
);

    always_ff @(CLK25) begin
        
    end


endmodule

