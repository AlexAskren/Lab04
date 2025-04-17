<<<<<<< HEAD
module forwarding_unit(
    input wire [4:0] ID_EX_Rs1,
    input wire [4:0] ID_EX_Rs2,
    input wire [4:0] EX_MEM_Rd,
    input wire [4:0] MEM_WB_Rd,
    input wire EX_MEM_RegWrite,
    input wire MEM_WB_RegWrite,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

always @(*) begin
    // Default forwarding controls
    ForwardA = 2'b00;
    ForwardB = 2'b00;

    // ForwardA logic
    if (MEM_WB_RegWrite && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_Rs1) &&
        !(EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rs1))) begin
        ForwardA = 2'b01; // Forward from MEM/WB
    end
    else if (EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rs1)) begin
        ForwardA = 2'b10; // Forward from EX/MEM
    end

    // ForwardB logic
    if (MEM_WB_RegWrite && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_Rs2) &&
        !(EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rs2))) begin
        ForwardB = 2'b01; // Forward from MEM/WB
    end
    else if (EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rs2)) begin
        ForwardB = 2'b10; // Forward from EX/MEM
    end
end

endmodule
=======
module forwarding_unit(
    input wire [4:0] ID_EX_Rs1,         // Source register 1
    input wire [4:0] ID_EX_Rs2,         // Source register 2
    input wire [4:0] EX_MEM_Rd,         // Destination register in EX/MEM
    input wire [4:0] MEM_WB_Rd,         // Destination register in MEM/WB
    input wire       EX_MEM_RegWrite,   // EX/MEM write enable
    input wire       MEM_WB_RegWrite,   // MEM/WB write enable
    output reg [1:0] ForwardA,          // Forward control for ALU input A
    output reg [1:0] ForwardB           // Forward control for ALU input B
);

always @(*) begin
    // Default to no forwarding (from register file)
    ForwardA = 2'b00;
    ForwardB = 2'b00;

    // --------------------------------------------
    // ForwardA (ALU input A)
    // --------------------------------------------

    // EX hazard: Forward from EX/MEM
    if (EX_MEM_RegWrite &&
        (EX_MEM_Rd != 0) &&
        (EX_MEM_Rd == ID_EX_Rs1)) begin
        ForwardA = 2'b10;
    end

    // MEM hazard: Forward from MEM/WB (only if EX/MEM didn't already match)
    else if (MEM_WB_RegWrite &&
             (MEM_WB_Rd != 0) &&
             !(EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rs1)) &&
             (MEM_WB_Rd == ID_EX_Rs1)) begin
        ForwardA = 2'b01;
    end

    // --------------------------------------------
    // ForwardB (ALU input B)
    // --------------------------------------------

    // EX hazard: Forward from EX/MEM
    if (EX_MEM_RegWrite &&
        (EX_MEM_Rd != 0) &&
        (EX_MEM_Rd == ID_EX_Rs2)) begin
        ForwardB = 2'b10;
    end

    // MEM hazard: Forward from MEM/WB (only if EX/MEM didn't already match)
    else if (MEM_WB_RegWrite &&
             (MEM_WB_Rd != 0) &&
             !(EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rs2)) &&
             (MEM_WB_Rd == ID_EX_Rs2)) begin
        ForwardB = 2'b01;
    end
end

endmodule
>>>>>>> 1d83ef174731f3dd56e5a49324b21a90cf0e531e
