/*
Author: Ryan Eng 

This module contains the logic for the uart interface to the ALU
*/

`timescale 1ns / 1ps

typedef enum logic [1:0] {
    STATE_IDLE,
    STATE_START,
    STATE_PROCESSING,
    STATE_DONE
} uart_state_t;

typedef struct packed {
    logic [13:0] in_a;
    logic [13:0] in_b;
    logic [3:0]  alu_sel;
} alu_packet_t;


module alu_block #(
    parameter integer CLK_FRQ = 100_000_000,
    parameter integer BPS = 115_200
)
(
    input  logic clk,
    input  logic rst,
    input  logic rx,
    output logic tx
);
    // internal signals
    int packet_counter = 0; // bit packet_counterer to track packet
    int message_counter = 0;
    uart_state_t uart_state;
    alu_packet_t alu_packet;
    logic [31:0] packet_bits;


    // signals for alu instantiation
    logic [31:0] out;
    logic        data_ready, data_valid;

    assign alu_packet.in_a    = packet_bits[31:18];
    assign alu_packet.in_b    = packet_bits[17:4];
    assign alu_packet.alu_sel = packet_bits[3:0];

    alu_core u_alu_core (
        .clk(clk),                  // in
        .rst(rst),                  // in
        .alu_sel(alu_packet.alu_sel),          // in [3:0]
        .in_a(alu_packet.in_a),                // in [13:0]
        .in_b(alu_packet.in_b),                // in [13:0]
        .data_ready(data_ready),    // in
        .out(out),                  // out [31:0]
        .data_valid(data_valid)     // out 
    );

    // signals for baud tick generator
    logic baud_tick;       // full-bit tick
    logic half_baud_tick;  // half-bit tick for mid-bit sampling

    baud_rate_gen #(
        .BPS(BPS)
    ) u_baud_rate_gen (
        .Clk(clk),
        .Rst(rst),
        .Tick(baud_tick),          // full-bit tick
        .Half_Tick(half_baud_tick) // mid-bit tick
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            data_ready      <= 0;
            packet_counter  <= 0;
            message_counter <= 0;
            packet_bits     <= 0;
            uart_state      <= STATE_IDLE;
        end 
        else begin
            case (uart_state)

                STATE_IDLE: begin
                    data_ready <= 0;
                    if (rx == 0) begin // start bit
                        uart_state     <= STATE_START;
                        packet_counter <= 0;
                    end
                end

                STATE_START: begin
                    // wait 0.5 bit, then start sampling (not shown)
                    if (half_baud_tick) uart_state <= STATE_PROCESSING;
                end

                STATE_PROCESSING: begin
                    if (baud_tick) begin
                        // store current bit
                        packet_bits[(message_counter*8) + packet_counter] <= rx;
                        packet_counter <= packet_counter + 1;

                        if (packet_counter == 8) begin
                            message_counter <= message_counter + 1;
                            packet_counter  <= 0;

                            if (message_counter == 3) begin
                                uart_state <= STATE_DONE;
                            end else begin
                                uart_state <= STATE_IDLE; // wait for next byte
                            end
                        end
                    end
                end

                STATE_DONE: begin
                    if (rx == 1) begin // stop bit high
                        data_ready  <= 1;
                        uart_state  <= STATE_IDLE;
                        message_counter <= 0;
                    end
                end
            endcase
        end
    end



endmodule

