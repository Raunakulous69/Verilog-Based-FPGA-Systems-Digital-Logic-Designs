`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 09:47:31 PM
// Design Name: 
// Module Name: hex7seg
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


// Input and Output for hex7seg
module hex7seg
(
    input [3:0] N,
    
    output [6:0] Seg
);
  
  // Each Seg[x] will correspond to a particular segment on the 7-segment display
  assign Seg[0] = (~N[3]&~N[2]&~N[1]&N[0])|(~N[3]&N[2]&~N[1]&~N[0])|(N[3]&~N[2]&N[1]&N[0])|(N[3]&N[2]&~N[1]&N[0]);
  assign Seg[1] = (~N[3]&N[2]&~N[1]&N[0])|(~N[3]&N[2]&N[1]&~N[0])|(N[3]&~N[2]&N[1]&N[0])|(N[3]&N[2]&~N[1]&~N[0])|(N[3]&N[2]&N[1]&~N[0])|(N[3]&N[2]&N[1]&N[0]);
  assign Seg[2] = (~N[3]&~N[2]&N[1]&~N[0])|(N[3]&N[2]&~N[1]&~N[0])|(N[3]&N[2]&N[1]&~N[0])|(N[3]&N[2]&N[1]&N[0]);
  assign Seg[3] = (~N[3]&~N[2]&~N[1]&N[0])|(~N[3]&N[2]&~N[1]&~N[0])|(~N[3]&N[2]&N[1]&N[0])|(N[3]&~N[2]&~N[1]&N[0])|(N[3]&~N[2]&N[1]&~N[0])|(N[3]&N[2]&N[1]&N[0]);
  assign Seg[4] = (~N[3]&~N[2]&~N[1]&N[0])|(~N[3]&~N[2]&N[1]&N[0])|(~N[3]&N[2]&~N[1]&~N[0])|(~N[3]&N[2]&~N[1]&N[0])|(~N[3]&N[2]&N[1]&N[0])|(N[3]&~N[2]&~N[1]&N[0]);
  assign Seg[5] = (~N[3]&~N[2]&~N[1]&N[0])|(~N[3]&~N[2]&N[1]&~N[0])|(~N[3]&~N[2]&N[1]&N[0])|(~N[3]&N[2]&N[1]&N[0])|(N[3]&N[2]&~N[1]&N[0]);
  assign Seg[6] = (~N[3]&~N[2]&~N[1]&~N[0])|(~N[3]&~N[2]&~N[1]&N[0])|(~N[3]&N[2]&N[1]&N[0])|(N[3]&N[2]&~N[1]&~N[0]);
 
endmodule
