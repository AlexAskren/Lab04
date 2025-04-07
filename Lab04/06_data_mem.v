module mem_data #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter MEM_DEPTH  = 2048  // Total memory in words
)(
    input clk,
    input reset,
    input rd_en,
    input wr_en,
    input [ADDR_WIDTH-1:0] addr,            // Byte address
    input [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout
);

    // Memory array: each entry is a 32-bit word (word-aligned by default)
    reg [DATA_WIDTH-1:0] memory [0:MEM_DEPTH-1];

    // Calculate word index: drop 2 LSBs for 4-byte alignment
    wire [$clog2(MEM_DEPTH)-1:0] word_addr = addr[ADDR_WIDTH-1:2];

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = MEM_DEPTH/2; i < MEM_DEPTH; i = i + 1)
                memory[i] <= 0;
            dout <= 0;
        end else begin
            // Write operation to data memory region (second half)
            if (wr_en && word_addr >= (MEM_DEPTH/2) && word_addr < MEM_DEPTH) begin
                memory[word_addr] <= din;
                $display("[WRITE] Addr=0x%08h (word=%0d), Data=0x%08h", addr, word_addr, din);
            end

            // Read operation from data memory region
            if (rd_en && word_addr >= (MEM_DEPTH/2) && word_addr < MEM_DEPTH) begin
                dout <= memory[word_addr];
                $display("[READ] Addr=0x%08h (word=%0d), Data=0x%08h", addr, word_addr, memory[word_addr]);
            end else if (rd_en) begin
                dout <= 0;
                $display("[READ BLOCKED] Invalid Addr=0x%08h (word=%0d)", addr, word_addr);
            end
        end
    end

    // Optional memory dump after 1000 ns
    initial begin
        #1000;
        $writememh("data_memory_dump.txt", memory, MEM_DEPTH/2, MEM_DEPTH-1);
    end

endmodule
