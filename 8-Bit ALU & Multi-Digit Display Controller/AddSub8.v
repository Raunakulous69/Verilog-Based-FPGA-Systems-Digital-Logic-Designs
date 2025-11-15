`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2025 11:10:01 AM
// Design Name: 
// Module Name: AddSub8
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

    
module AddSub8
(
    input [7:0] a,
    input [7:0] b,
    input Sub,
    output [7:0] s,
    output ovfl
);
    
    wire [7:0] out_mux;
    wire [7:0] b_neg;
    assign b_neg = b ^ (8'b11111111);
    
// Instantiation for mux8bit2 
    mux8bit2 mux(.a(b), .b(b_neg), .c(out_mux), .sel(Sub));
    
// Instantiation for adder8 
    adder8 adder(.a(a), .b(out_mux), .cin(Sub), .s(s), .cout(cout), .ovfl(ovfl));
    
endmodule
