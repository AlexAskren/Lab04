module instr_mem #(
    parameter MEM_DEPTH = 2048  // Total memory in words (1024 for instr, 1024 for data)
)(
    input wire clk,
    input wire reset,
    input wire [31:0] addr, // Byte address
    output reg [31:0] instr
);

    reg [31:0] memory [0:MEM_DEPTH-1];  // Unified memory

    // Load instruction contents only into the first half
    initial begin
        $readmemh("instruction_rom_single_dp.txt", memory, 0, (MEM_DEPTH/2)-1);
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            instr <= 32'h0;
        else begin
            if (addr[11:2] < (MEM_DEPTH/2))  // Instruction memory check
                instr <= memory[addr[11:2]];
            else
                instr <= 32'h0; // Invalid instruction fetch
        end
    end
endmodule
