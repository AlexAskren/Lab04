module forwarding_unit #(
    parameter REG_ADDR_WIDTH = 5       // Width of register address (default 5 bits for 32 registers)
)(
    input  wire [REG_ADDR_WIDTH-1:0] ID_EX_Rs1,     // Source register 1 in ID/EX
    input  wire [REG_ADDR_WIDTH-1:0] ID_EX_Rs2,     // Source register 2 in ID/EX
    input  wire [REG_ADDR_WIDTH-1:0] EX_MEM_Rd,     // Destination register in EX/MEM
    input  wire [REG_ADDR_WIDTH-1:0] MEM_WB_Rd,     // Destination register in MEM/WB
    input  wire                      EX_MEM_RegWrite, // EX/MEM write enable
    input  wire                      MEM_WB_RegWrite, // MEM/WB write enable
    output reg  [1:0]                ForwardA,       // Forward control for ALU input A
    output reg  [1:0]                ForwardB        // Forward control for ALU input B
);

    always @(*) begin
        // Default: no forwarding
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // -----------------------------------
        // ForwardA (operand A)
        // -----------------------------------
        if (EX_MEM_RegWrite &&
            (EX_MEM_Rd != {REG_ADDR_WIDTH{1'b0}}) &&
            (EX_MEM_Rd == ID_EX_Rs1)) begin
            ForwardA = 2'b10;
        end else if (MEM_WB_RegWrite &&
                     (MEM_WB_Rd != {REG_ADDR_WIDTH{1'b0}}) &&
                     !(EX_MEM_RegWrite && (EX_MEM_Rd != {REG_ADDR_WIDTH{1'b0}}) && (EX_MEM_Rd == ID_EX_Rs1)) &&
                     (MEM_WB_Rd == ID_EX_Rs1)) begin
            ForwardA = 2'b01;
        end

        // -----------------------------------
        // ForwardB (operand B)
        // -----------------------------------
        if (EX_MEM_RegWrite &&
            (EX_MEM_Rd != {REG_ADDR_WIDTH{1'b0}}) &&
            (EX_MEM_Rd == ID_EX_Rs2)) begin
            ForwardB = 2'b10;
        end else if (MEM_WB_RegWrite &&
                     (MEM_WB_Rd != {REG_ADDR_WIDTH{1'b0}}) &&
                     !(EX_MEM_RegWrite && (EX_MEM_Rd != {REG_ADDR_WIDTH{1'b0}}) && (EX_MEM_Rd == ID_EX_Rs2)) &&
                     (MEM_WB_Rd == ID_EX_Rs2)) begin
            ForwardB = 2'b01;
        end
    end

endmodule
