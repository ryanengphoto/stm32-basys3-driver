`timescale 1ns / 1ps
`include "common_tasks.svh"

module tb_alu_block;

    // -------------------------
    // TB pass/fail signals
    // -------------------------
    static int checked, errors;
    logic [31:0] expected, rx_word;

    // -------------------------
    // UUT signals
    // -------------------------
    logic clk, rst;
    logic tx, rx;
    logic tick16;   // 16× baud tick from DUT for sync

    // -------------------------
    // System clock: 100 MHz => 10 ns period
    // -------------------------
    real sys_clk_period = 1e9 / 100_000_000.0;
    initial clk = 0;
    always #(sys_clk_period/2) clk = ~clk;

    // -------------------------
    // Instantiate ALU block
    // -------------------------
    alu_block #(
        .CLK_FRQ(100_000_000),
        .BPS(115200)
    ) UUT_alu_block (
        .clk(clk),
        .rst(rst),
        .tx(rx),   // DUT TX feeds TB RX
        .rx(tx)    // TB drives DUT RX
    );

    // Grab tick16 from DUT
    assign tick16 = UUT_alu_block.u_baud16.tick16;

    // -------------------------
    // Reset task
    // -------------------------
    task automatic pulse_reset();
        begin
            rst = 1'b1;
            repeat(20) @(posedge clk);
            rst = 1'b0;
            repeat(20) @(posedge clk);
        end
    endtask

    // -------------------------
    // Send a byte over UART (16× oversampling)
    // -------------------------
    task automatic send_byte(input logic [7:0] data);
        int i, j;
        begin
            // Start bit
            tx = 1'b0;
            for (j = 0; j < 16; j++) @(posedge tick16);

            // Data bits (LSB first)
            for (i = 0; i < 8; i++) begin
                tx = data[i];
                for (j = 0; j < 16; j++) @(posedge tick16);
            end

            // Stop bit
            tx = 1'b1;
            for (j = 0; j < 16; j++) @(posedge tick16);
        end
    endtask

    // -------------------------
    // Receive a byte (16× oversampling)
    // -------------------------
    task automatic recv_byte(output logic [7:0] data);
        int i, j;
        begin
            // Wait for start bit
            @(negedge rx);

            // Wait 8 ticks to align to middle of first data bit
            for (j = 0; j < 8; j++) @(posedge tick16);

            // Sample data bits
            for (i = 0; i < 8; i++) begin
                data[i] = rx;
                for (j = 0; j < 16; j++) @(posedge tick16);
            end

            // Stop bit: wait 16 ticks (ignore value)
            for (j = 0; j < 16; j++) @(posedge tick16);
        end
    endtask

    // -------------------------
    // Receive a 32-bit word from DUT
    // -------------------------
    task automatic recv_word(output logic [31:0] word);
        logic [7:0] b0, b1, b2, b3;
        begin
            recv_byte(b0);
            recv_byte(b1);
            recv_byte(b2);
            recv_byte(b3);

            word = {b3, b2, b1, b0}; // LSB-first
            $display("[%0t] Received 32-bit word = 0x%08h (%b)", $time, word, word);
        end
    endtask

    // -------------------------
    // Send a 4-byte packet: example ADD operation
    // -------------------------
    task automatic test_add_uart();
        logic [7:0] byte_1 = 8'b00010010;
        logic [7:0] byte_2 = 8'b00000000;
        logic [7:0] byte_3 = 8'b00000100;
        logic [7:0] byte_4 = 8'b00000000;
        begin
            $display("[%0t] Sending 4-byte UART packet...", $time);

            send_byte(byte_1);
            send_byte(byte_2);
            send_byte(byte_3);
            send_byte(byte_4);

            $display("[%0t] UART packet sent. Waiting for 32-bit response...", $time);

            recv_word(rx_word);

            // Example check
            expected = 32'd2;
            if (rx_word !== expected) begin
                $display("[%0t] Mismatch! Expected 0x%08h, got 0x%08h", $time, expected, rx_word);
                errors++;
            end else begin
                $display("[%0t] Correct result: %0d", $time, rx_word);
                checked++;
            end
        end
    endtask

    // -------------------------
    // Main testbench
    // -------------------------
    initial begin
        $dumpfile("alu_block_tb.vcd");
        $dumpvars(0, tb_alu_block);

        checked = 0;
        errors = 0;
        tx = 1;

        pulse_reset();

        test_add_uart();

        $display("Checked: %d | Errors: %d", checked, errors);
        if (errors) display_fail();
        else display_pass();

        $finish;
    end

endmodule
