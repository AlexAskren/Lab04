module register_file #(
    parameter REG_ADDR_WIDTH = 5,                     // Address width for 32 registers
    parameter REG_DATA_WIDTH = 32,                    // Each register is 32 bits wide
    parameter REG_COUNT = (1 << REG_ADDR_WIDTH)       // Number of registers = 2^addr_width
)(
    input wire clk,
    input wire rst,                                   // Active-high synchronous reset
    input wire WE3,                                   // Write enable
    input wire [REG_ADDR_WIDTH-1:0] A1,               // Read register 1 address
    input wire [REG_ADDR_WIDTH-1:0] A2,               // Read register 2 address
    input wire [REG_ADDR_WIDTH-1:0] A3,               // Write register address
    input wire [REG_DATA_WIDTH-1:0] WD3,              // Write data
    output wire [REG_DATA_WIDTH-1:0] RD1,             // Read data 1
    output wire [REG_DATA_WIDTH-1:0] RD2              // Read data 2
);

    // Declare the register array
    reg [REG_DATA_WIDTH-1:0] Register [0:REG_COUNT-1];
    integer i;

    // Synchronous write and reset
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < REG_COUNT; i = i + 1)
                Register[i] <= {REG_DATA_WIDTH{1'b0}};
        end
        else if (WE3 && A3 != {REG_ADDR_WIDTH{1'b0}}) begin
            Register[A3] <= WD3; // Do not write to register x0
        end
    end

    // Combinational read
    assign RD1 = (rst) ? {REG_DATA_WIDTH{1'b0}} : Register[A1];
    assign RD2 = (rst) ? {REG_DATA_WIDTH{1'b0}} : Register[A2];


endmodule
