`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 10:54:28 PM
// Design Name: 
// Module Name: countUD16L
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


// Inputs and Outputs for CountUD16L
module countUD16L
(
    input clk,
    input up,
    input dw,
    input ld,
    input [15:0] din,
    
    output [15:0] q,
    output Utc,
    output Dtc
);

    // Wires for connecting the borrow and carry outputs between each 4-bit counter stage
    wire [3:0] borrow_Out;
    wire [3:0] carry_Out;
    
    
    // Instantiating the 4-bit counter for least significant nibble (bits 3:0)
    // Using external up/down/load control and generating the initial carry/borrow signals
    countUD4L counter_0 (.clk(clk), .up(up), .dw(dw), .ld(ld), .cin(up & ~dw), .bin(dw & ~up), .din(din[3:0]), .q(q[3:0]), .cout(carry_Out[0]), .bout(borrow_Out[0]));
    
    // Instantiating the 2nd 4-bit counter for the bits 7:4
    // Carry-in and borrow-in come from the previous stage's outputs
    countUD4L counter_1 (.clk(clk), .up(up), .dw(dw), .ld(ld), .cin(carry_Out[0]), .bin(borrow_Out[0]), .din(din[7:4]), .q(q[7:4]), .cout(carry_Out[1]), .bout(borrow_Out[1]));
    
    // Instantiating the 3rd 4-bit counter for the bits 11:8
    // Connected similarly in the cascade
    countUD4L counter_2 (.clk(clk), .up(up), .dw(dw), .ld(ld), .cin(carry_Out[1]), .bin(borrow_Out[1]), .din(din[11:8]), .q(q[11:8]), .cout(carry_Out[2]), .bout(borrow_Out[2]));
    
    // Instantiating the 4th (most significant) 4-bit counter for the bits 15:12
    countUD4L counter_3 (.clk(clk), .up(up), .dw(dw), .ld(ld), .cin(carry_Out[2]), .bin(borrow_Out[2]), .din(din[15:12]), .q(q[15:12]), .cout(carry_Out[3]), .bout(borrow_Out[3]));
         
     // Conditions of Terminal Count Output
    assign Utc = &q;
    assign Dtc = ~|q;

endmodule
