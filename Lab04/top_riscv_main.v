module top_pipelined_riscv (
    input wire clk,
    input wire reset
);

    // PC and instruction fetch
    reg [31:0] PC;
    wire [31:0] next_PC;
    wire [31:0] instr;

    // IF/ID pipeline registers
    reg [31:0] IF_ID_instr;
    reg [31:0] IF_ID_PC;

    // ID/EX pipeline registers
    reg [31:0] ID_EX_RD1, ID_EX_RD2, ID_EX_imm;
    reg [4:0]  ID_EX_rs1, ID_EX_rs2, ID_EX_rd;
    reg [1:0]  ID_EX_ALUOp;
    reg        ID_EX_ALUSrc, ID_EX_MemRead, ID_EX_MemWrite;
    reg        ID_EX_RegWrite, ID_EX_MemToReg;
    reg [2:0]  ID_EX_funct3;
    reg        ID_EX_funct7_bit;

    // EX/MEM pipeline registers
    reg [31:0] EX_MEM_ALU_result, EX_MEM_RD2;
    reg [4:0]  EX_MEM_rd;
    reg        EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_MemToReg;

    // MEM/WB pipeline registers
    reg [31:0] MEM_WB_read_data, MEM_WB_ALU_result;
    reg [4:0]  MEM_WB_rd;
    reg        MEM_WB_RegWrite, MEM_WB_MemToReg;

    wire RegWrite, MemRead, MemWrite, ALUSrc, Branch, MemToReg;
    wire [1:0] ALUOp;
    wire hazard_stall, PCWrite, IF_ID_Write;

    wire [6:0] opcode = IF_ID_instr[6:0];
    wire [4:0] rs1 = IF_ID_instr[19:15];
    wire [4:0] rs2 = IF_ID_instr[24:20];
    wire [4:0] rd  = IF_ID_instr[11:7];
    wire [31:0] imm = {{20{IF_ID_instr[31]}}, IF_ID_instr[31:20]};

    wire [1:0] ForwardA, ForwardB;
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

    wire [31:0] ALU_input_A = (ForwardA == 2'b10) ? EX_MEM_ALU_result :
                              (ForwardA == 2'b01) ? (MEM_WB_MemToReg ? MEM_WB_read_data : MEM_WB_ALU_result) :
                              ID_EX_RD1;

    wire [31:0] ALU_input_B_raw = (ForwardB == 2'b10) ? EX_MEM_ALU_result :
                                  (ForwardB == 2'b01) ? (MEM_WB_MemToReg ? MEM_WB_read_data : MEM_WB_ALU_result) :
                                  ID_EX_RD2;

    wire [31:0] ALU_input_B = (ID_EX_ALUSrc) ? ID_EX_imm : ALU_input_B_raw;

    wire [4:0] ALU_ctrl;
    alu_control ALU_CTRL (
        .ALUOp(ID_EX_ALUOp),
        .funct3(ID_EX_funct3),
        .funct7_bit(ID_EX_funct7_bit),
        .ALUControl(ALU_ctrl)
    );

    wire [31:0] ALU_result;
    wire Zero_flag;
    riscv_ALU ALU (
        .clk(clk),
        .reset(reset),
        .ALU_ctrl(ALU_ctrl),
        .ALU_ina(ALU_input_A),
        .ALU_inb_reg(ALU_input_B_raw),
        .ALU_inb_imm(ID_EX_imm),
        .ALUSrc(ID_EX_ALUSrc),
        .ALU_out(ALU_result),
        .Zero_flag(Zero_flag)
    );

    wire [31:0] DataMemOut;
    mem_data DMEM (
        .clk(clk),
        .reset(reset),
        .rd_en(EX_MEM_MemRead),
        .wr_en(EX_MEM_MemWrite),
        .addr(EX_MEM_ALU_result),
        .din(EX_MEM_RD2),
        .dout(DataMemOut)
    );

    instr_mem #(.MEM_DEPTH(2048)) IMEM (
        .clk(clk),
        .reset(reset),
        .addr(PC),
        .instr(instr)
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

    wire [31:0] RD1, RD2;
    register_file RF (
        .clk(clk),
        .rst(reset),
        .stall(hazard_stall),
        .A1(rs1),
        .A2(rs2),
        .A3(MEM_WB_rd),
        .WD3(MEM_WB_MemToReg ? MEM_WB_read_data : MEM_WB_ALU_result),
        .WE3(MEM_WB_RegWrite),
        .RD1(RD1),
        .RD2(RD2)
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

    always @(posedge clk or posedge reset)
        PC <= (reset) ? 32'b0 : (PCWrite) ? next_PC : PC;

    assign next_PC = PC + 4;

    // pipeline register updates as provided earlier in corrected form...
    // IF_ID pipeline register update
always @(posedge clk) begin
    if (reset) begin
        IF_ID_instr <= 32'b0;
        IF_ID_PC    <= 32'b0;
    end else if (IF_ID_Write) begin
        IF_ID_instr <= instr;
        IF_ID_PC    <= PC;
    end
end

// ID_EX pipeline register update (Exactly ONCE)
always @(posedge clk) begin
    if (reset || hazard_stall) begin
        ID_EX_RD1       <= 32'b0;
        ID_EX_RD2       <= 32'b0;
        ID_EX_imm       <= 32'b0;
        ID_EX_rs1       <= 5'b0;
        ID_EX_rs2       <= 5'b0;
        ID_EX_rd        <= 5'b0;
        ID_EX_RegWrite  <= 1'b0;
        ID_EX_MemRead   <= 1'b0;
        ID_EX_MemWrite  <= 1'b0;
        ID_EX_ALUSrc    <= 1'b0;
        ID_EX_ALUOp     <= 2'b00;
        ID_EX_MemToReg  <= 1'b0;
        ID_EX_funct3    <= 3'b000;
        ID_EX_funct7_bit<= 1'b0;
    end else begin
        ID_EX_RD1       <= RD1;
        ID_EX_RD2       <= RD2;
        ID_EX_imm       <= imm;
        ID_EX_rs1       <= rs1;
        ID_EX_rs2       <= rs2;
        ID_EX_rd        <= rd;
        ID_EX_RegWrite  <= RegWrite;
        ID_EX_MemRead   <= MemRead;
        ID_EX_MemWrite  <= MemWrite;
        ID_EX_ALUSrc    <= ALUSrc;
        ID_EX_ALUOp     <= ALUOp;
        ID_EX_MemToReg  <= MemToReg;
        ID_EX_funct3    <= IF_ID_instr[14:12];
        ID_EX_funct7_bit<= IF_ID_instr[30];
    end
end

// EX_MEM pipeline register update
always @(posedge clk) begin
    if (reset) begin
        EX_MEM_ALU_result <= 32'b0;
        EX_MEM_RD2        <= 32'b0;
        EX_MEM_rd         <= 5'b0;
        EX_MEM_RegWrite   <= 1'b0;
        EX_MEM_MemRead    <= 1'b0;
        EX_MEM_MemWrite   <= 1'b0;
        EX_MEM_MemToReg   <= 1'b0;
    end else begin
        EX_MEM_ALU_result <= ALU_result;
        EX_MEM_RD2        <= ALU_input_B_raw;
        EX_MEM_rd         <= ID_EX_rd;
        EX_MEM_RegWrite   <= ID_EX_RegWrite;
        EX_MEM_MemRead    <= ID_EX_MemRead;
        EX_MEM_MemWrite   <= ID_EX_MemWrite;
        EX_MEM_MemToReg   <= ID_EX_MemToReg;
    end
end

// MEM_WB pipeline register update
always @(posedge clk) begin
    if (reset) begin
        MEM_WB_read_data  <= 32'b0;
        MEM_WB_ALU_result <= 32'b0;
        MEM_WB_rd         <= 5'b0;
        MEM_WB_RegWrite   <= 1'b0;
        MEM_WB_MemToReg   <= 1'b0;
    end else begin
        MEM_WB_read_data  <= DataMemOut;
        MEM_WB_ALU_result <= EX_MEM_ALU_result;
        MEM_WB_rd         <= EX_MEM_rd;
        MEM_WB_RegWrite   <= EX_MEM_RegWrite;
        MEM_WB_MemToReg   <= EX_MEM_MemToReg;
    end
end



// Debugging display (optional but recommended)
always @(posedge clk) begin
    $display("[FORWARD DEBUG] EX_MEM_RegWrite=%b, EX_MEM_Rd=%d, MEM_WB_RegWrite=%b, MEM_WB_Rd=%d, ID_EX_Rs1=%d, ID_EX_Rs2=%d", 
        EX_MEM_RegWrite, EX_MEM_rd, MEM_WB_RegWrite, MEM_WB_rd, ID_EX_rs1, ID_EX_rs2);
end

endmodule
