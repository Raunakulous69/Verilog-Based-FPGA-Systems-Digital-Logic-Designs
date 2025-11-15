`timescale 1ns / 1ps

module edge_detector
(
    input clk_in,
    input signal_in,
    
    output edge_out
);
    
    wire prev;
    
    FDRE ff (.R(1'b0), .C(clk_in), .CE(1'b1), .Q(prev), .D(signal_in));
    
    assign edge_out = ~prev & signal_in;
    
endmodule