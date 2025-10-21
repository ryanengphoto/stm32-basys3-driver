// modified from https://electronoobs.com/eng_circuitos_tut26_2.php
/*
Author: Ryan Eng 

This module contains the logic for the baud rate tick generator for the UART interface
*/

module baud_rate_gen #(
    parameter integer BPS = 115_200
)(
    input  wire Clk,
    input  wire Rst,
    output wire Tick,          // 1-bit full period pulse
    output wire Half_Tick      // pulse at half-bit (for mid-bit sampling)
);

    reg [31:0] baudRateReg = 0; 
    reg tick_reg, half_tick_reg;

    assign Tick      = tick_reg;
    assign Half_Tick = half_tick_reg;

    localparam HALF_BPS = BPS / 2;

    always @(posedge Clk or posedge Rst) begin
        if (Rst) begin
            baudRateReg    <= 0;
            tick_reg       <= 0;
            half_tick_reg  <= 0;
        end else begin
            if (baudRateReg == BPS-1) begin
                baudRateReg   <= 0;
                tick_reg      <= 1;
                half_tick_reg <= 0;
            end
            else begin
                baudRateReg <= baudRateReg + 1;
                tick_reg    <= 0;

                if (baudRateReg == HALF_BPS-1)
                    half_tick_reg <= 1;
                else
                    half_tick_reg <= 0;
            end
        end
    end
endmodule

