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
