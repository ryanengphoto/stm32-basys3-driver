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
    task automatic send_byte(input logic [7:0] data, input logic is_last = 0);
        int i, j;
        tx = 1'b0;
        for (j = 0; j < 16; j++) @(posedge tick16); // start bit
        for (i = 0; i < 8; i++) begin
            tx = data[i];
            for (j = 0; j < 16; j++) @(posedge tick16);
        end
        tx = 1'b1; // stop bit
        if (is_last) @(posedge tick16);
        else for (j = 0; j < 16; j++) @(posedge tick16);
    endtask

    // -------------------------
    // Receive a byte (16× oversampling)
    // -------------------------
    task automatic recv_byte(output logic [7:0] data);
        int i,j;
        @(negedge rx); // wait start
        repeat(8) @(posedge tick16); // middle of start
        for (i = 0; i < 8; i++) begin
            repeat(16) @(posedge tick16);
            data[i] = rx;
            //$display("[%0t] Received bit %0d: %b", $time, i, data[i]);
        end
        repeat(16) @(posedge tick16); // stop
    endtask

    // -------------------------
    // Receive a 32-bit word from DUT
    // -------------------------
    task automatic recv_word(output logic [31:0] word);
        logic [7:0] b0, b1, b2, b3;
        recv_byte(b0);
        recv_byte(b1);
        recv_byte(b2);
        recv_byte(b3);
        word = {b3,b2,b1,b0}; // LSB first
        $display("[%0t] Received 32-bit word = 0x%08h (%b)", $time, word, word);
    endtask

    // -------------------------
    // Send a 4-byte packet
    // -------------------------
    task automatic send_alu_packet(input logic [3:0] sel, input logic [13:0] a, input logic [13:0] b);
        logic [31:0] word;
        logic [7:0] byte0, byte1, byte2, byte3;
        begin
            // pack: [31:28] unused | [27:24] sel | [23:10] a | [9:0] b ?
            word = {a, b, sel}; // adjust packing if needed
            byte0 = word[7:0];
            byte1 = word[15:8];
            byte2 = word[23:16];
            byte3 = word[31:24];
            send_byte(byte0);
            send_byte(byte1);
            send_byte(byte2);
            send_byte(byte3,1);
        end
    endtask

    // -------------------------
    // Test ALU operation
    // -------------------------
    task automatic test_alu(input logic [3:0] sel, input logic [13:0] a, input logic [13:0] b, input logic [31:0] exp);
        begin
            $display("[%0t] Testing ALU sel=%0h, a=%0d, b=%0d ...", $time, sel, a, b);
            send_alu_packet(sel,a,b);
            recv_word(rx_word);
            expected = exp;
            if(rx_word !== expected) begin
                $display("[%0t] FAIL: got 0x%08h, expected 0x%08h", $time, rx_word, expected);
                errors++;
            end else begin
                $display("[%0t] PASS", $time);
                checked++;
            end
        end
    endtask

    // -------------------------
    // Main testbench
    // -------------------------
    initial begin
        $dumpfile("alu_block_tb.vcd");
        $dumpvars(0,tb_alu_block);
        checked = 0; errors = 0; tx=1;
        pulse_reset();

        // ADD
        test_alu(4'h2, 14'd2, 14'd3, 32'd5);
        // SUB
        test_alu(4'h6, 14'd5, 14'd3, 32'd2);
        // AND
        test_alu(4'h0, 14'd7, 14'd3, 32'd3);
        // OR
        test_alu(4'h1, 14'd2, 14'd4, 32'd6);
        // XOR
        test_alu(4'h3, 14'd6, 14'd3, 32'd5);
        // SLL
        test_alu(4'h4, 14'd1, 14'd2, 32'd4);
        // SRL
        test_alu(4'h5, 14'd8, 14'd2, 32'd2);
        // SLT
        test_alu(4'h8, 14'd3, 14'd5, 32'd1);
        test_alu(4'h8, 14'd5, 14'd3, 32'd0);
        // SLTU
        test_alu(4'h9, 14'd3, 14'd5, 32'd1);
        test_alu(4'h9, 14'd5, 14'd3, 32'd0);
        // ROL
        test_alu(4'hD, 14'd1, 14'd1, 32'd2);
        // ROR
        test_alu(4'hE, 14'd2, 14'd1, 32'd1);
        
        $display("Tests completed. Checked: %0d, Errors: %0d", checked, errors);

        if (errors) begin
            display_fail();
        end
        else begin
            display_pass();
        end

        $finish;
    end

endmodule
