module top_pipelined_riscv #(
    parameter DATA_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 5,
    parameter MEM_DEPTH = 2048
)(
    input wire clk,
    input wire reset
);

    // PC and instruction fetch
    reg [DATA_WIDTH-1:0] PC;
    wire [DATA_WIDTH-1:0] next_PC;
    wire [DATA_WIDTH-1:0] instr;

    // IF/ID pipeline registers
    reg [DATA_WIDTH-1:0] IF_ID_instr;
    reg [DATA_WIDTH-1:0] IF_ID_PC;
    reg IF_ID_branch_predict;

    // ID/EX pipeline registers
    reg [DATA_WIDTH-1:0] ID_EX_RD1, ID_EX_RD2, ID_EX_imm;
    reg [REG_ADDR_WIDTH-1:0] ID_EX_rs1, ID_EX_rs2, ID_EX_rd;
    reg [1:0] ID_EX_ALUOp;
    reg       ID_EX_ALUSrc, ID_EX_MemRead, ID_EX_MemWrite;
    reg       ID_EX_RegWrite, ID_EX_MemToReg;
    reg [2:0] ID_EX_funct3;
    reg       ID_EX_funct7_bit;
    reg       ID_EX_branch_predict;
    reg       ID_EX_Branch;

    // EX/MEM pipeline registers
    reg [DATA_WIDTH-1:0] EX_MEM_ALU_result, EX_MEM_RD2;
    reg [REG_ADDR_WIDTH-1:0] EX_MEM_rd;
    reg       EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_MemToReg;
    reg       EX_MEM_branch_taken, EX_MEM_Branch, EX_MEM_predicted_taken;

    // MEM/WB pipeline registers
    reg [DATA_WIDTH-1:0] MEM_WB_read_data, MEM_WB_ALU_result;
    reg [REG_ADDR_WIDTH-1:0] MEM_WB_rd;
    reg       MEM_WB_RegWrite, MEM_WB_MemToReg;

    wire RegWrite, MemRead, MemWrite, ALUSrc, Branch, MemToReg;
    wire [1:0] ALUOp;
    wire hazard_stall, PCWrite, IF_ID_Write;

    wire [6:0] opcode = IF_ID_instr[6:0];
    wire [REG_ADDR_WIDTH-1:0] rs1 = IF_ID_instr[19:15];
    wire [REG_ADDR_WIDTH-1:0] rs2 = IF_ID_instr[24:20];
    wire [REG_ADDR_WIDTH-1:0] rd  = IF_ID_instr[11:7];

    wire [DATA_WIDTH-1:0] imm_i = {{20{IF_ID_instr[31]}}, IF_ID_instr[31:20]};
    wire [DATA_WIDTH-1:0] imm_u = {IF_ID_instr[31:12], 12'b0};
    wire [DATA_WIDTH-1:0] imm_b = {{20{IF_ID_instr[31]}}, IF_ID_instr[7], IF_ID_instr[30:25], IF_ID_instr[11:8], 1'b0};

    wire [DATA_WIDTH-1:0] imm = (opcode == 7'b0110111 || opcode == 7'b0010111) ? imm_u :
                                (opcode == 7'b1100011) ? imm_b : imm_i;

    wire [1:0] ForwardA, ForwardB;
    wire branch_predict;
    wire flush_IF_ID, flush_ID_EX, flush_EX_MEM;

    forwarding_unit FU (
        .ID_EX_Rs1(ID_EX_rs1),
        .ID_EX_Rs2(ID_EX_rs2),
        .EX_MEM_Rd(EX_MEM_rd),
        .MEM_WB_Rd(MEM_WB_rd),
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    wire [DATA_WIDTH-1:0] ALU_input_A = (ForwardA == 2'b10) ? EX_MEM_ALU_result :
                                       (ForwardA == 2'b01) ? MEM_WB_ALU_result :
                                       ID_EX_RD1;

    wire [DATA_WIDTH-1:0] ALU_input_B_raw = (ForwardB == 2'b10) ? EX_MEM_ALU_result :
                                           (ForwardB == 2'b01) ? MEM_WB_ALU_result :
                                           ID_EX_RD2;

    wire [DATA_WIDTH-1:0] ALU_input_B = ID_EX_ALUSrc ? ID_EX_imm : ALU_input_B_raw;

    wire [4:0] ALU_ctrl;
    alu_control ALU_CTRL (
        .ALUOp(ID_EX_ALUOp),
        .funct3(ID_EX_funct3),
        .funct7_bit(ID_EX_funct7_bit),
        .ALUControl(ALU_ctrl)
    );

    wire [DATA_WIDTH-1:0] ALU_result;
    wire Zero_flag;
    riscv_ALU ALU (
        .clk(clk), .reset(reset),
        .ALU_ctrl(ALU_ctrl),
        .ALU_ina(ALU_input_A),
        .ALU_inb_reg(ALU_input_B),
        .ALU_inb_imm(ID_EX_imm),
        .ALUSrc(ID_EX_ALUSrc),
        .ALU_out(ALU_result),
        .Zero_flag(Zero_flag)
    );

    wire [DATA_WIDTH-1:0] DataMemOut;
    mem_data #(.MEM_DEPTH(MEM_DEPTH)) DMEM (
        .clk(clk), .reset(reset),
        .rd_en(EX_MEM_MemRead),
        .wr_en(EX_MEM_MemWrite),
        .addr(EX_MEM_ALU_result),
        .din(EX_MEM_RD2),
        .dout(DataMemOut)
    );

    instr_mem #(.MEM_DEPTH(MEM_DEPTH)) IMEM (
        .clk(clk), .reset(reset),
        .addr(PC), .instr(instr)
    );

    control_unit CU (
        .stall(hazard_stall),
        .opcode(opcode),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .Branch(Branch),
        .MemToReg(MemToReg),
        .ALUOp(ALUOp)
    );

    wire [DATA_WIDTH-1:0] RD1, RD2;
    register_file RF (
        .clk(clk), .rst(reset), .stall(hazard_stall),
        .A1(rs1), .A2(rs2), .A3(MEM_WB_rd),
        .WD3(MEM_WB_MemToReg ? MEM_WB_read_data : MEM_WB_ALU_result),
        .WE3(MEM_WB_RegWrite),
        .RD1(RD1), .RD2(RD2)
    );

    hazard_detection_unit HDU (
        .ID_EX_MemRead(ID_EX_MemRead),
        .ID_EX_Rd(ID_EX_rd),
        .IF_ID_Rs1(rs1),
        .IF_ID_Rs2(rs2),
        .stall(hazard_stall),
        .PCWrite(PCWrite),
        .IF_ID_Write(IF_ID_Write)
    );

    wire [DATA_WIDTH-1:0] branch_target = IF_ID_PC + imm;
    assign next_PC = branch_predict ? branch_target : (PC + 4);

    always @(posedge clk or posedge reset) begin
        if (reset)
            PC <= {DATA_WIDTH{1'b0}};
        else if (PCWrite)
            PC <= next_PC;
    end

    // IF/ID pipeline register update
    always @(posedge clk) begin
        if (reset || flush_IF_ID) begin
            IF_ID_instr <= {DATA_WIDTH{1'b0}};
            IF_ID_PC <= {DATA_WIDTH{1'b0}};
            IF_ID_branch_predict <= 1'b0;
        end else if (IF_ID_Write) begin
            IF_ID_instr <= instr;
            IF_ID_PC <= PC;
            IF_ID_branch_predict <= branch_predict;
        end
    end

    // ID/EX pipeline register update
    always @(posedge clk) begin
        if (reset || hazard_stall || flush_ID_EX) begin
            ID_EX_RD1 <= 0; ID_EX_RD2 <= 0; ID_EX_imm <= 0;
            ID_EX_rs1 <= 0; ID_EX_rs2 <= 0; ID_EX_rd <= 0;
            ID_EX_RegWrite <= 0; ID_EX_MemRead <= 0; ID_EX_MemWrite <= 0;
            ID_EX_ALUSrc <= 0; ID_EX_ALUOp <= 0; ID_EX_MemToReg <= 0;
            ID_EX_funct3 <= 0; ID_EX_funct7_bit <= 0;
            ID_EX_branch_predict <= 0; ID_EX_Branch <= 0;
        end else begin
            ID_EX_RD1 <= RD1; ID_EX_RD2 <= RD2; ID_EX_imm <= imm;
            ID_EX_rs1 <= rs1; ID_EX_rs2 <= rs2; ID_EX_rd <= rd;
            ID_EX_RegWrite <= RegWrite; ID_EX_MemRead <= MemRead;
            ID_EX_MemWrite <= MemWrite; ID_EX_ALUSrc <= ALUSrc;
            ID_EX_ALUOp <= ALUOp; ID_EX_MemToReg <= MemToReg;
            ID_EX_funct3 <= IF_ID_instr[14:12];
            ID_EX_funct7_bit <= IF_ID_instr[30];
            ID_EX_branch_predict <= IF_ID_branch_predict;
            ID_EX_Branch <= Branch;
        end
    end

    // EX/MEM pipeline register update
    always @(posedge clk) begin
        if (reset || flush_EX_MEM) begin
            EX_MEM_ALU_result <= 0; EX_MEM_RD2 <= 0; EX_MEM_rd <= 0;
            EX_MEM_RegWrite <= 0; EX_MEM_MemRead <= 0; EX_MEM_MemWrite <= 0;
            EX_MEM_MemToReg <= 0; EX_MEM_branch_taken <= 0;
            EX_MEM_Branch <= 0; EX_MEM_predicted_taken <= 0;
        end else begin
            EX_MEM_ALU_result <= ALU_result;
            EX_MEM_RD2 <= ALU_input_B_raw;
            EX_MEM_rd <= ID_EX_rd;
            EX_MEM_RegWrite <= ID_EX_RegWrite;
            EX_MEM_MemRead <= ID_EX_MemRead;
            EX_MEM_MemWrite <= ID_EX_MemWrite;
            EX_MEM_MemToReg <= ID_EX_MemToReg;
            EX_MEM_branch_taken <= ID_EX_Branch & Zero_flag;
            EX_MEM_Branch <= ID_EX_Branch;
            EX_MEM_predicted_taken <= ID_EX_branch_predict;
        end
    end

    // MEM/WB pipeline register update
    always @(posedge clk) begin
        if (reset || flush_EX_MEM) begin
            MEM_WB_read_data <= 0;
            MEM_WB_ALU_result <= 0;
            MEM_WB_rd <= 0;
            MEM_WB_RegWrite <= 0;
            MEM_WB_MemToReg <= 0;
        end else begin
            MEM_WB_read_data <= DataMemOut;
            MEM_WB_ALU_result <= EX_MEM_ALU_result;
            MEM_WB_rd <= EX_MEM_rd;
            MEM_WB_RegWrite <= EX_MEM_RegWrite;
            MEM_WB_MemToReg <= EX_MEM_MemToReg;
        end
    end

    branch_prediction_unit BPU (
        .clk(clk), .reset(reset),
        .branch_resolved(EX_MEM_Branch),
        .branch_taken_actual(EX_MEM_branch_taken),
        .branch_predict(branch_predict)
    );

    branch_control_flush BCF (
        .clk(clk), .reset(reset),
        .branch_taken(EX_MEM_branch_taken),
        .predicted_taken(EX_MEM_predicted_taken),
        .flush_IF_ID(flush_IF_ID),
        .flush_ID_EX(flush_ID_EX),
        .flush_EX_MEM(flush_EX_MEM)
    );


endmodule
