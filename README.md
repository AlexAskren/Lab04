# Lab04

## top_riscv_main
- **Processor**
  - DONE HDL design 1: ALU (EX stage) - `CLK` __(deep)__
  - DONE HDL design 2: Instruction Decode (ID stage) - `CLK` __(sank)__
  - DONE HDL design 3: Program Counter (IF stage) - `NO CLK` __(deep)__
  - DONE HDL design 5: Register File (ID stage) - `CLK` __(deep)__
  - DONE HDL design 7: Control Block - ALU Operation Reorganize (ID/EX stage) - `CLK`  __(alex)__
  - DONE HDL design 8: Instruction Control Logic Branch and Jump (ID/EX stages) - `CLK` __(alex)__
  - HDL design 9: Miscellaneous Designs - `CLK` __()__

- **Instruction Memory**
  - DONE HDL design 4: Instruction Memory File (IF stage) - `NO CLK` __(sank)__

- **Data Memory**
  - DONE HDL design 6: Data Memory File (MEM stage) - `NO CLK` __(alex)__

## Pipeline Flow
1. **Program Counter** (HDL design 3) → 
2. **Instruction Decode** (HDL design 2), **Register File** (HDL design 5), **ALU Operation Reorganize** (HDL design 7), **Branch/Jump Logic** (HDL design 8) → 
3. **ALU** (HDL design 1) → 
4. **Data Memory File** (HDL design 6)
