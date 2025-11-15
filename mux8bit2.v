`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2025 10:43:44 AM
// Design Name: 
// Module Name: mux8bit2
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


module mux8bit2
(
    input [7:0] a,
    input [7:0] b,
    input sel,
    
    output [7:0] c
);

   assign c = ({8{sel}} & b) | ({8{~sel}} & a);

endmodule
