module instr_mem #(
    parameter MEM_DEPTH = 2048  // Total memory in words (1024 for instr, 1024 for data)
)(
    input wire clk,
    input wire reset,
    input wire [31:0] addr,      // Byte address
    output reg [31:0] instr      // Output instruction
);

    reg [31:0] memory [0:MEM_DEPTH-1];  // Unified memory array

    // Load instructions into first half (IMEM region)
    initial begin
        $readmemh("instruction_rom_single_dp.txt", memory, 0, (MEM_DEPTH/2) - 1);
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instr <= 32'h00000013; // NOP on reset (ADDI x0, x0, 0)
        end else begin
            if (addr[31:2] < (MEM_DEPTH / 2)) begin
                instr <= memory[addr[31:2]]; // Word-aligned access
                $display("[IMEM] PC=0x%08h => INSTR=0x%08h", addr, memory[addr[31:2]]);
            end else begin
                instr <= 32'h00000013; // NOP on invalid access
                $display("[IMEM] Invalid PC=0x%08h => NOP inserted", addr);
            end
        end
    end

endmodule
