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

    always @(*) begin
        if (stall) begin
            // Insert NOP (No Operation)
            RegWrite = 0;
            MemRead  = 0;
            MemWrite = 0;
            ALUSrc   = 0;
            Branch   = 0;
            MemToReg = 0;
            ALUOp    = 2'b00;
        end else begin
            case (opcode)
                7'b0110011: begin // R-type
                    RegWrite = 1;
                    MemRead  = 0;
                    MemWrite = 0;
                    ALUSrc   = 0;
                    Branch   = 0;
                    MemToReg = 0;
                    ALUOp    = 2'b10;
                end
                7'b0000011: begin // I-type: Load (e.g., lw)
                    RegWrite = 1;
                    MemRead  = 1;
                    MemWrite = 0;
                    ALUSrc   = 1;
                    Branch   = 0;
                    MemToReg = 1;
                    ALUOp    = 2'b00;
                end
                7'b0100011: begin // S-type: Store (e.g., sw)
                    RegWrite = 0;
                    MemRead  = 0;
                    MemWrite = 1;
                    ALUSrc   = 1;
                    Branch   = 0;
                    MemToReg = 0; // Don't care
                    ALUOp    = 2'b00;
                end
                7'b1100011: begin // B-type: Branch (e.g., beq, bne)
                    RegWrite = 0;
                    MemRead  = 0;
                    MemWrite = 0;
                    ALUSrc   = 0;
                    Branch   = 1;
                    MemToReg = 0; // Don't care
                    ALUOp    = 2'b01;
                end
                7'b0010011: begin // I-type: Arithmetic immediate
                    RegWrite = 1;
                    MemRead  = 0;
                    MemWrite = 0;
                    ALUSrc   = 1;
                    Branch   = 0;
                    MemToReg = 0;
                    ALUOp    = 2'b10;
                end
                7'b1101111: begin // J-type: JAL
                    RegWrite = 1;
                    MemRead  = 0;
                    MemWrite = 0;
                    ALUSrc   = 1;
                    Branch   = 0;
                    MemToReg = 0;
                    ALUOp    = 2'b00;
                end
                default: begin // Unknown instruction → NOP
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
