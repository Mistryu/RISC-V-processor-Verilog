# Pipelined RISC-V Processor Implementation

This directory contains the implementation of a 5-stage pipelined RISC-V processor.

## Architecture

The processor implements a classic 5-stage pipeline:

1. **IF (Instruction Fetch)**: Fetches instructions from instruction memory
2. **ID (Instruction Decode)**: Decodes instructions, reads register file, generates control signals
3. **EX (Execute)**: Performs ALU operations
4. **MA (Memory Access)**: Accesses data memory for loads and stores
5. **WB (Write Back)**: Writes results back to register file

## Module Structure

### Pipeline Registers

- `pipeline_reg_if_id.v`: IF/ID pipeline register
- `pipeline_reg_id_ex.v`: ID/EX pipeline register
- `pipeline_reg_ex_ma.v`: EX/MA pipeline register
- `pipeline_reg_ma_wb.v`: MA/WB pipeline register

### Control and main file

- `controller.v`: Main controller generating control signals
- `rv_pipelined.v`: Top-level module connecting all stages

## Control Signals

See `Table_controller.csv` for the complete controller truth table showing all control signals for each instruction type.

## Files

- `rv_pipelined.v`: Top-level processor module
- `controller.v`: Control unit
- `Table_controller.csv`: Controller truth table
- `testbench.v`: Testbench for simulation
- `program.hex`: Instruction memory initialization file

## Usage

1. Compilation

   ```bash
   iverilog -o riscv_pipelined testbench.v rv_pipelined.v *.v
   ```

2. Run simulation:

   ```bash
   vvp riscv_pipelined
   ```

3. View waveforms:
   ```bash
   gtkwave riscv_pipelined.vcd
   ```
