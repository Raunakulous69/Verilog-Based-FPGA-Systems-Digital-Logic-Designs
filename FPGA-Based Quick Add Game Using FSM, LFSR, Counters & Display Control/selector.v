`timescale 1ns / 1ps

module selector
(
    input [15:0] n,
    input [3:0] Sel,
    
    output [3:0] h
);

    wire Sel_0, Sel_1, Sel_2, Sel_3;
    
    assign Sel_0 = ~Sel[3] & ~Sel[2] & ~Sel[1] & Sel[0];
    assign Sel_1 = ~Sel[3] & ~Sel[2] & Sel[1] & ~Sel[0];
    assign Sel_2 = ~Sel[3] & Sel[2] & ~Sel[1] & ~Sel[0];
    assign Sel_3 = Sel[3] & ~Sel[2] & ~Sel[1] & ~Sel[0];
    
    assign h[0] = (Sel_0 & n[0]) | (Sel_1 & n[4]) | (Sel_2 & n[8]) | (Sel_3 & n[12]);
    assign h[1] = (Sel_0 & n[1]) | (Sel_1 & n[5]) | (Sel_2 & n[9]) | (Sel_3 & n[13]);
    assign h[2] = (Sel_0 & n[2]) | (Sel_1 & n[6]) | (Sel_2 & n[10]) | (Sel_3 & n[14]);
    assign h[3] = (Sel_0 & n[3]) | (Sel_1 & n[7]) | (Sel_2 & n[11]) | (Sel_3 & n[15]);

endmodule
