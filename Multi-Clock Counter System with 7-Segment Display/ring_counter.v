`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 09:30:08 PM
// Design Name: 
// Module Name: ring_counter
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


// Inputs and Outputs for Ring Counter
module ring_counter
(
    input clk,
    input advance, // Control signal that advances ring's position
    
    output [3:0] q
);

    // Internal wires holding the flip-flop state and next state logic
    wire [3:0] Next_State, State_FF;
    
    // Next state logic for each bit
    assign Next_State[0] = (advance & State_FF[1]) | (~advance & State_FF[0]);
    assign Next_State[1] = (advance & State_FF[2]) | (~advance & State_FF[1]);
    assign Next_State[2] = (advance & State_FF[3]) | (~advance & State_FF[2]);
    assign Next_State[3] = (advance & State_FF[0]) | (~advance & State_FF[3]);
    
    // 4 D flip-flops holding the state of the current ring
    FDRE #(.INIT(1'b1)) ff0 (.C(clk), .R(1'b0), .CE(1'b1), .D(Next_State[0]), .Q(State_FF[0]));
    FDRE #(.INIT(1'b0)) ff1 (.C(clk), .R(1'b0), .CE(1'b1), .D(Next_State[1]), .Q(State_FF[1]));
    FDRE #(.INIT(1'b0)) ff2 (.C(clk), .R(1'b0), .CE(1'b1), .D(Next_State[2]), .Q(State_FF[2]));
    FDRE #(.INIT(1'b0)) ff3 (.C(clk), .R(1'b0), .CE(1'b1), .D(Next_State[3]), .Q(State_FF[3]));
    
    // Output for the current ring position
    assign q = State_FF;

endmodule
