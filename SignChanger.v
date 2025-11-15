`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2025 09:05:43 AM
// Design Name: 
// Module Name: SignChanger
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


// SignChanger Module (contains the inputs and outputs)
module SignChanger
(
    input [7:0] a,
    input sign,
    
    output [7:0] d,
    output ovfl
);

// A zero constant used as an operand in the adder/subtractor    
    wire [7:0] zero_val;
    assign zero_val = 8'b00000000;

// Instantiation for AddOrSub        
    AddSub8 AddOrSub(.a(zero_val), .b(a), .s(d), .Sub(sign), .ovfl(ovfl));

endmodule
