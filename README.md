# Lab04

| Module / Stage                  | Pipeline (Design 1)                                         | Data Forwarding (Design 2)                                      | Hazard Detection (Design 3)                                  | Branch Flushing (Design 4)                                   | Branch Prediction (Design 5)                                  |
|---------------------------------|-------------------------------------------------------------|------------------------------------------------------------------|--------------------------------------------------------------|---------------------------------------------------------------|---------------------------------------------------------------|
| **Instruction Fetch (IF)**      | - Add IF/ID register<br>- Sequential PC logic               | -                                                                | - Add PC stall logic                                         | - Flush IF stage (replace with NOP) if mispredicted          | - Predict next PC (FSM-based)                                 |
| **Instruction Decode (ID)**     | - Add ID/EX register<br>- Forward control signals           | -                                                                | - Stall if load-use hazard detected (insert NOP)             | - Flush ID stage if branch mispredicted (insert NOP)         | -                                                              |
| **Execute (EX)**                | - Add EX/MEM register<br>- Pipeline ALU inputs/results      | - Add forwarding MUXes (ForwardA/B signals)                      | -                                                            | - Flush EX stage if branch mispredicted (insert NOP)         | - ALU verifies actual branch outcome                          |
| **Memory (MEM)**                | - Add MEM/WB register<br>- Sequential data memory           | - Provide forward path to ALU inputs from MEM stage              | -                                                            | - Determine branch outcome for flushing                      | - Update FSM with actual branch outcomes                      |
| **Write Back (WB)**             | - Complete register write-back logic                        | -                                                                | -                                                            | -                                                            | -                                                              |
| **Register File**               | - Add pipeline registers for data/address                   | - Integrate forwarding paths (from EX/MEM and MEM/WB)            | - Stall register updates during hazard conditions            | -                                                            | -                                                              |
| **Control Unit**                | - Store control signals in pipeline registers               | - Generate forwarding control signals                            | - Generate stall signals                                     | - Generate flush signals                                     | - Integrate prediction signals into pipeline stages            |
| **ALU**                         | - Pipeline synchronization                                  | - Inputs controlled by ForwardA/ForwardB signals                 | -                                                            | -                                                            | - Perform branch evaluation to confirm predictions             |
| **Forwarding Unit (new)**       | -                                                           | - Detect hazards & select forwarding sources                     | -                                                            | -                                                            | -                                                              |
| **Hazard Detection Unit (new)** | -                                                           | -                                                                | - Detect load-use hazards, stall IF/ID and PC                | -                                                            | -                                                              |
| **Branch Control & Flush (new)**| -                                                           | -                                                                | -                                                            | - Detect mispredictions, flush IF, ID, EX stages             | -                                                              |
| **Branch Prediction Unit (new)**| -                                                           | -                                                                | -                                                            | -                                                            | - FSM-based 2-bit prediction<br>- Update FSM with outcomes     |

## Summary of Modules to Add:

- **Pipeline Registers**
  - `IF/ID`
  - `ID/EX`
  - `EX/MEM`
  - `MEM/WB`

- **Control & Hazard Units**
  - `Forwarding Unit`
  - `Hazard Detection Unit`
  - `Branch Control & Flush Logic`
  - `Branch Prediction Unit (2-bit FSM)`

## Adjustments to Top-Level Module:

- Instantiate and connect pipeline registers and new control units.
- Route stall/flush signals appropriately between pipeline stages.
- Integrate forwarding unit outputs (`ForwardA`, `ForwardB`) into ALU inputs.
- Implement FSM-based branch prediction logic to influence PC updates.


