`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2025 08:11:39 PM
// Design Name: 
// Module Name: Lab1_DesignSource
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


module Lab1_DesignSource
(
    input d2, d1, d0, btnD,
    
    output CA, CB, CC, CD, CE, CF, CG,DP, AN3, AN2, AN1, AN0
    
);

assign CA = (~d2*~d1*d0)+(d2*~d1*~d0);
assign CB = (d2*~d1*d0)+(d2*d1*~d0);
assign CC = (~d2*d1*~d0);
assign CD = (~d2*~d1*d0)+(d2*~d1*~d0)+(d2*d1*d0);
assign CE = (~d2*~d1*d0)+(~d2*d1*d0)+(d2*~d1*~d0)+(d2*~d1*d0)+(d2*d1*d0);
assign CF = (~d2*~d1*d0)+(~d2*d1*~d0)+(~d2*d1*d0)+(d2*d1*d0);
assign CG = (~d2*~d1*~d0)+(~d2*~d1*d0)+(d2*d1*d0);

assign DP = btnD;
 
assign AN3 = 1;
assign AN2 = 1;
assign AN1 = 1;
assign AN0 = 0; // Activating the rightmost digit

endmodule

