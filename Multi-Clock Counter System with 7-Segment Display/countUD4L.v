`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 11:22:33 PM
// Design Name: 
// Module Name: countUD4L
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

// Inputs and Outputs for CountUD4L
module countUD4L
(
    input [3:0] din,
    input clk,
    input up,
    input dw,
    input ld,
    input bin,
    input cin,
    
    output [3:0] q,
    output bout,
    output cout
);
    
    // Internal wires
    wire [3:0] next_Count, count_FF;
    wire up_Condition;
    wire load_Condition;
    wire down_Condition; 
    wire no_Change;
    
    // Control logic for managing the counter mode
    assign up_Condition = up & ~dw;
    assign load_Condition = ld;
    assign down_Condition = ~up & dw;
    assign no_Change = ~load_Condition & ~up_Condition & ~down_Condition;

    
    // Intermediate wires for incremental logic
    wire [3:0] inc_Carry;
    wire [3:0] count_PLUS_1;
    
    
    //  4-bit incremental logic utilizing the ripple-carry adder
    assign inc_Carry[0] = cin;
    assign count_PLUS_1[0] = count_FF[0] ^ inc_Carry[0];
    assign inc_Carry[1] = count_FF[0] & inc_Carry[0];
    assign count_PLUS_1[1] = count_FF[1] ^ inc_Carry[1];
    assign inc_Carry[2] = count_FF[1] & inc_Carry[1];
    assign count_PLUS_1[2] = count_FF[2] ^ inc_Carry[2];
    assign inc_Carry[3] = count_FF[2] & inc_Carry[2];
    assign count_PLUS_1[3] = count_FF[3] ^ inc_Carry[3];
    assign cout = count_FF[3] & inc_Carry[3];

    
    // Intermediate wires for decremental logic
    wire [3:0] dec_Borrow;
    wire [3:0] count_MINUS_1;
    
    
    // 4-bit decremental logic utilizing the ripple-carry adder
    assign dec_Borrow[0] = bin;
    assign count_MINUS_1[0] = count_FF[0] ^ dec_Borrow[0];
    assign dec_Borrow[1] = ~count_FF[0] & dec_Borrow[0];
    assign count_MINUS_1[1] = count_FF[1] ^ dec_Borrow[1];
    assign dec_Borrow[2] = ~count_FF[1] & dec_Borrow[1];
    assign count_MINUS_1[2] = count_FF[2] ^ dec_Borrow[2];
    assign dec_Borrow[3] = ~count_FF[2] & dec_Borrow[2];
    assign count_MINUS_1[3] = count_FF[3] ^ dec_Borrow[3];
    assign bout = ~count_FF[3] & dec_Borrow[3];

    
    // Bitwise logic to compute next counter value
    assign next_Count = ({4{up_Condition}} & count_PLUS_1) | ({4{load_Condition}} & din) | ({4{down_Condition}} & count_MINUS_1) | ({4{no_Change}} & count_FF);

    
    // Flip-flops for holding the 4-bit counter state
    FDRE #(.INIT(1'b0)) ff0 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_Count[0]), .Q(count_FF[0]));
    FDRE #(.INIT(1'b0)) ff1 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_Count[1]), .Q(count_FF[1]));
    FDRE #(.INIT(1'b0)) ff2 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_Count[2]), .Q(count_FF[2]));
    FDRE #(.INIT(1'b0)) ff3 (.C(clk), .R(1'b0), .CE(1'b1), .D(next_Count[3]), .Q(count_FF[3]));
    
    // Output
    assign q = count_FF;
    
endmodule