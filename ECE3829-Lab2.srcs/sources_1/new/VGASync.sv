`timescale 1ns / 1ps

module VGASync(
    input wire CLK25, reset_n,
    output reg hsync, vsync,
    output reg x, y
);

    //640x480 VGA Parameters
    localparam HORI_AREA = 640;
    localparam HORI_FRONT_PORCH = 18; //left
    localparam HORI_SYNC_PULSE = 92;
    localparam HORI_BACK_PORCH = 50; //right
    localparam HORI_TOTAL_M1 = HORI_AREA + HORI_FRONT_PORCH + HORI_SYNC_PULSE + HORI_BACK_PORCH - 1;
    localparam HORI_SYNC_START = HORI_AREA + HORI_FRONT_PORCH;
    localparam HORI_SYNC_END = HORI_SYNC_START + HORI_SYNC_PULSE;

    localparam VERT_AREA = 480;
    localparam VERT_FRONT_PORCH = 10; //top
    localparam VERT_SYNC_PULSE = 12;
    localparam VERT_BACK_PORCH = 33; //bottom
    localparam VERT_TOTAL_M1 = VERT_AREA + VERT_FRONT_PORCH + VERT_SYNC_PULSE + VERT_BACK_PORCH - 1;
    localparam VERT_SYNC_START = VERT_AREA + VERT_FRONT_PORCH;
    localparam VERT_SYNC_END = VERT_SYNC_START + VERT_SYNC_PULSE;
    
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