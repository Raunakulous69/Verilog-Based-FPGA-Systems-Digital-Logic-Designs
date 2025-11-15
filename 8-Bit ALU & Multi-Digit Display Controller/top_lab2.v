`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2025 10:40:55 AM
// Design Name: 
// Module Name: top_lab2
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


// inputs and outputs for top level module
module top_lab2
(
    input [7:0] sw,
    input btnU,
    input btnR,
    input clkin,
        
    output [6:0] seg,
    output [3:0] an,
    output [7:0] led,
    output dp 
);

// assigning the leds to switches (internal wires for data transfer between modules)
    wire [7:0] values_displayed;
    wire [6:0] upper_seg;
    wire [6:0] lower_seg;
    wire dig_sel;
    wire ovfl;
    
// Mapping the switches directly to the LEDs
    assign led = sw;
    
// SignChangder Module
    SignChanger s_c (.sign(btnU), .d(values_displayed), .a(sw), .ovfl(ovfl));
    
// hex7seg Modules
    hex7seg upper (.n(values_displayed[7:4]), .seg(upper_seg));
    hex7seg lower (.n(values_displayed[3:0]), .seg(lower_seg));
    
// mux8bit Modules
    mux8bit2 mux (.a(lower_seg), .b(upper_seg), .c(seg), .sel(dig_sel));
    
// Lab2_digsel Module (the timer is being initialized)
    lab2_digsel timer (.greset(btnR), .clkin(clkin), .digsel(dig_sel));
    
// assigning the proper values for each anode    
    assign an[0] = dig_sel;
    assign an[1] = ~dig_sel;
    assign an[2] = 1;
    assign an[3] = 1;
    
    assign dp = ~ovfl;

endmodule
