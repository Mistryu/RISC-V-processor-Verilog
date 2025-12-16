# RISC-V Multi-Cycle Processor

Multi-cycle RISC-V processor supporting RV32I subset (23 instructions: R-type, I-type, lw, sw, jal, lui).

## Build & Run

```bash
iverilog -o riscv_mul testbench.v rv_mc.v Controller2.0.v FSM.v ALU_Decoder.v Instruction_Decoder.v Mem.v register.v register_file.v sign_extender.v mux.v MUX3.v ALU.v
vvp riscv_mul
```

## Components

- **rv_mc.v**: Top-level processor module
- **Controller2.0.v**: FSM + Instruction Decoder + ALU Decoder
- **FSM.v**: Multi-cycle state machine controller
- **ALU.v**: Arithmetic/logic unit
- **ALU_Decoder.v**: ALU control signal decoder
- **Instruction_Decoder.v**: Instruction field decoder
- **Mem.v**: Unified instruction/data memory
- **register_file.v**: 32-register file
- **register.v**: Generic pipeline register
- **sign_extender.v**: Immediate extension (I/S/B/U/J-type)
- **mux.v**: 2-to-1 multiplexer
- **MUX3.v**: 3-to-1 multiplexer
- **testbench.v**: Simulation testbench
