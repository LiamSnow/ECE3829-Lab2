`timescale 1ns / 1ps

module Debouncer(
    input wire CLK25,
    input wire reset_n,
    input wire in,
    output reg out
);
    parameter DEBOUNCE_INTERVAL = 100000; //# clocks to wait for debounce
    reg [19:0] counter;

    reg state = 0;

    always @(posedge CLK25 or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 0;
            state <= 0;
            out <= 0;
        end
        
        else begin
            //state is the same
            if (in == state) begin
                //almost stable
                if (counter < DEBOUNCE_INTERVAL) begin
                    counter <= counter + 1;
                end
                
                //is stable
                else begin
                    out <= state;
                end
            end
            
            //state changed
            else begin
                counter <= 0;
                state <= in;
            end
        end
    end
endmodule