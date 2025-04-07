module tb_alu_control;

    // Testbench signals
    reg clk;                          // Clock signal
    reg reset;                        // Reset signal
    reg [1:0] ALUOp;                  // ALU operation control (2 bits)
    reg [31:0] instr;                 // Instruction (32 bits)
    wire [4:0] ALUControl;            // ALU operation output (5 bits)

    // Instantiate the ALU control module
    alu_control uut (
        .clk(clk),
        .reset(reset),
        .ALUOp(ALUOp),
        .instr(instr),
        .ALUControl(ALUControl)
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
        ALUOp = 2'b00;
        instr = 32'b0;

        // Apply reset
        reset = 1;
        #10;
        reset = 0;
        #10;

        // Test 1: ALUOp = 00 (Add / Base) with ADD instruction (funct3 = 000, funct7_bit = 0)
        ALUOp = 2'b00;
        instr = 32'b00000000000000000000000000000000;  // ADD instruction (funct3 = 000, funct7 = 0)
        #10;
        if (ALUControl !== 5'b00000) begin
            $display("Test 1 failed: Expected 5'b00000 (ADD), got %b", ALUControl);
        end else begin
            $display("Test 1 passed: ALUControl = %b (ADD)", ALUControl);
        end

        // Test 2: ALUOp = 00 (Add / Base) with SUB instruction (funct3 = 000, funct7_bit = 1)
        instr = 32'b01000000000000000000000000000000;  // SUB instruction (funct3 = 000, funct7 = 1)
        #10;
        if (ALUControl !== 5'b00001) begin
            $display("Test 2 failed: Expected 5'b00001 (SUB), got %b", ALUControl);
        end else begin
            $display("Test 2 passed: ALUControl = %b (SUB)", ALUControl);
        end

        // Test 3: ALUOp = 01 (Branch Compare) with BEQ (funct3 = 000)
        ALUOp = 2'b01;
        instr = 32'b00000000000000000000000000000000;  // BEQ instruction (funct3 = 000)
        #10;
        if (ALUControl !== 5'b00001) begin
            $display("Test 3 failed: Expected 5'b00001 (BEQ), got %b", ALUControl);
        end else begin
            $display("Test 3 passed: ALUControl = %b (BEQ)", ALUControl);
        end

        // Test 4: ALUOp = 10 (R-type) with SLT instruction (funct3 = 010, funct7 = 0)
        ALUOp = 2'b10;
        instr = 32'h00532633; // slt x12, x6, x5  // SLT instruction (funct3 = 010, funct7 = 0)
        #10;
        if (ALUControl !== 5'b10000) begin
            $display("Test 4 failed: Expected 5'b10000 (SLT), got %b", ALUControl);
        end else begin
            $display("Test 4 passed: ALUControl = %b (SLT)", ALUControl);
        end

        // Test 5: ALUOp = 10 (R-type) with XOR instruction (funct3 = 100, funct7 = 0)
        instr = 32'h00534433; // xor x8, x6, x5  // XOR instruction (funct3 = 100)
        #10;
        if (ALUControl !== 5'b01010) begin
            $display("Test 5 failed: Expected 5'b01010 (XOR), got %b", ALUControl);
        end else begin
            $display("Test 5 passed: ALUControl = %b (XOR)", ALUControl);
        end

        // Test 6: ALUOp = 10 (R-type) with SRL (funct3 = 101, funct7 = 0)
        instr = 32'h00935533;  // SRL instruction (funct3 = 101, funct7 = 0)
        #10;
        if (ALUControl !== 5'b01110) begin
            $display("Test 6 failed: Expected 5'b01110 (SRL), got %b", ALUControl);
        end else begin
            $display("Test 6 passed: ALUControl = %b (SRL)", ALUControl);
        end

        // Test 7: ALUOp = 10 (R-type) with SRA (funct3 = 101, funct7 = 1)
        instr =  32'h40935533;  // SRA instruction (funct3 = 101, funct7 = 1)
        #10;
        if (ALUControl !== 5'b01111) begin
            $display("Test 7 failed: Expected 5'b01111 (SRA), got %b", ALUControl);
        end else begin
            $display("Test 7 passed: ALUControl = %b (SRA)", ALUControl);
        end

        // Test 8: ALUOp = 01 (Branch Compare) with BNE (funct3 = 001)
        ALUOp = 2'b01;
        instr = 32'b00000000010000010001000001100011;  // BNE instruction (funct3 = 001)
        #10;
        if (ALUControl !== 5'b00001) begin
            $display("Test 8 failed: Expected 5'b00001 (BNE), got %b", ALUControl);
        end else begin
            $display("Test 8 passed: ALUControl = %b (BNE)", ALUControl);
        end

        // Finish the simulation
        $finish;
    end

endmodule
