`timescale 1ns / 1ps

module Debouncer(
    input wire CLK25,
    input wire reset_n,
    input wire in,
    output reg out
);
    parameter DEBOUNCE_INTERVAL = 250000; //10ms
    reg [19:0] counter;

    reg state = 0;

    always @(posedge CLK25 or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 0;
            state <= 0;
            out <= in;
        end
        else begin
            // State is the same
            if (in == state) begin
                // Almost stable
                if (counter < DEBOUNCE_INTERVAL) begin
                    counter <= counter + 1;
                end
                // Is stable
                else begin
                    out <= state;
                    counter <= 0; // Reset counter after reaching terminal count
                end
            end
            // State changed
            else begin
                counter <= 0;
                state <= in;
            end
        end
    end
endmodule