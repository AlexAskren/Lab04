module hazard_detection_unit (
    input wire ID_EX_MemRead,        // MEM read signal from ID/EX stage (load instruction in EX)
    input wire [4:0] ID_EX_Rd,       // Destination register from ID/EX stage
    input wire [4:0] IF_ID_Rs1,      // Source register 1 from IF/ID stage
    input wire [4:0] IF_ID_Rs2,      // Source register 2 from IF/ID stage

    output reg stall,                // Stall signal (to control pipeline)
    output reg PCWrite,              // PC update control (hold PC when hazard)
    output reg IF_ID_Write           // IF/ID pipeline register write enable (hold when hazard)
);

always @(*) begin
    // Default no hazard
    stall       = 1'b0;
    PCWrite     = 1'b1;
    IF_ID_Write = 1'b1;

    // Check for Load-Use Hazard:
    // If current EX stage instruction is a load (MemRead),
    // and the following ID stage instruction uses the loaded register as a source,
    // we have a hazard and must stall.
    if (ID_EX_MemRead && ((ID_EX_Rd == IF_ID_Rs1) || (ID_EX_Rd == IF_ID_Rs2))) begin
        stall       = 1'b1;   // Insert stall (pipeline bubble)
        PCWrite     = 1'b0;   // Prevent PC from updating
        IF_ID_Write = 1'b0;   // Prevent IF/ID register from updating
    end
end

endmodule
