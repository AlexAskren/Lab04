module alu_control (
    input wire [1:0] ALUOp,
    input wire [2:0] funct3,
    input wire funct7_bit,
    output reg [4:0] ALUControl
);

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = 5'b00000; // ADD (for LW, SW, and base ops)
        2'b01: ALUControl = 5'b00001; // SUB (for branches like BEQ, BNE, etc.)
        2'b10: begin // R-type or arithmetic I-type
            case ({funct7_bit, funct3})
                4'b0000: ALUControl = 5'b00000; // ADD
                4'b1000: ALUControl = 5'b00001; // SUB
                4'b0001: ALUControl = 5'b01101; // SLL
                4'b0010: ALUControl = 5'b10000; // SLT
                4'b0011: ALUControl = 5'b10001; // SLTU
                4'b0100: ALUControl = 5'b01010; // XOR
                4'b0101: ALUControl = 5'b01110; // SRL
                4'b1101: ALUControl = 5'b01111; // SRA
                4'b0110: ALUControl = 5'b01011; // OR
                4'b0111: ALUControl = 5'b01100; // AND
                default: ALUControl = 5'b00000; // Default ADD
            endcase
        end
        default: ALUControl = 5'b00000; // Default ADD operation
    endcase
end

endmodule
