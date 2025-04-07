// Testbench for top_single_cycle_riscv
//`timescale 1ns / 1ps

module top_single_cycle_riscv_tb;
    reg clk;
    reg reset;

    // Instantiate the top-level module
    top_single_cycle_riscv uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Reset and simulation control
    initial begin
        $display("Starting RISC-V Single Cycle CPU Simulation...");

        // Initialize reset
        reset = 1;
        #20;
        reset = 0;

        // Run for sufficient time to process all instructions
        #1000;
        
        $display("Simulation finished.");
        $stop;
    end

endmodule
