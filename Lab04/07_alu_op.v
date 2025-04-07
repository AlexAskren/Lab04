/*
For each Opcode listed on the green card, you need to first identify the ALU operation based on the values of
 Opcode, funct3, and funct7. Additionally, ensure that for I-type instructions, the ALU accesses the extended
 immediate value rather than the data from the general-purpose registers. For B-type instructions, which implicitly
 include subtraction, you need to configure these instructions to perform subtraction. For I-type load instructions
 and S-type store instructions, the ALU should be configured for addition, and similarly for the case of JALR.
 You also need to identify the control signals: Branch, MemRead, MemtoReg, ALUOP, MemWrite, ALUSrc, and
 RegWrite. Note that some of these signals can be merged with the ID module, while others still need to be connected 
 to the top-level processor.
*/
/*
module alu_op #(
    parameter INSTR_WIDTH = 32,      // Instruction width (default 32 bits)
    parameter ALUCONTROL_WIDTH = 4,  // ALU Control signal width (default 4 bits)
    parameter ADD_OPCODE = 7'b0110011,   // R-type ADD opcode
    parameter SUB_OPCODE = 7'b0110011    // R-type SUB opcode
)
*/
    
/*
NOTES

based on AluOP and instr(30), instr(14:12) the ALU Operation is decided
*/

        /*
     case (ALU_ctrl)
            5'b00000: // ADD ok
            5'b00001: // SUB ok
            5'b00010: // MUL ok
            5'b00011:  // MULH ok
            5'b00100: // MULHSU ok
            5'b00101: // MULHU ok
            5'b00110: //DIV ok
            5'b00111: //DIVU ok
            5'b01000: //REM ok
            5'b01001: //REMU ok
            5'b01010: //XOR ok
            5'b01011: //OR ok
            5'b01100: //AND ok
            5'b01101: //SLL ok
            5'b01110: //SRL ok
            5'b01111: //SRA ok
            5'b10000: //Set less than ok
            5'b10001: //Set less than unsigned ok
            5'b10010:   //Equal
            5'b10011:   //Not equal
            default: 
        endcase
    */

    module alu_control (
    input wire clk,                     // Clock signal
    input wire reset,                   // Reset signal
    input wire [1:0] ALUOp,             // ALU operation control (2 bits)
    input wire [31:0] instr,            // Instruction (32 bits)
    output reg [4:0] ALUControl         // ALU operation output (5 bits)
);

    // Extract necessary fields from instruction
    wire [2:0] funct3 = instr[14:12];      // Funct3 (bits 14-12)
    wire funct7_bit = instr[30];           // Funct7 bit (bit 30)

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ALUControl <= 5'b00000; // Reset ALU control to default (NOP)
        end else begin
            case (ALUOp)
                2'b00: begin // ALUOp = 00: Add / Base (I-type, S-type, U-type, J-type)
                    case (funct3)
                        3'b000: begin // ADD/SUB operation
                            case (funct7_bit)
                                1'b0: ALUControl = 5'b00000; // ADD (for R-type)
                                1'b1: ALUControl = 5'b00001; // SUB (for R-type)
                                default: ALUControl = 5'b00000; // Default to ADD
                            endcase
                        end
                        3'b100: ALUControl = 5'b01010; // XOR
                        3'b101: begin // SRL/SRA (Shift Right Logical / Arithmetic)
                            case (funct7_bit)
                                1'b0: ALUControl = 5'b01110; // SRL
                                1'b1: ALUControl = 5'b01111; // SRA
                                default: ALUControl = 5'b00000; // Default to NOP
                            endcase
                        end
                        3'b110: ALUControl = 5'b01011; // OR
                        3'b111: ALUControl = 5'b01100; // AND
                        3'b001: ALUControl = 5'b01101; // SLL (Shift Left Logical)
                        3'b010: ALUControl = 5'b10000; // SLT (Set Less Than)
                        3'b110: ALUControl = 5'b10001; // SLTU (Set Less Than Unsigned)
                        default: ALUControl = 5'b00000; // Default to ADD
                    endcase
                end

                2'b01: begin // ALUOp = 01: Branch Compare (B-type)
                    case (funct3)
                        3'b000: ALUControl = 5'b00001; // BEQ (Branch if equal) - Compare with SUB
                        3'b001: ALUControl = 5'b00001; // BNE (Branch if not equal) - Compare with SUB
                        3'b100: ALUControl = 5'b00001; // BLT (Branch if less than) - Compare with SUB
                        3'b101: ALUControl = 5'b00001; // BGE (Branch if greater than or equal) - Compare with SUB
                        default: ALUControl = 5'b00000; // Default to NOP
                    endcase
                end

                2'b10: begin // ALUOp = 10: R-type / I-type ALU (arithmetic/logical operations)
                    case (funct3)
                        3'b000: begin // ADD / SUB
                            case (funct7_bit)
                                1'b0: ALUControl = 5'b00000; // ADD
                                1'b1: ALUControl = 5'b00001; // SUB
                                default: ALUControl = 5'b00000; // Default to ADD
                            endcase
                        end
                        3'b010: ALUControl = 5'b10000; // SLT (Set Less Than)
                        3'b011: ALUControl = 5'b10001; // SLTU (Set Less Than Unsigned)
                        3'b100: ALUControl = 5'b01010; // XOR
                        3'b101: begin // SRL / SRA (Shift Right Logical / Arithmetic)
                            case (funct7_bit)
                                1'b0: ALUControl = 5'b01110; // SRL
                                1'b1: ALUControl = 5'b01111; // SRA
                                default: ALUControl = 5'b00000; // Default to NOP
                            endcase
                        end
                        3'b110: ALUControl = 5'b01011; // OR
                        3'b111: ALUControl = 5'b01100; // AND
                        default: ALUControl = 5'b00000; // Default to ADD
                    endcase
                end

                default: ALUControl = 5'b00000; // Default NOP operation for invalid ALUOp
            endcase
        end
    end
endmodule
