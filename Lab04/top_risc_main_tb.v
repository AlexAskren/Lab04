`timescale 1ns / 1ps

module tb_top_pipelined_riscv;

    reg clk;
    reg reset;

    // Instantiate the DUT (Design Under Test)
    top_pipelined_riscv dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation: 10ns period
    always begin
        #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        $display("Starting pipelined RISC-V simulation...");
        clk = 0;
        reset = 1;
        #20;
        reset = 0;

        // Let it run long enough to execute a program
        #1000;

        $display("Simulation complete.");
        $finish;
    end

    // Dump waveform
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top_pipelined_riscv);
    end

endmodule
