module branch_control_flush (
    input wire clk,
    input wire reset,
    input wire branch_taken,             // Final decision: branch is taken (from EX or MEM)
    input wire predicted_taken,         // Initial prediction: branch was predicted taken (from IF stage)

    output reg flush_IF_ID,             // Flush IF/ID stage
    output reg flush_ID_EX,             // Flush ID/EX stage
    output reg flush_EX_MEM             // Optional: Flush EX/MEM (useful in mispredict recovery)
);

    reg mispredicted;

    always @(*) begin
        // Determine if there's a branch misprediction
        mispredicted = (branch_taken != predicted_taken);

        // Flush all instructions in IF, ID, EX stages if mispredicted
        if (mispredicted) begin
            flush_IF_ID  = 1'b1;
            flush_ID_EX  = 1'b1;
            flush_EX_MEM = 1'b1;  // Optional — depends on your control/data path
        end else begin
            flush_IF_ID  = 1'b0;
            flush_ID_EX  = 1'b0;
            flush_EX_MEM = 1'b0;
        end
    end

endmodule
