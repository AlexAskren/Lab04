`timescale 1ns / 1ps

module tb_riscv_ALU;

    parameter ALU_WIDTH = 32;
    parameter ALU_CTRL_WIDTH = 5;

    // Inputs
    reg clk;
    reg reset;
    reg [ALU_CTRL_WIDTH-1:0] ALU_ctrl;
    reg [ALU_WIDTH-1:0] ALU_ina;
    reg [ALU_WIDTH-1:0] ALU_inb_reg;
    reg [ALU_WIDTH-1:0] ALU_inb_imm;
    reg ALUSrc;

    // Outputs
    wire [ALU_WIDTH-1:0] ALU_out;
    wire Overflow_flag;
    wire Carry_flag;
    wire Negative_flag;
    wire Zero_flag;

    // Instantiate the ALU
    riscv_ALU #(
        .ALU_WIDTH(ALU_WIDTH),
        .ALU_CTRL_WIDTH(ALU_CTRL_WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .ALU_ctrl(ALU_ctrl),
        .ALU_ina(ALU_ina),
        .ALU_inb_reg(ALU_inb_reg),
        .ALU_inb_imm(ALU_inb_imm),
        .ALUSrc(ALUSrc),
        .ALU_out(ALU_out),
        .Overflow_flag(Overflow_flag),
        .Carry_flag(Carry_flag),
        .Negative_flag(Negative_flag),
        .Zero_flag(Zero_flag)
    );

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        $display("===== RISC-V ALU Testbench Start =====");
        clk = 0;
        reset = 0;

        // Format: task_run(ALU_ctrl, A, B_reg, B_imm, ALUSrc)
        task_run(5'b00000, 12, 8, 99, 0);  // ADD (reg)
        task_run(5'b00000, 12, 8, 99, 1);  // ADD (imm)
        task_run(5'b00001, 20, 8, 5, 0);   // SUB (reg)
        task_run(5'b00010, 4, 3, 7, 1);    // MUL (imm)
        task_run(5'b00011, -8, 2, 0, 0);   // MULH
        task_run(5'b00110, 50, 10, 0, 1);  // DIV
        task_run(5'b01000, 17, 3, 0, 1);   // REM
        task_run(5'b01010, 12'hF0, 12'h0F, 0, 0); // XOR
        task_run(5'b01011, 12'hF0, 12'h0F, 0, 0); // OR
        task_run(5'b01100, 12'hF0, 12'h0F, 0, 0); // AND
        task_run(5'b01101, 4, 3, 0, 1);    // SLL
        task_run(5'b01110, 32'hF0, 4, 0, 1); // SRL
        task_run(5'b01111, -16, 2, 0, 1);  // SRA
        task_run(5'b10000, -3, 5, 0, 0);   // SLT
        task_run(5'b10001, 2, 10, 0, 0);   // SLTU
        task_run(5'b10010, 12, 12, 0, 0);  // SEQ
        task_run(5'b10011, 12, 13, 0, 0);  // SNE

        $display("===== RISC-V ALU Testbench End =====");
        $finish;
    end

    // Helper task to run ALU op
    task task_run(
        input [4:0] ctrl,
        input [ALU_WIDTH-1:0] A,
        input [ALU_WIDTH-1:0] B_reg,
        input [ALU_WIDTH-1:0] B_imm,
        input ALUSrc_val
    );
    begin
        ALU_ctrl = ctrl;
        ALU_ina = A;
        ALU_inb_reg = B_reg;
        ALU_inb_imm = B_imm;
        ALUSrc = ALUSrc_val;
        #10;

        $display("ALU_ctrl=%b | A=%0d | B=%0d (%s) | OUT=%0d | Z=%b N=%b C=%b OF=%b",
            ctrl, A, (ALUSrc_val ? B_imm : B_reg), (ALUSrc_val ? "Imm" : "Reg"),
            ALU_out, Zero_flag, Negative_flag, Carry_flag, Overflow_flag);
    end
    endtask

endmodule
