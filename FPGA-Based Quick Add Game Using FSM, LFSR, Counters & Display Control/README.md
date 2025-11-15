# Quick Add Reaction Game (FPGA, Verilog, Basys3)

This project implements a full FPGA-based reaction game called **Quick Add**, built using a synchronous finite state machine (FSM), pseudo-random number generator (LFSR), countdown timer, LED shifter, and a multiplexed 7-segment display system. The player must press **btnU** at the right moment when two displayed 3-bit numbers sum to a randomly generated 4-bit target. The game provides visual feedback, scoring, flashing animations, and supports a cheat/debug mode.

## Features
- **Finite State Machine (FSM)** controlling all game flow and timing  
- **8-bit LFSR** for generating pseudo-random target and operand values  
- **Loadable time counter** that counts down using qsec pulses  
- **LED shifting score display** with left- or right-shift based on win/loss  
- **Multiplexed 7-segment display** driven by ring counter and hex decoder  
- **Debounced push-button inputs** using edge detection  
- **Correct 2-second and 4-second timing** using qsec clock enables  
- **Optional cheat mode** showing A+B sum for debugging

## Inputs
- `btnC` — Go (start round)  
- `btnU` — Stop (evaluate sum)  
- `btnR` — Global reset  
- `sw[15]` — Cheat mode  
- `clkin` — 100 MHz FPGA system clock  

## Outputs
- `an[3:0]`, `seg[6:0]`, `dp` — 7-segment display  
- `led[15:0]` — Scoring bar  

## Modules Included
- `fsm.v` — One-hot encoded state machine  
- `lfsr.v` — 8-bit linear feedback shift register  
- `time_counter.v` — Loadable down counter  
- `led_shifter.v` — Shift-register scoring indicator  
- `ring_counter.v` — Time-multiplexing digit selector  
- `selector.v` — Display value mux  
- `hex7seg.v` — Segment decoder  
- `edge_detector.v` — Rising-edge detector  
- `countUD4L.v`, `countUD16L.v` — Up/down counters  
- `top.v` — Integrated top-level game system  
- `qsec_clks.v` — Clock divider providing `clk`, `digsel`, and `qsec`  :contentReference[oaicite:0]{index=0}

## Purpose
This lab demonstrates complete FPGA system design, including FSM control, synchronous logic, pseudo-random value generation, timing, multiplexed display control, and hierarchical Verilog module integration. It highlights real-time digital system behavior and event-driven design on hardware.

## Tools
- Vivado 2023.2  
- Basys3 FPGA (Artix-7)  
- Verilog HDL  
