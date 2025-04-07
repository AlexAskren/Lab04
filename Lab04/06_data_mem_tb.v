module tb_mem_data;

    // Testbench signals
    reg clk;                            // Clock signal
    reg reset;                          // Reset signal
    reg wr_en;                          // Write enable signal
    reg [31:0] addr;                    // Address for memory access
    reg [31:0] din;                     // Data to be written
    wire [31:0] dout;                   // Data read from memory

    // Instantiate the memory module (with default parameters)
    mem_data #(
        .MEM_SIZE(1024),
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32)
    ) uut (
        .clk(clk),
        .reset(reset),
        .wr_en(wr_en),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    // Clock generation (period = 10)
    always begin
        #5 clk = ~clk;  // Toggle the clock every 5 time units
    end

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;
        wr_en = 0;
        addr = 0;
        din = 0;

        // Apply reset
        reset = 1;
        #10;  // Hold reset for 10 time units
        reset = 0;
        #10;

        // Test 1: Write data to memory at address 0
        addr = 32'h0;
        din = 32'hA5A5A5A5;  // Arbitrary test data
        wr_en = 1;
        #10;  // Wait for one clock cycle

        // Test 2: Read back data from memory at address 0
        wr_en = 0;
        #10;
        if (dout !== 32'hA5A5A5A5) begin
            $display("Test 2 failed: Expected 32'hA5A5A5A5, got %h", dout);
        end else begin
            $display("Test 2 passed: Read value %h from address 0", dout);
        end

        // Test 3: Write data to memory at address 4 (aligned address)
        addr = 32'h4;
        din = 32'h5A5A5A5A;  // Different test data
        wr_en = 1;
        #10;  // Wait for one clock cycle

        // Test 4: Read back data from memory at address 4
        wr_en = 0;
        #10;
        if (dout !== 32'h5A5A5A5A) begin
            $display("Test 4 failed: Expected 32'h5A5A5A5A, got %h", dout);
        end else begin
            $display("Test 4 passed: Read value %h from address 4", dout);
        end

        // Test 5: Invalid read (address out of bounds)
        addr = 32'h1000;  // Address beyond MEM_SIZE (assuming MEM_SIZE = 1024)
        wr_en = 0;
        #10;
        if (dout !== 32'b0) begin
            $display("Test 5 failed: Expected 0, got %h", dout);
        end else begin
            $display("Test 5 passed: Read value 0 from invalid address %h", addr);
        end

        // Test 6: Write to a new address (address 8)
        addr = 32'h8;
        din = 32'hDEADBEEF;
        wr_en = 1;
        #10;  // Wait for one clock cycle

        // Test 7: Read back data from memory at address 8
        wr_en = 0;
        #10;
        if (dout !== 32'hDEADBEEF) begin
            $display("Test 7 failed: Expected 32'hDEADBEEF, got %h", dout);
        end else begin
            $display("Test 7 passed: Read value %h from address 8", dout);
        end

        // Test 8: Reset memory and check if it resets to 0
        reset = 1;
        #10;
        reset = 0;
        addr = 32'h0;  // Check if address 0 is reset
        wr_en = 0;
        #10;
        if (dout !== 32'b0) begin
            $display("Test 8 failed: Expected 0, got %h", dout);
        end else begin
            $display("Test 8 passed: Memory reset, read value 0 from address 0");
        end

        $finish;
    end

endmodule
