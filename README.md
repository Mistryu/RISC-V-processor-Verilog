# RISC-V Processor Implementation

A single-cycle RISC-V processor implementation supporting a subset of RV32I instructions.

## Building and Running

```bash
iverilog -o riscv_sim testbench.v main.v Program_counter.v add.v instructoin_memory.v controller.v register_file.v sign_extender.v mux.v ALU.v add_pc_imm.v Data_memory.v
```

```bash
vvp riscv_sim
```
