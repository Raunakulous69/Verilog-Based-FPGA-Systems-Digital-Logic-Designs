`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2025 11:02:32 AM
// Design Name: 
// Module Name: adder8
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

module Fa
(
    input A,
    input B,
    input cin,
    
    output S,
    output cout
);
    
    assign S = A ^ B ^ cin;
    assign cout = (A & cin) | (B & cin) | (A & B);

endmodule


module adder8
(
    input [7:0] a,
    input [7:0] b,
    input cin,
    
    output [7:0] s,
    output ovfl,
    output cout
);

    wire [6:0] c;
    
    Fa fa0(.A(a[0]), .B(b[0]), .cin(cin), .S(s[0]), .cout(c[0]));
    Fa fa1(.A(a[1]), .B(b[1]), .cin(c[0]), .S(s[1]), .cout(c[1]));
    Fa fa2(.A(a[2]), .B(b[2]), .cin(c[1]), .S(s[2]), .cout(c[2]));
    Fa fa3(.A(a[3]), .B(b[3]), .cin(c[2]), .S(s[3]), .cout(c[3]));
    Fa fa4(.A(a[4]), .B(b[4]), .cin(c[3]), .S(s[4]), .cout(c[4]));
    Fa fa5(.A(a[5]), .B(b[5]), .cin(c[4]), .S(s[5]), .cout(c[5]));
    Fa fa6(.A(a[6]), .B(b[6]), .cin(c[5]), .S(s[6]), .cout(c[6]));
    Fa fa7(.A(a[7]), .B(b[7]), .cin(c[6]), .S(s[7]), .cout(cout));
    
    assign ovfl = c[6] ^ cout;
    
endmodule
