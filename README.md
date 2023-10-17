# MIPS Pipeline Processor

This Verilog implementation represents a simplified MIPS 32-bit pipeline processor. The design is based on principles discussed in the "Verilog Book" by Samir Palnitkar, "Computer Organization" by Patterson and Hennessy, and the course "Hardware Modeling Using Verilog" by Dr. Indranil Sengupta.

## Overview

The MIPS pipeline processor is designed with separate clocks (`clk1` and `clk2`) for proper computation. It includes key components such as memory banks (`Mem`), register banks (`regb`), various latches (`IF_ID_IR`, `ID_EX_IR`, `EX_MEM_IR`, `MEM_WB_IR`, etc.), and flags (`HALTED`, `TAKEN_BRANCH`). The pipeline consists of stages for Instruction Fetch (`IF`), Instruction Decode (`ID`), Execute (`EX`), Memory Access (`MEM`), and Write Back (`WB`).

## Conventions

The following conventions are used for pipeline stages:
- **IF:** Instruction Fetch Cycle
- **ID:** Instruction Decode Cycle
- **EX:** Execute Cycle
- **MEM:** Memory Access Cycle
- **WB:** Write Back Cycle

## Instruction Types and Opcodes

The MIPS instructions are categorized into different types, and opcodes are assigned accordingly. Some key parameters include:
- **ALU Operations:** ADD, SUB, AND, OR, SLT, MUL
- **Memory Operations:** LW, SW
- **Immediate Operations:** ADDI, SUBI, SLTI
- **Branch Operations:** BEQZ, BNEQZ
- **Halt Operation:** HLT

## Pipeline Stages

### 1. Instruction Fetch (`IF`)

In this stage, the processor fetches the next instruction. It also handles branching instructions and updates the program counter (`PC`) accordingly.

### 2. Instruction Decode (`ID`)

This stage decodes the fetched instruction, reads data from registers, and prepares the necessary values for the next stage. It also determines the type of instruction.

### 3. Execute (`EX`)

The execute stage performs the computation based on the type of instruction. It calculates the ALU output and other relevant values.

### 4. Memory Access (`MEM`)

This stage handles memory operations. It may perform memory read (`LOAD`), memory write (`STORE`), or simply forward the ALU output.

### 5. Write Back (`WB`)

The write back stage updates the register file based on the results obtained from the previous stages. It also checks for the halt condition.

## Halt and Branch Handling

The processor includes flags (`HALTED`, `TAKEN_BRANCH`) to efficiently manage the execution of halt instructions and branching conditions.

## Simulation and Testing

The Verilog code is designed for simulation and testing. Proper clock edges (`posedge`) are used to synchronize operations in each stage.

## Contributors

- [Your Name]

## References

1. Samir Palnitkar. "Verilog Book."
2. John L. Hennessy and David A. Patterson. "Computer Organization and Design: The Hardware/Software Interface."
3. Dr. Indranil Sengupta. "Hardware Modeling Using Verilog" [Include course details, if available].

## License

This MIPS pipeline processor implementation is provided under the [insert license type, e.g., MIT License]. See the `LICENSE` file for more details.
