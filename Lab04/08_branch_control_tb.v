module tb_branch_control;

    // Testbench signals
    reg clk;                          // Clock signal
    reg reset;                        // Reset signal
    reg [31:0] offset;                 // Branch offset
    reg [31:0] PC;                    // Current program counter
    reg zero;                          // Zero flag (from ALU comparison)
    reg branch;                        // Branch control signal
    wire [31:0] target;                // Target address for branch

    // Instantiate the branch control module
    branch_control #(
        .INSTR_WIDTH(32),               // Instruction width (32 bits)
        .OFFSET_LEN(32)                 // Offset length (32 bits)
    ) uut (
        .clk(clk),
        .reset(reset),
        .offset(offset),
        .PC(PC),
        .zero(zero),
        .branch(branch),
        .target(target)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // Toggle clock every 5 time units (period = 10)
    end

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;
        offset = 0;
        PC = 32'b0;
        zero = 0;
        branch = 0;

        // Apply reset
        reset = 1;
        #10;
        reset = 0;
        #10;

        // Test 1: Branch taken (zero = 1, branch = 1, offset = 4)
        offset = 32'b00000000000000000000000000000100; // Offset = 4
        PC = 32'h1000; // Current PC = 0x1000
        zero = 1;      // Zero flag is set (comparison result is true)
        branch = 1;    // Branch signal is asserted
        #10;
        if (target !== 32'h1004) begin
            $display("Test 1 failed: Expected 0x1004, got 0x%h", target);
        end else begin
            $display("Test 1 passed: Target = 0x%h", target);
        end

        // Test 2: Branch not taken (zero = 0, branch = 1, offset = 4)
        zero = 0;      // Zero flag is not set (comparison result is false)
        #10;
        if (target !== 32'h1004) begin
            $display("Test 2 failed: Expected 0x1004, got 0x%h", target);
        end else begin
            $display("Test 2 passed: Target = 0x%h", target);
        end

        // Test 3: Branch not taken (zero = 1, branch = 0, offset = 4)
        branch = 0;    // Branch signal is not asserted
        zero = 1;      // Zero flag is set (comparison result is true)
        #10;
        if (target !== 32'h1004) begin
            $display("Test 3 failed: Expected 0x1004, got 0x%h", target);
        end else begin
            $display("Test 3 passed: Target = 0x%h", target);
        end

        // Test 4: Branch taken (zero = 1, branch = 1, offset = -4)
        offset = 32'b11111111111111111111111111111100; // Offset = -4 (signed offset)
        PC = 32'h1000; // Current PC = 0x1000
        zero = 1;      // Zero flag is set (comparison result is true)
        branch = 1;    // Branch signal is asserted
        #10;
        if (target !== 32'h0ffc) begin
            $display("Test 4 failed: Expected 0x0ffc, got 0x%h", target);
            reset = 1;
        end else begin
            $display("Test 4 passed: Target = 0x%h", target);
        end

        // Test 5: Reset and check target address (should be 0)
        reset = 1;
        #50;
        reset = 0;
        #10;
        if (target !== 32'b0) begin
            $display("Test 5 failed: Expected 0x00000000, got 0x%h", target);
        end else begin
            $display("Test 5 passed: Target = 0x%h", target);
        end

        // Test 6: Check if target defaults to PC + 4 when branch is not taken
        branch = 0;
        offset = 32'b0;
        #10;
        if (target !== PC + 4) begin
            $display("Test 6 failed: Expected 0x%h, got 0x%h", PC + 4, target);
        end else begin
            $display("Test 6 passed: Target = 0x%h", target);
        end

        // Test 7: Negative offset for branch with zero flag
        offset = 32'b11111111111111111111111111111101; // Offset = -3 (signed offset)
        PC = 32'h2000; // Current PC = 0x2000
        zero = 1;      // Zero flag is set (comparison result is true)
        branch = 1;    // Branch signal is asserted
        #10;
        if (target !== 32'h1ffc) begin
            $display("Test 7 failed: Expected 0x1ffd, got 0x%h", target);
        end else begin
            $display("Test 7 passed: Target = 0x%h", target);
        end

        // Finish the simulation
        $finish;
    end

endmodule
