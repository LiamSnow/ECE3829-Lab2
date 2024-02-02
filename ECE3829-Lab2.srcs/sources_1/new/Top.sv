`timescale 1ns / 1ps

module Top(
    input wire CLK100,
    input wire buttonUp, buttonCenter,
    input wire [15:0] switches,
    output wire [15:0] leds,
    output wire [6:0] sevenSegmentSegments,
    output wire sevenSegmentDecimal,
    output wire [3:0] sevenSegmentAnodes,
    output wire [11:0] vgaColor,
    output wire vgaHsync, vgaVsync
    );

    //25MHz Clock Gen
    wire CLK25, reset_n;
    clk_wiz_0 clk_wiz_0(
        .clk_in1(CLK100),
        .clk_out1(CLK25),
        .locked(reset_n)
    );

    //SSD Driver
    wire [3:0] [3:0] digitValues = '{4'd9, 4'd8, 4'd8, 4'd7};
    SevenSegmentDisplay SevenSegmentDisplay(
        .CLK25(CLK25),
        .reset_n(reset_n),
        .digitValues(digitValues),
        .segments(sevenSegmentSegments),
        .decimal(sevenSegmentDecimal),
        .anodes(sevenSegmentAnodes)
    );

    //VGA Driver
    wire vgaBlank;
    wire [10:0] vgaX, vgaY;
    wire [11:0] vgaColorDisplay;
    VGADriver VGADriver(
        .CLK25(CLK25),
        .reset_n(reset_n),
        .hsync(vgaHsync),
        .vsync(vgaVsync),
        .blank(vgaBlank),
        .colorIn(vgaColorDisplay),
        .colorOut(vgaColor),
        .x(vgaX),
        .y(vgaY)
    );

    //Inputs
    wire screenSaverScreenSelected, movingBlockScreenSelected, movingBlockScreenBoost;
    wire [1:0] shapesScreenState;
    Debouncer Button1Debouncer(CLK25, reset_n, buttonCenter, movingBlockScreenSelected);
    Debouncer Button2Debouncer(CLK25, reset_n, buttonUp, movingBlockScreenBoost);
    Debouncer Switch1Debouncer(CLK25, reset_n, switches[0], shapesScreenState[0]);
    Debouncer Switch2Debouncer(CLK25, reset_n, switches[1], shapesScreenState[1]);
    Debouncer Switch15Debouncer(CLK25, reset_n, switches[15], screenSaverScreenSelected);

    //Screens
    wire [11:0] vgaColorScreens [2:0];
    assign vgaColorDisplay = screenSaverScreenSelected ? vgaColorScreens[2'd0] : 
        movingBlockScreenSelected ? vgaColorScreens[2'd1] : vgaColorScreens[2'd2];

    ScreenSaverScreen ScreenSaverScreen(CLK25, reset_n, vgaColorScreens[2'd0], vgaX, vgaY);
    MovingBlockScreen MovingBlockScreen(CLK25, reset_n, movingBlockScreenBoost, vgaColorScreens[2'd1], vgaX, vgaY);
    ShapesScreen ShapesScreen(shapesScreenState, vgaColorScreens[2'd2], vgaX, vgaY);
endmodule