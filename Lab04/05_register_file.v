module register_file #(
    parameter REG_ADDR_WIDTH = 5,       // 32 registers (5-bit address)
    parameter REG_DATA_WIDTH = 32,      // 32-bit data width
    parameter REG_COUNT = (1 << REG_ADDR_WIDTH)
)(
    input wire clk,
    input wire rst,                     // Synchronous reset
    input wire stall,                   // Hazard stall signal — disables write if asserted
    input wire WE3,                     // Write enable
    input wire [REG_ADDR_WIDTH-1:0] A1, // Read address 1
    input wire [REG_ADDR_WIDTH-1:0] A2, // Read address 2
    input wire [REG_ADDR_WIDTH-1:0] A3, // Write address
    input wire [REG_DATA_WIDTH-1:0] WD3,// Write data
    output wire [REG_DATA_WIDTH-1:0] RD1,// Read data 1
    output wire [REG_DATA_WIDTH-1:0] RD2 // Read data 2
);

    // Register file memory
    reg [REG_DATA_WIDTH-1:0] Register [0:REG_COUNT-1];
    integer i;

    // Synchronous write with reset and stall check
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < REG_COUNT; i = i + 1)
                Register[i] <= {REG_DATA_WIDTH{1'b0}};
        end else if (!stall && WE3 && A3 != 0) begin
            Register[A3] <= WD3;
        end
    end

    // Combinational reads
    assign RD1 = (A1 == 0) ? 32'b0 : Register[A1];
    assign RD2 = (A2 == 0) ? 32'b0 : Register[A2];

endmodule
