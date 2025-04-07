module riscv_adder #(
    parameter DATA_WIDTH = 32
)(
    input wire clk,
    input wire reset,
    input wire [DATA_WIDTH-1:0] in_a,
    input wire [DATA_WIDTH-1:0] in_b,
    output reg [DATA_WIDTH-1:0] out_y
);

    always @(posedge clk) begin
        if (reset)
            out_y <= {DATA_WIDTH{1'b0}};
        else
            out_y <= in_a + in_b;
    end

endmodule
