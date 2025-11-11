`timescale 1ns / 1ps

module tb_alu_block;

    // tb pass/fail signals
    static int checked, errors;
    logic [31:0] expected;
    
    // UUT signals
    logic clk, rst, tx, rx;
    logic baud_tick;       // expose baud_tick from DUT for sync

    // System clock (fast, e.g., 50 MHz)
    real sys_clk_period = 1e9 / 50_000_000.0; // 50 MHz => 20 ns period
    always #(sys_clk_period/2) clk = ~clk;   // generate clk

    // Instantiate the ALU block
    alu_block #(
        .CLK_FRQ(50_000_000),
        .BPS(115200)
    ) UUT_alu_block(
        .clk(clk),
        .rst(rst),
        .tx(rx),
        .rx(tx)
    );

    // Extract baud_tick from DUT (for aligned simulation)
    // Note: assumes you expose baud_tick as public signal or add a debug wire
    assign baud_tick = UUT_alu_block.u_baud_rate_gen.Tick;

    // Reset task
    task automatic pulse_reset();
        begin
            rst = 1'b1;
            repeat (10000) @(posedge clk); // ensure proper initialization
            rst = 1'b0;
            repeat (10000) @(posedge clk);
        end
    endtask

    // Send a byte over UART (aligned to baud_tick)
    task automatic send_byte(input logic [7:0] data);
        int i;
        begin
            // Start bit
            tx = 1'b0;
            @(posedge baud_tick);

            // Data bits (LSB first)
            for (i = 0; i < 8; i++) begin
                tx = data[i];
                @(posedge baud_tick);
            end

            // Stop bit
            tx = 1'b1;
            @(posedge baud_tick);
        end
    endtask

    // Send 4-byte packet (example ADD operation)
    // add 1, 1
    task automatic test_add_uart();
        logic [7:0] byte_1 = 8'b00010010; // 0010 = add
        logic [7:0] byte_2 = 8'b00000000; // next 14 = 1, next 14 = 1
        logic [7:0] byte_3 = 8'b00000100;
        logic [7:0] byte_4 = 8'b00000000;
        begin
            send_byte(byte_1);
            send_byte(byte_2);
            send_byte(byte_3);
            send_byte(byte_4);

            $display("[%0t] UART packet sent.", $time);
        end
    endtask

    // Main test
    initial begin
        $dumpfile("alu_block_tb.vcd");
        $dumpvars(0, tb_alu_block);
        checked = 0;
        errors = 0;
        clk = 0;
        rst = 0;
        tx = 1;

        pulse_reset();

        test_add_uart();

        // wait for packet to be processed
        repeat (100) @(posedge clk);

        $finish;
    end

endmodule
