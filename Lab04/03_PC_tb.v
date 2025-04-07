`timescale 1ns / 1ps

module tb_pc;

    parameter PC_WIDTH = 32;

    // Inputs
    reg clk;
    reg reset;
    reg PCSrc;
    reg [PC_WIDTH-1:0] ImmExt;

    // Outputs
    wire [PC_WIDTH-1:0] PC;
    wire [PC_WIDTH-1:0] PCPlus4;
    wire [PC_WIDTH-1:0] PCTarget;

    // Instantiate the PC module
    pc #(.PC_WIDTH(PC_WIDTH)) uut (
        .clk(clk),
        .reset(reset),
        .PCSrc(PCSrc),
        .ImmExt(ImmExt),
        .PC(PC),
        .PCPlus4(PCPlus4),
        .PCTarget(PCTarget)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Initialization
    initial begin
        clk = 0;
        reset = 1;
        PCSrc = 0;
        ImmExt = 32'd0;

        #10;
        reset = 0;

        // 1. Normal increment: PC should go 0 → 4 → 8 ...
        PCSrc = 0;
        repeat(4) begin
            #10 display_values("PC increment");
        end

        // 2. Branching: PC should jump by ImmExt
        ImmExt = 32'd16; // Jump forward by 16
        PCSrc = 1;
        #10 display_values("Branch Taken (+16)");

        PCSrc = 0;
        #10 display_values("Back to increment");

        // 3. Branching again
        ImmExt = -16; // Jump back by 16
        PCSrc = 1;
        #10 display_values("Branch Taken (-16)");

        // 4. Reset and check again
        reset = 1;
        #10;
        reset = 0;
        PCSrc = 0;
        ImmExt = 0;
        #10 display_values("Reset + Increment");

        $finish;
    end

    // Display task
    task display_values(input [1023:0] label);
    begin
        $display("=== %s ===", label);
        $display("Time      : %t", $time);
        $display("PC        : %0d", PC);
        $display("PCPlus4   : %0d", PCPlus4);
        $display("PCTarget  : %0d", PCTarget);
        $display("PCSrc     : %b", PCSrc);
        $display("ImmExt    : %0d", ImmExt);
        $display("------------------------------");
    end
    endtask

endmodule
