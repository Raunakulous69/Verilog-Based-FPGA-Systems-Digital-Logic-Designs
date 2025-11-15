`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 10:09:52 PM
// Design Name: 
// Module Name: edge_detector
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


// Inputs and Output for the Edge Detector
module edge_detector
(
    input clk,
    input signal,
    
    output pulse
);
    
    // Internal wires that are storing delayed versions of the signal
    wire signal_FF1, signal_FF2;
    
    FDRE #(.INIT(1'b0)) ff1 (.C(clk), .R(1'b0), .CE(1'b1), .D(signal), .Q(signal_FF1)); // captures the current value of signal
    FDRE #(.INIT(1'b0)) ff2 (.C(clk), .R(1'b0), .CE(1'b1), .D(signal_FF1), .Q(signal_FF2)); // captures the previous value of signal
    
    // Output logic of pulse being high for one cycle on a rising edge
    assign pulse = signal_FF1 & ~signal_FF2;

endmodule