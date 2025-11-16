# Watch Your Step – VGA Platformer Game (FPGA • Verilog • Basys3)

This project implements **Watch Your Step**, a real-time VGA platformer game running at 640×480 @ 60 Hz entirely on the Basys3 FPGA. The design includes full VGA signal generation, pixel rendering, jump physics, moving obstacles, collision detection, scoring, randomization, and animation — all written in pure synchronous Verilog using FDRE flip-flops and assign-based combinational logic, as required by the lab. 

A custom VGA sync generator produces pixel coordinates, which feed into game object modules (player, hole, ball) and pixel rendering logic. A global frame tick controls movement and gameplay timing. The final RGB output is displayed directly on a VGA monitor, while the 7-segment display shows the player's score.

---

## 🎮 Game Overview
- Press **btnC** to start the game.
- Hold **btnU** to charge a green **power bar**; release to jump.
- A moving **hole** travels across the ground—falling into it ends the game.
- A **ball** moves horizontally; touching it freezes, flashes, disappears, and awards a point.
- The player falls with gravity and jumps along a predictable physics arc.
- Score increments each time the ball is captured; displayed on the 7-segment.
- Press **btnR** to reset anytime.

Gameplay strictly follows the behavior described in Lab 6 specifications.

---

## 🔧 Major Hardware Modules

### **1. VGA Timing Generator (`Syncs.v`)**
- Produces **Hsync**, **Vsync**, and pixel timing signals.
- Generates a 640×480 active region inside an 800×525 timing frame.
- Provides horizontal/vertical counters (`hpos`, `vpos`).

### **2. Pixel Addressing (`Pixel_Address.v`)**
- Determines if the current pixel is inside the visible display area.
- Routes pixel coordinates to render logic.

### **3. Player Engine (`Player_Control.v`)**
- 16×16 player character.
- Jump physics (2 px/frame up, 2 px/frame down).
- Power-bar–based jump height.
- Detects falling through hole and collision with ball.

### **4. Hole Engine (`Hole_Control.v`)**
- Random hole width (41–71 pixels).
- Moves from right to left at 1 px/frame.
- Respawns off-screen after exiting left boundary.

### **5. Ball Engine (`Ball_Control.v`)**
- 8×8 moving ball.
- Moves at 4 px/frame.
- Random vertical spawn range (192–252).
- Upon collision: freeze → flash → despawn → respawn.

### **6. Random Generator (`LFSR.v`)**
- Generates:
  - Hole widths  
  - Ball heights  
- Uses an 8-bit LFSR for pseudo-random values.

### **7. Clocking System (`labVGA_clks.v`)**
- Derives:
  - **`p_tick`** → one pulse per pixel (25 MHz)  
  - **`frame_tick`** → one pulse per video frame (60 Hz)  
  - **`digsel`** → multiplexing clock for 7-segment display  

### **8. RGB Rendering**
- Draws game elements in layered order:
  - Background (blue)  
  - Ground platform  
  - Hole (black)  
  - Player (green)  
  - Ball (yellow)  
  - Power bar (green)  
  - Borders (red)  
  - Flash effect  

### **9. 7-Segment Display System**
- Uses:
  - `selector.v` – Muxes displayed value  
  - `ring_counter.v` – Active digit rotation  
  - `hex7seg.v` – Segment decoder  
- Displays the score or debug values.

### **10. Top-Level Integration (`Top.v`)**
Connects:
- All VGA logic  
- Player, ball, hole modules  
- Clocking  
- Random generators  
- Frame timing  
- Rendering pipeline  
- Button inputs  
- Score display  

---

## 🧠 Concepts Demonstrated
- Real-time VGA graphics and timing  
- Pixel-based rendering  
- Jump physics, falling logic, gravity  
- Moving obstacles and random behavior  
- Collision detection  
- Flashing animations  
- Synchronous digital design principles  
- Modular FPGA architecture  
- Clean separation of combinational vs. sequential logic  
- 7-segment multiplexed displays  
- Clock division and timing control  

---

## 📁 Files Included
- `Top.v` – Full game integration  
- `Syncs.v` – VGA sync generator  
- `Pixel_Address.v` – Pixel coordinate controller  
- `Player_Control.v` – Jump + movement engine  
- `Hole_Control.v` – Moving obstacle logic  
- `Ball_Control.v` – Ball movement + collision  
- `LFSR.v` – Random generator  
- `labVGA_clks.v` – Clock divider for VGA + digsel + frame tick  
- `selector.v`, `ring_counter.v`, `hex7seg.v` – 7-segment control  
- Any supporting modules reused from earlier labs  

---

## 🛠 Tools
- **Vivado 2023.2**  
- **Basys3 FPGA (Artix-7 XC7A35T)**  
- **Verilog HDL**  
- **VGA monitor (640×480 @ 60 Hz)**  

---

## 🏁 Summary
Lab 6 is a fully-featured **FPGA video game engine** with pixel-level rendering, physics-based movement, animation, and real-time interaction — all implemented from scratch using synchronous digital logic. It is the most advanced and comprehensive design project in the CSE 100 FPGA series.

