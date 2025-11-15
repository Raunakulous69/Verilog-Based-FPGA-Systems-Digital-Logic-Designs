`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 08:18:42 PM
// Design Name: 
// Module Name: top_lab3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// Inputs & Outputs for this entire lab 3 
module top_lab3(
    input [15:0] sw,
    input clkin,
    input btnD,
    input btnR,
    input btnU,
    input btnL,
    input btnC,
        
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an,
    output dp
);

    // Internal Clock & Control Signals
    wire [15:0] count;
    wire [3:0] ring_out, selected_digit;
    wire clk;
    wire digsel;
    wire up_signal, down_signal, load_signal;    
    wire up_pulse, down_pulse, load_pulse;
    wire UTC, DTC;
    
    // Logic for detecting when each button is held (while reset isn't pressed)
    wire up_held = btnU & ~btnR;
    wire load_held = btnL & ~btnR;
    wire down_held = btnD & ~btnR;
    
    // Button priority logic (only allowing just one control at a time)
    wire up_allowed = ~down_held & ~load_held;
    wire load_allowed = ~up_held & ~down_held;
    wire down_allowed = ~up_held & ~load_held;
    
    
    // Clock divider for generating a slower digit selector and system clock
    labCnt_clks clk_div (.clkin(clkin), .greset(btnR), .clk(clk), .digsel(digsel));
    
    // Generating a single-cycle pulse when btnU is going from low to high
    edge_detector edge_up (.clk(clk), .signal(btnU), .pulse(up_pulse));
    
    // Generating a single-cycle pulse when btnD is going from low to high
    edge_detector edge_down (.clk(clk), .signal(btnD), .pulse(down_pulse));
    
    
    // Determining the final control signals (gated and prioritized)
    assign up_signal = up_allowed & (up_pulse | (btnC & ~(&count[15:2])));
    assign down_signal = down_allowed & down_pulse;
    assign load_signal = load_allowed & load_pulse;
  
    
    // 16-bit loadable up/down counter w/ the FDRE-based 4-bit slices
    countUD16L counter_16 (.clk(clk), .up(up_signal), .dw(down_signal), .ld(btnL), .din(sw), .q(count), .Utc(utc), .Dtc(dtc));
    
    // 4-bit ring counter for the digit multiplexing 
    ring_counter rc(.clk(clk), .advance(digsel), .q(ring_out));
    
    // Selecting a 4-bit portion from the 16-bit count based on ring counter
    selector Sel(.n(count), .Sel(ring_out), .h(selected_digit));
    
    // Converting the 4-bit value to an encoded 7-segment display 
    hex7seg decoding_seg(.N(selected_digit), .Seg(seg));
    
    
    // Anode & Decimal Point Control
    assign led = {utc, 14'b0, dtc};
    assign an = ~ring_out;
    assign dp = 1'b1;

endmodule