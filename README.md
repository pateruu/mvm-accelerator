# Matrix-Vector Multiplication (MVM) Engine

## Overview
An **8-lane matrix-vector multiplication (MVM) accelerator** in SystemVerilog inspired by Microsoft BrainWave.  
Each lane uses **8 DSP blocks** for parallel multiplications, with pipelined dot product and accumulation units.

## Features
- 8-lane parallel MVM architecture.
- 8 DSP blocks per lane for high throughput.
- FSM-based control for sequencing memory reads and coordinating accumulation.
- Verified correctness with a parameterized testbench.
- Achieves **150+ MHz throughput** on FPGA (Vivado synthesis).

## Usage
1. Open in **Vivado** 
2. Run synthesis and implementation.
3. Run simulation with the testbench in `tb/` to verify functionality.
