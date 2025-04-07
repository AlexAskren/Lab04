// Parameterized Program Counter Module (PCPlus4 is internal)
module pc_no_out_plus4 #(
    parameter PC_WIDTH = 32  // Default PC/data width
)(
    input wire clk,
    input wire reset,
    input wire PCSrc,                          // Branch control
    input wire [PC_WIDTH-1:0] ImmExt,          // Sign-extended immediate
    output reg [PC_WIDTH-1:0] PC,              // Current PC value
    output wire [PC_WIDTH-1:0] PCTarget        // PC + ImmExt (branch target)
);

    // Internal wires
    wire [PC_WIDTH-1:0] PCPlus4;
    wire [PC_WIDTH-1:0] PCNext;

    // Adder: PC + 4 (aligned addition, internal only)
    assign PCPlus4 = PC + 32'd4;

    // Branch target address
    assign PCTarget = PC + ImmExt;

    // PC selection
    assign PCNext = (PCSrc) ? PCTarget : PCPlus4;

    // Register logic
    always @(posedge clk) begin
        if (reset)
            PC <= {PC_WIDTH{1'b0}};
        else
            PC <= PCNext;
    end

endmodule
