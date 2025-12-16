# RISC-V Processor Implementation

This repository contains two implementations of a RISC-V processor:

## Folder Structure

### `single_cycle/`

Contains the **single-cycle RISC-V processor** implementation:

- All instructions execute in a single clock cycle
- Separate instruction and data memories
- Dedicated adders for PC computation
- Simple controller with combinational logic

### `multi_cycle/`

Contains the **multi-cycle RISC-V processor** implementation:

- Instructions execute across multiple clock cycles
- Unified memory for instructions and data
- FSM-based controller with state machine
- ALU-based PC computation
- Pipeline registers for multi-cycle operation

## Files Organization

### Single-Cycle Files:

- `main.v` - Top-level single-cycle processor
- `controller.v` - Single-cycle controller
- `instructoin_memory.v` - Instruction memory
- `Data_memory.v` - Data memory
- `Program_counter.v` - Program counter
- `add.v` - PC+4 adder
- `add_pc_imm.v` - PC+imm adder
- `register_file.v`, `sign_extender.v`, `mux.v`, `ALU.v` - Shared components
- `testbench.v` - Single-cycle testbench
- `program.hex` - Test program

### Multi-Cycle Files:

- `rv_mc.v` - Top-level multi-cycle processor (to be created)
- `Controller2.0.v` - Combined controller (FSM + Decoders)
- `FSM.v` - Finite State Machine
- `ALU_Decoder.v` - ALU control decoder
- `Instruction_Decoder.v` - Instruction decoder
- `Mem.v` - Unified memory module
- `register.v` - Generic register module
- `register_file.v`, `sign_extender.v`, `mux.v`, `ALU.v` - Shared components
- `testbench.v` - Multi-cycle testbench
- `program.hex` - Test program

## Building and Running

See the README.md file in each folder for specific build instructions.
