`timescale 1ns / 1ps

module Top(
    input wire CLK100,
    input wire buttonUp, buttonRight, buttonDown, buttonLeft, buttonCenter,
    input wire [1:0] switches,
    output wire [6:0] sevenSegmentSegments,
    output wire sevenSegmentDecimal,
    output wire [3:0] sevenSegmentAnodes,
    output wire [3:0] vgaRed, vgaBlue, vgaGreen,
    output wire vgaHsync, vgaVsync
    );

    wire reset_n;

    wire CLK25;
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

    reg [9:0] vgaX, vgaY;
    VGASync VGASync(
        .CLK25(CLK25),
        .reset_n(reset_n),
        .hsync(vgaHsync),
        .vsync(vgaVsync),
        .x(vgaX),
        .y(vgaY)
    );

    wire [1:0] debouncedSwitches;
    Debouncer Switch1Debouncer(CLK25, reset_n, switches[0], debouncedSwitches[0]);
    Debouncer Switch2Debouncer(CLK25, reset_n, switches[1], debouncedSwitches[1]);

    wire combinedButton = buttonUp & buttonRight & buttonDown & buttonLeft & buttonCenter;
    wire debouncedButton;
    Debouncer ButtonDebouncer(CLK25, reset_n, combinedButton, debouncedButton);

    Display Display(
        .CLK25(CLK25),
        .reset_n(reset_n),
        .state(debouncedSwitches),
        .blockEnabled(debouncedButton),
        .vgaColor({vgaRed, vgaGreen, vgaBlue}),
        .vgaX(vgaX),
        .vgaY(vgaY)
    );

endmodule
