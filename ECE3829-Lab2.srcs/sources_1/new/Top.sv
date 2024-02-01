`timescale 1ns / 1ps

module Top(
    input wire CLK100,
    input wire buttonUp, buttonCenter,
    input wire [1:0] switches,
    output wire [15:0] leds,
    output wire [6:0] sevenSegmentSegments,
    output wire sevenSegmentDecimal,
    output wire [3:0] sevenSegmentAnodes,
    output wire [3:0] vgaRed, vgaBlue, vgaGreen,
    output wire vgaHsync, vgaVsync
    );

    wire CLK25, reset_n;
    clk_wiz_0 clk_wiz_0(
        .clk_in1(CLK100),
        .clk_out1(CLK25),
        .locked(reset_n)
    );

    wire [3:0] [3:0] digitValues = '{4'd9, 4'd8, 4'd8, 4'd7};
    SevenSegmentDisplay SevenSegmentDisplay(
        .CLK25(CLK25),
        .reset_n(reset_n),
        .digitValues(digitValues),
        .segments(sevenSegmentSegments),
        .decimal(sevenSegmentDecimal),
        .anodes(sevenSegmentAnodes)
    );

    wire vgaBlank;
    wire [10:0] vgaX, vgaY;
    VGASync VGASync(
        .CLK25(CLK25),
        .reset_n(reset_n),
        .hsync(vgaHsync),
        .vsync(vgaVsync),
        .blank(vgaBlank),
        .x(vgaX),
        .y(vgaY)
    );

    wire [1:0] displayState;
    Debouncer Switch1Debouncer(CLK25, reset_n, switches[0], displayState[0]);
    Debouncer Switch2Debouncer(CLK25, reset_n, switches[1], displayState[1]);
    assign leds[1:0] = displayState;

    wire displayBlockEnabled, displayBlockBoost;
    Debouncer Button1Debouncer(CLK25, reset_n, buttonCenter, displayBlockEnabled);
    Debouncer Button2Debouncer(CLK25, reset_n, buttonUp, displayBlockBoost);
    assign leds[3:2] = {displayBlockBoost, displayBlockEnabled};

    Display Display(
        .CLK25(CLK25),
        .reset_n(reset_n),
        .state(displayState),
        .blockEnabled(displayBlockEnabled),
        .blockBoost(displayBlockBoost),
        .vgaColor({vgaRed, vgaGreen, vgaBlue}),
        .vgaBlank(vgaBlank),
        .vgaX(vgaX),
        .vgaY(vgaY)
    );
endmodule