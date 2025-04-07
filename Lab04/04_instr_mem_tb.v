module instr_mem_tb;

    reg clk;
    reg reset;
    reg [31:0] addr;
    wire [31:0] instr;
    integer i;

    // Instantiate the instr_mem module
    instr_mem uut (
        .clk(clk),
        .reset(reset),
        .addr(addr),
        .instr(instr)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        addr = 32'b0;

        // Release reset after a short period
        #10 reset = 0;

        // Read instructions from the file and store them in the instruction memory
        $readmemh("instruction_rom_single_dp.txt", uut.instr_mem);  // Load instruction memory inside the module

        // Display the instruction memory content
        $display("Instruction memory content:");
        
        for (i = 0; i < 1024; i = i + 1) begin
            $display("instr_mem[%d] = %h", i, uut.instr_mem[i]);
        end

        // Read instructions from different addresses
        addr = 32'h0;
        #10 addr = 32'h4;
        #10 addr = 32'h8;
        #10 addr = 32'hC;
        #10 addr = 32'h10;
        #10 addr = 32'h14;
        #10 addr = 32'h18;
        #10 addr = 32'h1C;
        #10 addr = 32'h20;
        #10 addr = 32'h24;
        #10 addr = 32'h28;
        #10 addr = 32'h2C;
        #10 addr = 32'h30;
        #10 addr = 32'h34;
        #10 addr = 32'h38;
        #10 addr = 32'h3C;
        #10 addr = 32'h40;
        #10 addr = 32'h44;
        #10 addr = 32'h48;
        #10 addr = 32'h4C;
        #10 addr = 32'h50;
        #10 addr = 32'h54;
        #10 addr = 32'h58;
        #10 addr = 32'h5C;
        #10 addr = 32'h60;
        #10 addr = 32'h64;

        // End of simulation
        $finish;
    end
endmodule
