//`timescale 1ns / 1ps

/*
module riscv_Inst_Decode (
    input clk,
    input reset,
    input [31:0] Instr,                 // 32-bit RISC-V instruction
    output reg [4:0] src_reg_addr0,     // rs1
    output reg [4:0] src_reg_addr1,     // rs2
    output reg [4:0] dst_reg_addr,      // rd
    output reg [31:0] immediate_value,  // sign-extended immediate
    output reg MemWrite,
    output reg MemRead,
    output reg ALUSrc,
    output reg RegWrite,
    output reg Branch,
    output reg MemtoReg,
    output reg [1:0] ALUOp              // 2-bit ALUOp
    //Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite
    //Branch, MemWrite(0), 
);
*/

module riscv_Inst_Decode_tb;

    reg clk         = 0;
    reg reset       = 1;
    reg [31:0] Instr;

    wire [4:0] src_reg_addr0;
    wire [4:0] src_reg_addr1;
    wire [4:0] dst_reg_addr;
    wire [31:0] immediate_value;

    // Control signal outputs
    wire MemWrite;
    wire MemRead;
    wire ALUSrc;
    wire RegWrite;
    wire Branch;
    wire MemtoReg;
    wire [1:0] ALUOp;

    // Instantiate the riscv_Inst_Decode module
    riscv_Inst_Decode uut (
        .clk(clk),
        .reset(reset),
        .Instr(Instr),
        .src_reg_addr0(src_reg_addr0),
        .src_reg_addr1(src_reg_addr1),
        .dst_reg_addr(dst_reg_addr),
        .immediate_value(immediate_value),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Branch(Branch),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp)
    );

    // Clock Generation
    always #5 clk = ~clk;

    // Initialize signals
    initial begin
        clk = 0;
        reset = 1;
        Instr = 32'b0;
    end

    // Test sequence
    initial begin
        // Apply reset
        reset = 1;
        #20 reset = 0;

        // Test instructions
        Instr = 32'h80ff0337; // lui x6, 0x80FF0
        #20 display_values("lui x6, 0x80FF0");

        Instr = 32'h00800293; // addi x5, x0, 8
        #20 display_values("addi x5, x0, 8");

        Instr = 32'h00230393; // addi x7, x6, 2
        #20 display_values("addi x7, x6, 2");

        Instr = 32'h00628433; // add x8, x5, x6
        #20 display_values("add x8, x5, x6");

        Instr = 32'h405384b3; // sub x9, x7, x5
        #20 display_values("sub x9, x7, x5");

        Instr = 32'h02538433; // mul x8, x7, x5
        #20 display_values("mul x8, x7, x5");

        Instr = 32'h027394b3; // mulh x9, x7, x7
        #20 display_values("mulh x9, x7, x7");

        Instr = 32'h0273a4b3; // mulhsu x9, x7, x7
        #20 display_values("mulhsu x9, x7, x7");

        Instr = 32'h0273b4b3; // mulhu x9, x7, x7
        #20 display_values("mulhu x9, x7, x7");

        Instr = 32'h00534433; // xor x8, x6, x5
        #20 display_values("xor x8, x6, x5");

        Instr = 32'h00f2c493; // xori x9, x5, 15
        #20 display_values("xori x9, x5, 15");

        Instr = 32'h00536433; // or x8, x6, x5
        #20 display_values("or x8, x6, x5");

        Instr = 32'h00f2e493; // ori x9, x5, 15
        #20 display_values("ori x9, x5, 15");

        Instr = 32'h00537433; // and x8, x6, x5
        #20 display_values("and x8, x6, x5");

        Instr = 32'h00c2f493; // andi x9, x5, 12
        #20 display_values("andi x9, x5, 12");

        Instr = 32'h00931533; // sll x30, x6, x9
        #20 display_values("sll x30, x6, x9");

        Instr = 32'h00431593; // slli x11, x6, 4
        #20 display_values("slli x11, x6, 4");

        Instr = 32'h00935533; // srl x30, x6, x5
        #20 display_values("srl x30, x6, x5");

        Instr = 32'h00435593; // srli x11, x6, 4
        #20 display_values("srli x11, x6, 4");

        Instr = 32'h40935533; // sra x30, x6, x9
        #20 display_values("sra x30, x6, x9");

        Instr = 32'h40435593; // srai x11, x6, 4
        #20 display_values("srai x11, x6, 4");

        Instr = 32'h00532633; // slt x12, x6, x5
        #20 display_values("slt x12, x6, x5");

        Instr = 32'h00c2a693; // slti x13, x5, 12
        #20 display_values("slti x13, x5, 12");

        Instr = 32'h00533633; // sltu x12, x6, x5
        #20 display_values("sltu x12, x6, x5");

        Instr = 32'h0322b693; // sltiu x13, x5, 50
        #20 display_values("sltiu x13, x5, 50");

        // End simulation
        #50 $stop;
    end

    // Display task
    task display_values(input [1023:0] name);
    begin
        $display("=== %s ===", name);
        //$display("Instr       : %h", Instr);
        $display("Opcode      : %b", Instr[6:0]);
        $display("rs1         : %0d", src_reg_addr0);
        $display("rs2         : %0d", src_reg_addr1);
        $display("rd          : %0d", dst_reg_addr);
        $display("Immediate   : %d", immediate_value);
        $display("Control     : RegWrite=%b, MemRead=%b, MemWrite=%b, MemtoReg=%b, ALUSrc=%b, Branch=%b, ALUOp=%b",
                 RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, Branch, ALUOp);
        $display("");
    end
    endtask

endmodule
