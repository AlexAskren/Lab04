## 🚀 Pipeline Control Module Summary

| Module Name               | Purpose                                                                 | Inputs                                                                                      | Outputs                                                           | Integration Point                                         |
|---------------------------|-------------------------------------------------------------------------|---------------------------------------------------------------------------------------------|--------------------------------------------------------------------|------------------------------------------------------------|
| **Forwarding Unit**       | Resolves data hazards by forwarding ALU results from later pipeline stages | - `ID_EX_Rs1`, `ID_EX_Rs2`<br>- `EX_MEM_Rd`, `MEM_WB_Rd`<br>- `EX_MEM_RegWrite`, `MEM_WB_RegWrite` | - `ForwardA`, `ForwardB` (2-bit MUX control signals)               | Before ALU in EX stage, selects correct operand inputs    |
| **Hazard Detection Unit** | Detects load-use hazards; stalls pipeline if necessary                  | - `ID_EX_MemRead`, `ID_EX_Rd`<br>- `IF_ID_Rs1`, `IF_ID_Rs2`                                 | - `stall`<br>- `PCWrite`, `IF_ID_Write` (controls pipeline enable) | Between ID and EX stages; affects IF/ID, PC, and ID/EX    |
| **Branch Flush Unit**     | Flushes IF, ID, and EX pipeline registers on branch misprediction        | - `branch_taken` (from EX/MEM)<br>- `predicted_taken` (from IF)                             | - `flush_IF_ID`, `flush_ID_EX`, `flush_EX_MEM`                    | On branch misprediction; clears pipeline stages            |
| **Branch Prediction Unit**| Predicts if a branch will be taken (2-bit FSM predictor)                | - `clk`, `reset`<br>- `branch_resolved`, `branch_taken_actual`                             | - `branch_predict` (1: taken, 0: not taken)                        | Used in IF stage PC logic; updated in MEM stage            |

---

## 🧩 Integration Flow

1. **IF Stage**  
   - Use `branch_predict` to choose `PC + 4` or `branch_target`.
   - If `mispredicted`, flush using `flush_IF_ID`.

2. **ID Stage**  
   - Forward `Rs1`, `Rs2` to Hazard Detection Unit and Forwarding Unit.
   - Stall IF/ID register and PC if load-use hazard detected.

3. **EX Stage**  
   - ALU inputs selected via `ForwardA`, `ForwardB` from Forwarding Unit.
   - Branch comparator computes `branch_taken_actual`.

4. **MEM Stage**  
   - Send `branch_taken_actual` to Branch Prediction Unit to update FSM.
   - Use `branch_taken` vs `predicted_taken` to determine flush.

