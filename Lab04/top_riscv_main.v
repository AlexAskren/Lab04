// Top-level Single Cycle RISC-V Processor with debug outputs

module top_single_cycle_riscv(
    input wire clk,
    input wire reset,

    // Debug outputs to prevent Vivado from optimizing away logic
    output wire [31:0] debug_PC,
    output wire [31:0] debug_Instruction,
    output wire [31:0] debug_ALU_result,
    output wire [31:0] debug_DataMemOut
);

    // Wires between modules
    wire [31:0] PC, PCTarget;
    wire [31:0] Instr;

    wire [4:0] rs1, rs2, rd;
    wire [31:0] imm;
    wire [31:0] RD1, RD2;
    wire [31:0] ALU_result;

    wire [4:0] ALU_ctrl;
    wire [1:0] ALUOp;

    wire MemRead, MemWrite, RegWrite, ALUSrc, Branch, MemtoReg;
    wire [31:0] DataMemOut;
    wire Zero;

    // Debug assignments
    assign debug_PC           = PC;
    assign debug_Instruction  = Instr;
    assign debug_ALU_result   = ALU_result;
    assign debug_DataMemOut   = DataMemOut;

    // PC logic
    reg [31:0] PC_reg;
    assign PC = PC_reg;

    always @(posedge clk or posedge reset) begin
        if (reset)
            PC_reg <= 32'b0;
        else
            PC_reg <= PCTarget;
    end

    // Instruction Memory
    instr_mem Instruction_Memory (
        .clk(clk),
        .reset(reset),
        .addr(PC),
        .instr(Instr)
    );

    // Instruction Decode
    riscv_Inst_Decode ID (
        .clk(clk),
        .reset(reset),
        .Instr(Instr),
        .src_reg_addr0(rs1),
        .src_reg_addr1(rs2),
        .dst_reg_addr(rd),
        .immediate_value(imm),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Branch(Branch),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp)
    );

    // Register File
    register_file RF (
        .clk(clk),
        .rst(reset),
        .WE3(RegWrite),
        .WD3(MemtoReg ? DataMemOut : ALU_result),
        .A1(rs1),
        .A2(rs2),
        .A3(rd),
        .RD1(RD1),
        .RD2(RD2)
    );

    // ALU Control
    alu_control ALU_Control_Block (
        .clk(clk),
        .reset(reset),
        .ALUOp(ALUOp),
        .instr(Instr),
        .ALUControl(ALU_ctrl)
    );

    // ALU
    riscv_ALU ALU (
        .clk(clk),
        .reset(reset),
        .ALU_ctrl(ALU_ctrl),
        .ALU_ina(RD1),
        .ALU_inb_reg(RD2),
        .ALU_inb_imm(imm),
        .ALUSrc(ALUSrc),
        .ALU_out(ALU_result),
        .Zero_flag(Zero),
        .Negative_flag(),
        .Carry_flag(),
        .Overflow_flag()
    );

    // Data Memory
    mem_data DataMem (
        .clk(clk),
        .reset(reset),
        .wr_en(MemWrite),
        .rd_en(MemRead),
        .addr(ALU_result),
        .din(RD2),
        .dout(DataMemOut)
    );

    // Branch Control
    branch_control BranchUnit (
        .clk(clk),
        .reset(reset),
        .offset(imm),
        .PC(PC),
        .zero(Zero),
        .branch(Branch),
        .target(PCTarget)
    );

endmodule
