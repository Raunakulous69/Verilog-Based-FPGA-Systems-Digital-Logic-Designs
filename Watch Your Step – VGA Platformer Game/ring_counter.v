`timescale 1ns / 1ps

module ring_counter
(
    input advance_in,
    input clk_in,
    input reset_in,    
    
    output [3:0] data_out
);

    wire [3:0] d_i, q_o;
    
    assign d_i[0] = (advance_in & q_o[1]) | (~advance_in & q_o[0]);
    assign d_i[1] = (advance_in & q_o[2]) | (~advance_in & q_o[1]);
    assign d_i[2] = (advance_in & q_o[3]) | (~advance_in & q_o[2]);
    assign d_i[3] = (advance_in & q_o[0]) | (~advance_in & q_o[3]);
    
    FDRE #(.INIT(1'b1)) ff0 (.C(clk_in), .R(reset_in), .CE(1'b1), .D(d_i[0]), .Q(q_o[0]));
    FDRE #(.INIT(1'b0)) ff1 (.C(clk_in), .R(reset_in), .CE(1'b1), .D(d_i[1]), .Q(q_o[1]));
    FDRE #(.INIT(1'b0)) ff2 (.C(clk_in), .R(reset_in), .CE(1'b1), .D(d_i[2]), .Q(q_o[2]));
    FDRE #(.INIT(1'b0)) ff3 (.C(clk_in), .R(reset_in), .CE(1'b1), .D(d_i[3]), .Q(q_o[3]));
    
    assign data_out = q_o;

endmodule
