// Updated RISC-V ALU module with parameterization and forwarding support

module riscv_ALU #(
    parameter DATA_WIDTH = 32
)(
    input wire clk,
    input wire reset,

    input wire [4:0] ALU_ctrl,                        // ALU control signal
    input wire [DATA_WIDTH-1:0] ALU_ina,              // Forwarded ALU input A
    input wire [DATA_WIDTH-1:0] ALU_inb_reg,          // Forwarded ALU input B from reg
    input wire [DATA_WIDTH-1:0] ALU_inb_imm,          // Immediate value
    input wire ALUSrc,                                // Select between reg and imm

    output reg [DATA_WIDTH-1:0] ALU_out,              // ALU result
    output reg Zero_flag,
    output reg Negative_flag,
    output reg Carry_flag,
    output reg Overflow_flag
);

    wire [DATA_WIDTH-1:0] ALU_inb;
    assign ALU_inb = (ALUSrc) ? ALU_inb_imm : ALU_inb_reg; // Operand B selection

    always @(*) begin
        // Default outputs
        ALU_out = {DATA_WIDTH{1'b0}};
        Zero_flag = 1'b0;
        Negative_flag = 1'b0;
        Carry_flag = 1'b0;
        Overflow_flag = 1'b0;

        case (ALU_ctrl)
            5'b00000: ALU_out = ALU_ina + ALU_inb;            // ADD
            5'b00001: ALU_out = ALU_ina - ALU_inb;            // SUB
            5'b00010: ALU_out = ALU_ina * ALU_inb;            // MUL
            5'b00011: ALU_out = ($signed(ALU_ina) * $signed(ALU_inb)) >>> 32;  // MULH
            5'b00100: ALU_out = ($signed(ALU_ina) * $unsigned(ALU_inb)) >>> 32; // MULHSU
            5'b00101: ALU_out = ($unsigned(ALU_ina) * $unsigned(ALU_inb)) >>> 32; // MULHU
            5'b00110: ALU_out = $signed(ALU_ina) / $signed(ALU_inb); // DIV
            5'b00111: ALU_out = $unsigned(ALU_ina) / $unsigned(ALU_inb); // DIVU
            5'b01000: ALU_out = $signed(ALU_ina) % $signed(ALU_inb); // REM
            5'b01001: ALU_out = $unsigned(ALU_ina) % $unsigned(ALU_inb); // REMU
            5'b01010: ALU_out = ALU_ina ^ ALU_inb;             // XOR
            5'b01011: ALU_out = ALU_ina | ALU_inb;             // OR
            5'b01100: ALU_out = ALU_ina & ALU_inb;             // AND
            5'b01101: ALU_out = ALU_ina << ALU_inb[4:0];       // SLL
            5'b01110: ALU_out = ALU_ina >> ALU_inb[4:0];       // SRL
            5'b01111: ALU_out = $signed(ALU_ina) >>> ALU_inb[4:0]; // SRA
            5'b10000: ALU_out = ($signed(ALU_ina) < $signed(ALU_inb)) ? 1 : 0; // SLT
            5'b10001: ALU_out = ($unsigned(ALU_ina) < $unsigned(ALU_inb)) ? 1 : 0; // SLTU
            5'b10010: ALU_out = (ALU_ina == ALU_inb) ? 1 : 0;  // Equal
            5'b10011: ALU_out = (ALU_ina != ALU_inb) ? 1 : 0;  // Not equal
            default:  ALU_out = {DATA_WIDTH{1'b0}};
        endcase

        // Flag generation
        Zero_flag = (ALU_out == 0);
        Negative_flag = ALU_out[DATA_WIDTH-1];
    end

endmodule
