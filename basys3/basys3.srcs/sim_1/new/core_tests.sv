`timescale 1ns / 1ps

task automatic test_and();
    begin
        $display("\nStarting AND test");
        // inputs
        @(posedge clk);
        data_ready = 0; // pull low before changing in_a and in_b
        alu_sel = 4'b0000;
        in_a = 14'b00000000000010;
        in_b = 14'b00000000000010;
        @(posedge clk);
        data_ready = 1; // pull high after changing in_a and in_b
        
        @(posedge data_valid);
        
        expected = in_a & in_b;
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @ (posedge clk);
    end
endtask 

task automatic test_or();
    begin
        $display("\nStarting OR test");
        // inputs
        @(posedge clk);
        data_ready = 0; // pull low before changing in_a and in_b
        alu_sel = 4'b0001;
        in_a = 14'b00000000011010;
        in_b = 14'b00000000000010;
        @(posedge clk);
        data_ready = 1; // pull high after changing in_a and in_b
        
        @(posedge data_valid);
        
        expected = in_a | in_b;
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @ (posedge clk);
    end
endtask 

task automatic test_add();
    begin
        $display("\nStarting ADD test");
        // inputs
        @(posedge clk);
        data_ready = 0; // pull low before changing in_a and in_b
        alu_sel = 4'b0010;
        in_a = 14'b00000000000010;
        in_b = 14'b00000000000010;
        @(posedge clk);
        data_ready = 1; // pull high after changing in_a and in_b
        
        @(posedge data_valid);
        
        expected = in_a + in_b;
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @ (posedge clk);
    end
endtask 

task automatic test_xor();
    begin
        $display("\nStarting XOR test");
        // inputs
        @(posedge clk);
        data_ready = 0; // pull low before changing in_a and in_b
        alu_sel = 4'b0011;
        in_a = 14'b00000000011010;
        in_b = 14'b00000000000010;
        @(posedge clk);
        data_ready = 1; // pull high after changing in_a and in_b
        
        @(posedge data_valid);
        
        expected = in_a ^ in_b;
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @ (posedge clk);
    end
endtask 



task automatic test_sll();
    begin
        $display("\nStarting SLL test");
        // inputs
        @(posedge clk);
        data_ready = 0; // pull low before changing in_a and in_b
        alu_sel = 4'b0100;
        in_a = 14'b00000000011010;
        in_b = 14'b00000000000010;
        @(posedge clk);
        data_ready = 1; // pull high after changing in_a and in_b
        
        @(posedge data_valid);
        
        expected = in_a << (in_b & 5'h1F);
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @ (posedge clk);
    end
endtask 

task automatic test_srl();
    begin
        $display("\nStarting SRL test");
        // inputs
        @(posedge clk);
        data_ready = 0; // pull low before changing in_a and in_b
        alu_sel = 4'b0101;
        in_a = 14'b00000000011010;
        in_b = 14'b00000000000010;
        @(posedge clk);
        data_ready = 1; // pull high after changing in_a and in_b
        
        @(posedge data_valid);
        
        expected = in_a >> (in_b & 5'h1F);
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @ (posedge clk);
    end
endtask 

task automatic test_sub();
    begin
        $display("\nStarting SUB test");
        @(posedge clk);
        data_ready = 0;
        alu_sel = 4'b0110;
        in_a = 14'b00000000101010; // 42
        in_b = 14'b00000000000101; // 5
        @(posedge clk);
        data_ready = 1;
        
        @(posedge data_valid);
        
        expected = in_a - in_b;
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @(posedge clk);
    end
endtask


task automatic test_sra();
    begin
        $display("\nStarting SRA test");
        @(posedge clk);
        data_ready = 0;
        alu_sel = 4'b0111;
        in_a = 14'b11111111100000; // negative value if signed
        in_b = 14'b00000000000010;
        @(posedge clk);
        data_ready = 1;
        
        @(posedge data_valid);
        
        expected = $signed(in_a) >>> (in_b & 5'h1F);
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @(posedge clk);
    end
endtask


task automatic test_slt();
    begin
        $display("\nStarting SLT (signed) test");
        @(posedge clk);
        data_ready = 0;
        alu_sel = 4'b1000;
        in_a = 14'b11111111100000; // negative number
        in_b = 14'b00000000001000; // positive number
        @(posedge clk);
        data_ready = 1;
        
        @(posedge data_valid);
        
        expected = ($signed(in_a) < $signed(in_b)) ? 32'b1 : 32'b0;
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @(posedge clk);
    end
endtask


task automatic test_sltu();
    begin
        $display("\nStarting SLTU (unsigned) test");
        @(posedge clk);
        data_ready = 0;
        alu_sel = 4'b1001;
        in_a = 14'b11111111100000; // large unsigned
        in_b = 14'b00000000001000; // smaller unsigned
        @(posedge clk);
        data_ready = 1;
        
        @(posedge data_valid);
        
        expected = ({18'b0, in_a} < {18'b0, in_b}) ? 32'b1 : 32'b0;
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @(posedge clk);
    end
endtask


task automatic test_nor();
    begin
        $display("\nStarting NOR test");
        @(posedge clk);
        data_ready = 0;
        alu_sel = 4'b1010;
        in_a = 14'b00000000011010;
        in_b = 14'b00000000000010;
        @(posedge clk);
        data_ready = 1;
        
        @(posedge data_valid);
        
        expected = ~({18'b0, in_a} | {18'b0, in_b});
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @(posedge clk);
    end
endtask


task automatic test_inc();
    begin
        $display("\nStarting INC test");
        @(posedge clk);
        data_ready = 0;
        alu_sel = 4'b1011;
        in_a = 14'b00000000000111;
        in_b = 14'b00000000000000;
        @(posedge clk);
        data_ready = 1;
        
        @(posedge data_valid);
        
        expected = in_a + 1;
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @(posedge clk);
    end
endtask


task automatic test_dec();
    begin
        $display("\nStarting DEC test");
        @(posedge clk);
        data_ready = 0;
        alu_sel = 4'b1100;
        in_a = 14'b00000000001000;
        in_b = 14'b00000000000000;
        @(posedge clk);
        data_ready = 1;
        
        @(posedge data_valid);
        
        expected = in_a - 1;
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @(posedge clk);
    end
endtask


task automatic test_rol();
    begin
        $display("\nStarting ROL test");
        @(posedge clk);
        data_ready = 0;
        alu_sel = 4'b1101;
        in_a = 14'b00000000011010;
        in_b = 14'b00000000000010;
        @(posedge clk);
        data_ready = 1;
        
        @(posedge data_valid);
        
        expected = ({18'b0, in_a} << (in_b & 5'h1F)) | ({18'b0, in_a} >> (32 - (in_b & 5'h1F)));
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @(posedge clk);
    end
endtask


task automatic test_ror();
    begin
        $display("\nStarting ROR test");
        @(posedge clk);
        data_ready = 0;
        alu_sel = 4'b1110;
        in_a = 14'b00000000011010;
        in_b = 14'b00000000000010;
        @(posedge clk);
        data_ready = 1;
        
        @(posedge data_valid);
        
        expected = ({18'b0, in_a} >> (in_b & 5'h1F)) | ({18'b0, in_a} << (32 - (in_b & 5'h1F)));
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @(posedge clk);
    end
endtask


task automatic test_nop();
    begin
        $display("\nStarting NOP test");
        @(posedge clk);
        data_ready = 0;
        alu_sel = 4'b1111;
        in_a = 14'b11111111111111;
        in_b = 14'b00000000000000;
        @(posedge clk);
        data_ready = 1;
        
        @(posedge data_valid);
        
        expected = 0;
        if (expected != out) errors++;
        checked++;
        $display("Expected: %d | Actual: %d", expected, out);
        
        @(posedge clk);
    end
endtask
