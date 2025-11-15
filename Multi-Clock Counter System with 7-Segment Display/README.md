# Clock-Divided Multi-Counter System with 7-Segment Display (Verilog, Basys3 FPGA)

This project implements a clock-driven digital system featuring up/down counters, clock division, edge detection, a ring counter, and a multiplexed 7-segment display interface. The design uses hierarchical modules to create a responsive counter system that updates based on push-button input and displays values across multiple digits.

## Features
- **Clock divider module** (`labCnt_clks.v`) to generate slow, human-visible update rates  
- **4-bit and 16-bit up/down counters** (`countUD4L.v`, `countUD16L.v`)  
- **Edge detector** (`edge_detector.v`) for clean and debounced button inputs  
- **Ring counter** (`ring_counter.v`) for digit selection / time-multiplexing  
- **Hex-to-7-segment decoder** (`hex7seg.v`) for visual output  
- **Selector/multiplexer logic** (`selector.v`)  
- Fully integrated top-level design (`Top_Module.v`)  

## Purpose
This lab demonstrates core digital systems concepts including clock division, synchronous design, counters, input edge detection, state sequencing, and multiplexed 7-segment display control. It highlights hierarchical Verilog coding and modular hardware design for FPGA-based systems.

## Files
- `labCnt_clks.v` – Clock divider  
- `countUD4L.v`, `countUD16L.v` – Up/down counters  
- `edge_detector.v` – Push-button edge detection  
- `ring_counter.v` – Active-digit rotation  
- `selector.v` – Multiplexing logic  
- `hex7seg.v` – Segment decoder  
- `Top_Module.v` – Integrated system  
- `testTC.v` – Testbench for counter behavior  

## Tools
- Vivado 2023.2  
- Basys3 (Artix-7) FPGA  
- Verilog HDL  
