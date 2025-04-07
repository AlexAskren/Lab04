module riscv_ALU #(
    parameter ALU_WIDTH = 32,
    parameter ALU_CTRL_WIDTH = 5
)(
    input wire clk,
    input wire reset,
    input wire [ALU_CTRL_WIDTH-1:0] ALU_ctrl,
    input wire [ALU_WIDTH-1:0] ALU_ina,
    input wire [ALU_WIDTH-1:0] ALU_inb_reg,         // ReadData2
    input wire [ALU_WIDTH-1:0] ALU_inb_imm,         // ImmExt
    input wire ALUSrc,                              // Control signal
    output reg [ALU_WIDTH-1:0] ALU_out,
    output wire Overflow_flag,
    output wire Carry_flag,
    output wire Negative_flag,
    output wire Zero_flag
);

    // Operand MUX (inside ALU as requested)
    wire [ALU_WIDTH-1:0] ALU_inb = (ALUSrc) ? ALU_inb_imm : ALU_inb_reg;

    wire signed [ALU_WIDTH-1:0] A_signed = ALU_ina;
    wire signed [ALU_WIDTH-1:0] B_signed = ALU_inb;
    wire [ALU_WIDTH-1:0] A_unsigned = ALU_ina;
    wire [ALU_WIDTH-1:0] B_unsigned = ALU_inb;

    wire [2*ALU_WIDTH-1:0] mult_signed   = A_signed * B_signed;
    wire [2*ALU_WIDTH-1:0] mult_unsigned = A_unsigned * B_unsigned;
    wire [2*ALU_WIDTH-1:0] mult_mix      = A_signed * B_unsigned;

    wire [ALU_WIDTH-1:0] add_result = ALU_ina + ALU_inb;
    wire [ALU_WIDTH-1:0] sub_result = ALU_ina - ALU_inb;

    always @(*) begin
        case (ALU_ctrl)
            5'b00000: ALU_out = ALU_ina + ALU_inb;                      // ADD
            5'b00001: ALU_out = ALU_ina - ALU_inb;                      // SUB
            5'b00010: ALU_out = mult_signed[ALU_WIDTH-1:0];             // MUL
            5'b00011: ALU_out = mult_signed[2*ALU_WIDTH-1:ALU_WIDTH];   // MULH
            5'b00100: ALU_out = mult_mix[2*ALU_WIDTH-1:ALU_WIDTH];      // MULHSU
            5'b00101: ALU_out = mult_unsigned[2*ALU_WIDTH-1:ALU_WIDTH]; // MULHU
            5'b00110: ALU_out = (B_signed == 0) ? {ALU_WIDTH{1'b1}} : A_signed / B_signed;
            5'b00111: ALU_out = (B_unsigned == 0) ? {ALU_WIDTH{1'b1}} : A_unsigned / B_unsigned;
            5'b01000: ALU_out = (B_signed == 0) ? {ALU_WIDTH{1'b1}} : A_signed % B_signed;
            5'b01001: ALU_out = (B_unsigned == 0) ? {ALU_WIDTH{1'b1}} : A_unsigned % B_unsigned;
            5'b01010: ALU_out = ALU_ina ^ ALU_inb;
            5'b01011: ALU_out = ALU_ina | ALU_inb;
            5'b01100: ALU_out = ALU_ina & ALU_inb;
            5'b01101: ALU_out = ALU_ina << ALU_inb[$clog2(ALU_WIDTH)-1:0];
            5'b01110: ALU_out = ALU_ina >> ALU_inb[$clog2(ALU_WIDTH)-1:0];
            5'b01111: ALU_out = A_signed >>> ALU_inb[$clog2(ALU_WIDTH)-1:0];
            5'b10000: ALU_out = (A_signed < B_signed) ? {{(ALU_WIDTH-1){1'b0}}, 1'b1} : {ALU_WIDTH{1'b0}};
            5'b10001: ALU_out = (A_unsigned < B_unsigned) ? {{(ALU_WIDTH-1){1'b0}}, 1'b1} : {ALU_WIDTH{1'b0}};
            5'b10010: ALU_out = (ALU_ina == ALU_inb) ? {{(ALU_WIDTH-1){1'b0}}, 1'b1} : {ALU_WIDTH{1'b0}};
            5'b10011: ALU_out = (ALU_ina != ALU_inb) ? {{(ALU_WIDTH-1){1'b0}}, 1'b1} : {ALU_WIDTH{1'b0}};
            default:  ALU_out = {ALU_WIDTH{1'b0}};
        endcase
    end

    assign Zero_flag     = (ALU_out == {ALU_WIDTH{1'b0}});
    assign Negative_flag = ALU_out[ALU_WIDTH-1];

    assign Carry_flag = (ALU_ctrl == 5'b00000 || ALU_ctrl == 5'b00001) ?
                        (ALU_ina > {ALU_WIDTH{1'b1}} - ALU_inb) : 1'b0;

    assign Overflow_flag = (ALU_ctrl == 5'b00000 || ALU_ctrl == 5'b00001) ?
                           ((ALU_ina[ALU_WIDTH-1] == ALU_inb[ALU_WIDTH-1]) &&
                            (ALU_out[ALU_WIDTH-1] != ALU_ina[ALU_WIDTH-1])) : 1'b0;

endmodule
