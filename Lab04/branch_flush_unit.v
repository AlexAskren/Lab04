module branch_control_flush #(
    parameter FLUSH_EX_MEM = 1  // Set to 1 if EX_MEM stage should be flushed on misprediction
)(
    input  wire clk,
    input  wire reset,
    input  wire branch_taken,       // Final decision: branch is taken (from EX or MEM)
    input  wire predicted_taken,    // Initial prediction: branch was predicted taken (from IF stage)

    output reg flush_IF_ID,         // Flush IF/ID stage
    output reg flush_ID_EX,         // Flush ID/EX stage
    output reg flush_EX_MEM         // Optional: Flush EX/MEM (based on parameter)
);

    reg mispredicted;

    always @(*) begin
        mispredicted = (branch_taken != predicted_taken);

        flush_IF_ID  = mispredicted;
        flush_ID_EX  = mispredicted;
        flush_EX_MEM = (FLUSH_EX_MEM && mispredicted);
    end

endmodule
