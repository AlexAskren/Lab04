/*
The design of the branch operation requires the next PC to be determined by the flags from the ALU result. To
 find the appropriate way to obtain the comparison results for the six branch operations, a straightforward approach
 is to refer to how the ARM Cortex-M4F defines its conditional operations. This reference should help you identify
 the correct implementation.
 Note that the branch decision is determined after the execution of the ALU, so you need to ensure that the branch
 control signal is properly connected to the MUX before the PC adder, which calculates the current PC with the
 immediate value from the branch instruction.
 As a side note, the figure shown above only considers the zero flag for convenience; however, you may need other
 flags to assist with the comparison and branching process.
 */

module branch_control #(
    // Parameters for flexible instruction and offset width
    parameter INSTR_WIDTH = 32,         // Instruction width (default to 32 bits)
    parameter OFFSET_LEN = 32           // Length of the branch offset (default to 12 bits for 12-bit signed offsets)
)(
    input wire clk,                     // Clock signal
    input wire reset,                   // Reset signal
    input wire [OFFSET_LEN-1:0] offset, // Branch offset (from instruction)
    input wire [INSTR_WIDTH-1:0] PC,    // Current program counter
    input wire zero,                    // Zero flag (from ALU comparison)
    input wire branch,                  // Branch control signal (determines if branch should happen)
    output reg [INSTR_WIDTH-1:0] target // Target address for branch
);

    // Internal wire for calculating branch target (PC + offset)
    wire [INSTR_WIDTH-1:0] branch_target;   // Target address for the branch
    

    // Calculate the branch target address (PC + offset)
    assign branch_target = PC + {{(INSTR_WIDTH-OFFSET_LEN){offset[OFFSET_LEN-1]}}, offset}; // Sign extend offset to full width

    // Branch decision logic: Branch taken if 'branch' signal is active and the comparison is true (zero flag set)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            target = {INSTR_WIDTH{1'b0}};  // Reset to 0
        end else begin
            if (branch && zero) begin
                if (offset[OFFSET_LEN-1]) begin
                    // If offset is negative (sign bit is 1), add 1
                    target = branch_target ;
                end else begin
                    // Positive offset
                    target = branch_target;
                end
            end else begin
                // Not branching — go to next instruction
                target <= PC + 1;
            end
        end
    end

endmodule

    
        
        