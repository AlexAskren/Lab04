module forwarding_unit(
    input wire [4:0] ID_EX_Rs1,        // Source register 1 in ID/EX
    input wire [4:0] ID_EX_Rs2,        // Source register 2 in ID/EX
    input wire [4:0] EX_MEM_Rd,        // Destination register in EX/MEM
    input wire [4:0] MEM_WB_Rd,        // Destination register in MEM/WB
    input wire EX_MEM_RegWrite,        // EX/MEM register write enable
    input wire MEM_WB_RegWrite,        // MEM/WB register write enable
    output reg [1:0] ForwardA,         // Forward control for ALU input A
    output reg [1:0] ForwardB          // Forward control for ALU input B
);

// Forwarding decision logic
always @(*) begin
    // Default forwarding controls
    ForwardA = 2'b00;
    ForwardB = 2'b00;

    // EX hazard forwarding for ALU operand A
    if (EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rs1)) begin
        ForwardA = 2'b10; // Forward from EX/MEM stage
    end
    // MEM hazard forwarding for ALU operand A
    else if (MEM_WB_RegWrite && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_Rs1)) begin
        ForwardA = 2'b01; // Forward from MEM/WB stage
    end

    // EX hazard forwarding for ALU operand B
    if (EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rs2)) begin
        ForwardB = 2'b10; // Forward from EX/MEM stage
    end
    // MEM hazard forwarding for ALU operand B
    else if (MEM_WB_RegWrite && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_Rs2)) begin
        ForwardB = 2'b01; // Forward from MEM/WB stage
    end
end

endmodule
