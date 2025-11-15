`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 09:10:48 PM
// Design Name: 
// Module Name: selector
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


// Inputs and Outputs for the Selector
module selector
(
    input [15:0] n,
    input [3:0] Sel,
    
    output [3:0] h
);

    // Wires that represent which one-hot selector is being active
    wire Sel0, Sel1, Sel2, Sel3;
    
    // Decoding one-hot selection signals from the given Sel Input
    assign Sel0 = ~Sel[3] & ~Sel[2] & ~Sel[1] & Sel[0];
    assign Sel1 = ~Sel[3] & ~Sel[2] & Sel[1] & ~Sel[0];
    assign Sel2 = ~Sel[3] & Sel[2] & ~Sel[1] & ~Sel[0];
    assign Sel3 = Sel[3] & ~Sel[2] & ~Sel[1] & ~Sel[0];
    
    // Selecting the correct nibble based on which of the Sel input is indeed active
    assign h[0] = (Sel0 & n[0]) | (Sel1 & n[4]) | (Sel2 & n[8]) | (Sel3 & n[12]);
    assign h[1] = (Sel0 & n[1]) | (Sel1 & n[5]) | (Sel2 & n[9]) | (Sel3 & n[13]);
    assign h[2] = (Sel0 & n[2]) | (Sel1 & n[6]) | (Sel2 & n[10]) | (Sel3 & n[14]);
    assign h[3] = (Sel0 & n[3]) | (Sel1 & n[7]) | (Sel2 & n[11]) | (Sel3 & n[15]);

endmodule