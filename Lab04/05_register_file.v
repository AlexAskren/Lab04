// Updated register_file with stall support
module register_file #(
    parameter REG_ADDR_WIDTH = 5,
    parameter REG_DATA_WIDTH = 32,
    parameter REG_COUNT = (1 << REG_ADDR_WIDTH)
)(
    input wire clk,
    input wire rst,
    input wire stall,
    input wire WE3,
    input wire [REG_ADDR_WIDTH-1:0] A1,
    input wire [REG_ADDR_WIDTH-1:0] A2,
    input wire [REG_ADDR_WIDTH-1:0] A3,
    input wire [REG_DATA_WIDTH-1:0] WD3,
    output wire [REG_DATA_WIDTH-1:0] RD1,
    output wire [REG_DATA_WIDTH-1:0] RD2
);

    reg [REG_DATA_WIDTH-1:0] Register [0:REG_COUNT-1];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < REG_COUNT; i = i + 1)
                Register[i] <= {REG_DATA_WIDTH{1'b0}};
        end else if (!stall && WE3 && A3 != 0) begin
            Register[A3] <= WD3;
            $display("[REGFILE] Write: x%0d = 0x%08h", A3, WD3);
        end
    end

    assign RD1 = (A1 == 0) ? 32'b0 : Register[A1];
    assign RD2 = (A2 == 0) ? 32'b0 : Register[A2];

endmodule
