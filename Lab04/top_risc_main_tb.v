// Testbench for top_pipelined_riscv
`timescale 1ns / 1ps

module tb_top_pipelined_riscv;
    reg clk;
    reg reset;

    // Instantiate the DUT
    top_pipelined_riscv dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #5 clk = ~clk;  // 10ns period

    // Initial setup
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_top_pipelined_riscv);

        clk = 0;
        reset = 1;
        #20;
        reset = 0;

        // Run long enough to process instructions
        #1000;

        $display("Simulation completed.");
        $finish;
    end
endmodule
