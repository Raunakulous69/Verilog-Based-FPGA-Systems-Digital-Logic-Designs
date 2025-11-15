# Two-Player Quick Add Competitive Game (Verilog • Basys3 FPGA)

This project implements a **two-player competitive reaction game** on the Basys3 FPGA. Each round begins by displaying a random 4-bit target value, followed by two new random 4-bit numbers every 2 seconds. Players must press their button when the **sum mod 16** of the two numbers matches the target. Scoring, timing, flashing animations, and win/lose conditions are all handled by a fully synchronous one-hot encoded FSM.

This is an extension of the single-player Quick Add game from Lab 4, redesigned for two players with independent scoring logic, simultaneous button handling, and enhanced display control.  
:contentReference[oaicite:0]{index=0}

---

## 🎮 Game Rules (High-Level)
- Press **Go (btnC)** to start a round.
- A **4-bit random target** is displayed on the leftmost 7-segment digit.
- Every 2 seconds, two new **4-bit random operands** appear on the rightmost digits.
- Players **L** and **R** press their buttons (btnL, btnR) to guess if `(A + B) mod 16 == target`.
- Pressing *correctly* → score **+1**
- Pressing *incorrectly* → score **–1**
- If both players press → neither scores
- Each player begins with **3 points**
- Game ends if:
  - A player reaches **6 points**, or  
  - One player hits **0** while the other still has ≥1

---

## 🔧 Key Hardware Features
- **One-hot encoded FSM**: controls all game states, timings, flashing, and scoring  
- **LFSR module** (`lfsr.v`) generates random 4-bit values  
- **Two independent scoring LED shifters** (Player L & Player R)  
- **lab5_clks** (`lab5_clks.v`):
  - `clk` → main system clock  
  - `digsel` → multiplexed digit selector  
  - `qsec` → 0.25s clock enable for timers  
- **Time Counter (`time_counter.v`)** controls 2-second and 4-second periods  
- **Hex7Seg decoder (`hex7seg.v`)** for every digit  
- **Ring Counter (`ring_counter.v`)** for digit scanning  
- **Selector (`selector.v`)** for multiplexing display values  
- **Edge detectors (`edge_detector.v`)** for clean, debounced button presses  
- Top module integrates all components (`top.v`)

---

## 🧠 Concepts Demonstrated
- Hierarchical and synchronous FPGA design  
- One-hot FSM encoding with flip-flops (FDREs only)  
- Pseudo-random number generation with LFSR  
- Clock enable timing using a divided clock (`qsec`)  
- LED scoring system as a shift register  
- Simultaneous player input handling  
- Modular combinational logic (assign-only design)  
- Multiplexed 7-segment display control  
- Game logic, conditions, and flashing animation

---

## 📁 Files Included
- `top.v` – full integrated game  
- `fsm.v` – main state machine  
- `lab5_clks.v` – system clock divider  
- `lfsr.v` – pseudo-random number generator  
- `time_counter.v` – 2s and 4s timers  
- `selector.v` – display mux logic  
- `hex7seg.v` – digit-to-segment mapper  
- `ring_counter.v` – digit selection  
- `adder8.v`, `countUD4L.v`, `countUD16L.v` – counters and arithmetic  
- `led_shifter.v` – score tracking  
- `edge_detector.v` – clean button press detection  

---

## 🛠 Tools Used
- Xilinx Vivado 2023.2  
- Basys3 FPGA (Artix-7 XC7A35T)  
- Verilog HDL  

---

## 🏁 Summary
Lab 5 is a complete **two-player competitive hardware game**, combining synchronous digital design, real-time input handling, random number generation, and state-machine-based control. It serves as a capstone-level FPGA project demonstrating advanced logic design skills suitable for industry-level embedded and hardware engineering roles.
