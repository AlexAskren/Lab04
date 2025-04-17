module control_unit (
    input wire        stall,        // Stall signal from hazard detection
    input wire [6:0]  opcode,       // Opcode from instruction
    output reg        RegWrite,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        ALUSrc,
    output reg        Branch,
    output reg        MemToReg,
    output reg [1:0]  ALUOp
);

    // Opcode encoding (RISC-V base)
    localparam [6:0]
        OPCODE_R_TYPE = 7'b0110011,
        OPCODE_I_LOAD = 7'b0000011,
        OPCODE_S_TYPE = 7'b0100011,
        OPCODE_B_TYPE = 7'b1100011,
        OPCODE_I_ALU  = 7'b0010011,
        OPCODE_JAL    = 7'b1101111,
        OPCODE_LUI    = 7'b0110111,
        OPCODE_AUIPC  = 7'b0010111;

    always @(*) begin
        if (stall) begin
            // NOP
            RegWrite = 0;
            MemRead  = 0;
            MemWrite = 0;
            ALUSrc   = 0;
            Branch   = 0;
            MemToReg = 0;
            ALUOp    = 2'b00;
        end else begin
            case (opcode)
                OPCODE_R_TYPE: begin
                    RegWrite = 1;
                    MemRead  = 0;
                    MemWrite = 0;
                    ALUSrc   = 0;
                    Branch   = 0;
                    MemToReg = 0;
                    ALUOp    = 2'b10;
                end
                OPCODE_I_LOAD: begin
                    RegWrite = 1;
                    MemRead  = 1;
                    MemWrite = 0;
                    ALUSrc   = 1;
                    Branch   = 0;
                    MemToReg = 1;
                    ALUOp    = 2'b00;
                end
                OPCODE_S_TYPE: begin
                    RegWrite = 0;
                    MemRead  = 0;
                    MemWrite = 1;
                    ALUSrc   = 1;
                    Branch   = 0;
                    MemToReg = 0; // Don't care
                    ALUOp    = 2'b00;
                end
                OPCODE_B_TYPE: begin
                    RegWrite = 0;
                    MemRead  = 0;
                    MemWrite = 0;
                    ALUSrc   = 0;
                    Branch   = 1;
                    MemToReg = 0; // Don't care
                    ALUOp    = 2'b01;
                end
                OPCODE_I_ALU: begin
                    RegWrite = 1;
                    MemRead  = 0;
                    MemWrite = 0;
                    ALUSrc   = 1;
                    Branch   = 0;
                    MemToReg = 0;
                    ALUOp    = 2'b10;
                end
                OPCODE_JAL: begin
                    RegWrite = 1;
                    MemRead  = 0;
                    MemWrite = 0;
                    ALUSrc   = 1;
                    Branch   = 0;
                    MemToReg = 0;
                    ALUOp    = 2'b00;
                end
                OPCODE_LUI: begin
                    RegWrite = 1;
                    MemRead  = 0;
                    MemWrite = 0;
                    ALUSrc   = 1;
                    Branch   = 0;
                    MemToReg = 0;
                    ALUOp    = 2'b00;
                end
                OPCODE_AUIPC: begin
                    RegWrite = 1;
                    MemRead  = 0;
                    MemWrite = 0;
                    ALUSrc   = 1;
                    Branch   = 0;
                    MemToReg = 0;
                    ALUOp    = 2'b00;
                end
                default: begin
                    RegWrite = 0;
                    MemRead  = 0;
                    MemWrite = 0;
                    ALUSrc   = 0;
                    Branch   = 0;
                    MemToReg = 0;
                    ALUOp    = 2'b00;
                end
            endcase
        end
    end

endmodule
