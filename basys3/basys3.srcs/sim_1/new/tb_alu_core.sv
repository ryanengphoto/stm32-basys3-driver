`timescale 1ns / 1ps
`include "common_tasks.svh"

module tb_alu_core(

    );
    
    // tb pass/fail signals
    static int checked, errors;
    logic [31:0] expected;
    
    // UUT signals
    logic clk, rst;
    logic [3:0] alu_sel;
    logic [13:0] in_a;
    logic [13:0] in_b;
    logic data_ready;
    logic [31:0] out;
    logic data_valid;
    
    // generate clock
    always #5 clk = ~clk; 
    
    // instantiate alu_core
    alu_core UUT_alu_core(
        .clk(clk),                  // in
        .rst(rst),                  // in
        .alu_sel(alu_sel),          // in [3:0]
        .in_a(in_a),                // in [13:0]
        .in_b(in_b),                // in [13:0]
        .data_ready(data_ready),    // in
        .out(out),                  // out [31:0]
        .data_valid(data_valid)     // out 
    );
    
    // reset task
    task automatic pulse_reset();
        begin
            rst = 1'b1;
            #20;
            rst = 1'b0;
        end
    endtask     
       
    // *****************************
    // Tests   
    // *****************************
    `include "core_tests.sv"  
       
   // START TESTING HERE
   //initiate signals
    initial begin
        checked = 0;
        errors = 0;
        clk = 0;
        rst = 0;
        pulse_reset();
        
        test_and();
        #20;
        test_or();
        #20;
        test_add();
        #20;
        test_xor();
        #20;
        test_sll();
        #20;
        test_srl();
        #20;
        test_sub();
        #20;
        test_sra();
        #20;
        test_slt();
        #20;
        test_sltu();
        #20;
        test_nor();
        #20;
        test_inc();
        #20;
        test_dec();
        #20;
        test_rol();
        #20;
        test_ror();
        #20;
        test_nop();
        #20;
        
        $display("Checked: %d | Errors: %d", checked, errors);
        if (errors) begin
            display_fail();
        end
        else begin
            display_pass();
        end
        
        $finish;
    end

endmodule
