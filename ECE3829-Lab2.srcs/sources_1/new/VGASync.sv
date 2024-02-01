`timescale 1ns / 1ps

module VGASync(
    input wire CLK25, reset_n,
    output wire hsync, vsync, blank,
    output reg [10:0] x, y
    );

    localparam [10:0] HORI_MAX = 800;
    localparam [10:0] HORI_VISIBLE = 640;
    localparam [10:0] HORI_FRONT_PORCH_END = 648;
    localparam [10:0] HORI_SYNC_PULSE_END = 744;
    localparam [10:0] VERT_MAX = 525;
    localparam [10:0] VERT_VISIBLE = 480;
    localparam [10:0] VERT_FRONT_PORCH_END = 482;
    localparam [10:0] VERT_SYNC_PULSE_END = 484;

    assign vsync = ~(y >= VERT_FRONT_PORCH_END && y < VERT_SYNC_PULSE_END);
    assign hsync = ~(x >= HORI_FRONT_PORCH_END && x < HORI_SYNC_PULSE_END);
    assign blank = x >= HORI_VISIBLE || y >= VERT_VISIBLE;

    always_ff @(posedge CLK25 or negedge reset_n) begin
        if (~reset_n) begin
            x <= 0;
            y <= 0;
        end
        else begin
            if (x == HORI_MAX) begin
                x <= 0;
                if (y == VERT_MAX) begin
                    y <= 0;
                end
                else y <= y + 1;
            end
            else begin
                x <= x + 1;
            end
        end
    end
endmodule