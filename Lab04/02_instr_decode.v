 /*For the ID stage design, you are expected to:
 • Instruction Decoding: You need to determine how the instruction decoder identifies the type of instruction it
 receives. Each instruction type has a specific format and opcode that you can use for this purpose.
 • Sign Extension of Immediate Values: Ensure that the immediate values extracted from the instruction are
 correctly sign-extended. This is crucial for proper operation in subsequent stages of instruction execution.

 Important Considerations:
 • Review the instruction format to identify the fields such as opcode, funct3, funct7, rs1, rs2, and rd, which are
 necessary for decoding.
 • Implement logic to handle different instruction types, including R-type, I-type, S-type, B-type, U-type, and
 J-type instructions. Note that the type of instruction can be identified by the opcode within the 32-bit
 instruction.
 • Pay attention to how immediate values are represented in the instruction and how they should be extended to
 32 bits while preserving their sign. For U-type and J-type, the lower bits are set to 0. For slli, srli, and srai,
 the higher immediate bits are set to a preset value. You need to use only the select bits for these instructions.*/


 //declaration

 /*
 opcode and instr type

 R-type: 
 opcode = 0110011

 I-type:
 opcode = 0010011
 opcode = 0000011
 opcode = 1100111

 S-type:
 opcode = 0100011

 B-type:
 opcode = 1100011

 U-type:
 opcode = 0110111
 opcode = 0010111

 J-type:
 opcode = 1101111
*/

/*
NOTES

1. The ALU Op signal is derived from the Opcode fields of the instruction.
3. The immediate value is extracted from the instruction based on the type of instruction and sign-extended as needed.
4. The src_reg_addr0, src_reg_addr1, and dst_reg_addr are derived from the instruction fields based on the type of instruction.
5. The immediate value for U-type and J-type instructions is set to 0 for the lower bits, and for slli, srli, and srai, the higher immediate bits are set to a preset value.
*/


module riscv_Inst_Decode (
    input clk,
    input reset,
    input [31:0] Instr,                 // 32-bit RISC-V instruction
    output reg [4:0] src_reg_addr0,     // rs1
    output reg [4:0] src_reg_addr1,     // rs2
    output reg [4:0] dst_reg_addr,      // rd
    output reg [31:0] immediate_value,  // sign-extended immediate
    output reg MemWrite,
    output reg MemRead,
    output reg ALUSrc,
    output reg RegWrite,
    output reg Branch,
    output reg MemtoReg,
    output reg [1:0] ALUOp              // 2-bit ALUOp
    //Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite
    //Branch, MemWrite(0), 
);

    // Instruction field breakdown
    wire [6:0] opcode  = Instr[6:0];
    wire [4:0] rd      = Instr[11:7];
    wire [2:0] funct3  = Instr[14:12];
    wire [4:0] rs1     = Instr[19:15];
    wire [4:0] rs2     = Instr[24:20];
    wire [6:0] funct7  = Instr[31:25];

    // RISC-V opcodes
    localparam R_TYPE        = 7'b0110011;
    localparam I_TYPE        = 7'b0010011;
    localparam I_TYPE_L      = 7'b0000011;
    localparam I_TYPE_JALR   = 7'b1100111;
    //localparam I_TYPE_CALL   = 7'b1110011; // ??
    localparam S_TYPE        = 7'b0100011;
    localparam B_TYPE        = 7'b1100011;
    localparam J_TYPE        = 7'b1101111;
    localparam U_TYPE_AUIPC  = 7'b0010111;
    localparam U_TYPE        = 7'b0110111;

    // Control logic
    always @(*) begin
        // Default control values
        MemWrite        = 0;
        ALUSrc          = 0;
        RegWrite        = 0;
        Branch          = 0;
        ALUOp           = 2'b00;

        // Extract register fields
        src_reg_addr0 = 5'b0;   // Default to 0
        src_reg_addr1 = 5'b0;   // Default to 0
        dst_reg_addr  = 5'b0;   // Default to 0
        immediate_value = 32'b0;

        case (opcode)
            R_TYPE: begin //in the slides
                RegWrite = 1;
                MemRead  = 0;
                MemWrite = 0;
                MemtoReg = 0;
                ALUSrc   = 0;
                Branch   = 0;     
                ALUOp    = 2'b10;          // Based on your control diagram

                src_reg_addr0 = rs1;
                src_reg_addr1 = rs2;
                dst_reg_addr  = rd;
            end

            I_TYPE, I_TYPE_JALR: begin
                RegWrite = 1;
                MemRead  = 0;
                MemWrite = 0;
                MemtoReg = 0;
                ALUSrc   = 1;
                Branch   = 0;    
                ALUOp    = 2'b10;

                src_reg_addr0 = rs1;  // rs1 is used for I-type instructions
                src_reg_addr1 = 5'b0; // rs2 is not used in I-type
                dst_reg_addr  = rd;

                immediate_value = {{20{Instr[31]}}, Instr[31:20]};  // I-type
            end

            I_TYPE_L: begin
                RegWrite = 1;
                MemRead  = 1;
                MemWrite = 0;
                MemtoReg = 1;
                ALUSrc   = 1;
                Branch   = 0;    
                ALUOp    = 2'b00;

                src_reg_addr0 = rs1;  // rs1 is used for I-type instructions
                src_reg_addr1 = 5'b0; // rs2 is not used in I-type
                dst_reg_addr  = rd;

                immediate_value = {{20{Instr[31]}}, Instr[31:20]};  // I-type
            end

            S_TYPE: begin //in the slides
                RegWrite = 0;
                MemRead  = 0;
                MemWrite = 1;
                MemtoReg = 0;
                ALUSrc   = 1;
                Branch   = 0;    
                ALUOp    = 2'b00;

                src_reg_addr0 = rs1;
                src_reg_addr1 = rs2; // rs2 is used in S-type instructions
                dst_reg_addr  = 5'b0; // No destination register in S-type

                immediate_value = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};  // S-type
            end

            B_TYPE: begin
                RegWrite = 0;
                MemRead  = 0;
                MemWrite = 0;
                MemtoReg = 0;
                ALUSrc   = 0;
                Branch   = 1;    
                ALUOp    = 2'b01;

                src_reg_addr0 = rs1;
                src_reg_addr1 = rs2; // rs2 is used for branch comparison
                dst_reg_addr  = 5'b0; // No destination register in B-type

                immediate_value = {{19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8], 1'b0};  // B-type
            end

            U_TYPE, U_TYPE_AUIPC: begin
                RegWrite = 1;
                MemRead  = 0;
                MemWrite = 0;
                MemtoReg = 0;
                ALUSrc   = 1;
                Branch   = 0;    
                ALUOp    = 2'b00;
                immediate_value = {Instr[31:12], 12'b0};  // U-type
            end

            J_TYPE: begin
                RegWrite = 1;
                MemRead  = 0;
                MemWrite = 0;
                MemtoReg = 0;
                ALUSrc   = 1;
                Branch   = 0;    
                ALUOp    = 2'b00;

                src_reg_addr0 = 5'b0;  // No rs1 used in J-type
                src_reg_addr1 = 5'b0;  // No rs2 used in J-type
                dst_reg_addr  = rd;

                immediate_value = {{11{Instr[31]}}, Instr[31], Instr[19:12], Instr[20], Instr[30:21], 1'b0};  // J-type
            end

            default: begin
                // No-op for now
                RegWrite = 0;
                MemRead  = 0;
                MemWrite = 0;
                MemtoReg = 0;
                ALUSrc   = 0;
                Branch   = 0;    
                ALUOp    = 2'b00;

                src_reg_addr0 = 5'b0;  // Default to 0
                src_reg_addr1 = 5'b0;  // Default to 0
                dst_reg_addr  = 5'b0;  // Default to 0
            end
        endcase
    end

endmodule
