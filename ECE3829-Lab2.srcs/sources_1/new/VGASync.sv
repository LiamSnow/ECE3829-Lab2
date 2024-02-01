`timescale 1ns / 1ps

module VGASync(
    input wire CLK25, reset_n,
    output reg hsync, vsync,
    output reg [9:0] x, y
);

    //640x480 VGA Parameters
    localparam [9:0] HORI_AREA = 640;
    localparam [9:0] HORI_FRONT_PORCH = 18; //left
    localparam [9:0] HORI_SYNC_PULSE = 92;
    localparam [9:0] HORI_BACK_PORCH = 50; //right
    localparam [9:0] HORI_TOTAL_M1 = HORI_AREA + HORI_FRONT_PORCH + HORI_SYNC_PULSE + HORI_BACK_PORCH - 1;
    localparam [9:0] HORI_SYNC_START = HORI_AREA + HORI_FRONT_PORCH;
    localparam [9:0] HORI_SYNC_END = HORI_SYNC_START + HORI_SYNC_PULSE;

    localparam [9:0] VERT_AREA = 480;
    localparam [9:0] VERT_FRONT_PORCH = 10; //top
    localparam [9:0] VERT_SYNC_PULSE = 12;
    localparam [9:0] VERT_BACK_PORCH = 33; //bottom
    localparam [9:0] VERT_TOTAL_M1 = VERT_AREA + VERT_FRONT_PORCH + VERT_SYNC_PULSE + VERT_BACK_PORCH - 1;
    localparam [9:0] VERT_SYNC_START = VERT_AREA + VERT_FRONT_PORCH;
    localparam [9:0] VERT_SYNC_END = VERT_SYNC_START + VERT_SYNC_PULSE;
    
    assign hsync = ~(x >= HORI_SYNC_START && x < HORI_SYNC_END);
    assign vsync = ~(y >= VERT_SYNC_START && y < VERT_SYNC_END);

    always_ff @(posedge CLK25 or negedge reset_n) begin
        if (~reset_n) begin
            x <= 0;
            y <= 0;
        end
        else begin
            if (x < HORI_TOTAL_M1) begin
                x <= x + 1;
            end
            else begin
                x <= 0;
                if (y < VERT_TOTAL_M1) begin
                    y <= y + 1;
                end
                else begin
                    y <= 0;
                end
            end
        end
    end
endmodule