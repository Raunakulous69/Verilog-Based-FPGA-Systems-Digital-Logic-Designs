`timescale 1ns / 1ps

module led_shifter
(
    input clk_in,
    input right_in,
    input left_in, 
    input changing_scoreboard_in,
    input match_in,
    
    output [15:0] q_out,
    output gameOver_out
);

    wire [5:0] left_q, right_q;
    wire [5:0] left_next, right_next;
    
    wire together = right_in ^ left_in;

    // Shifting Logic for the Right-side Player
    wire right_shift_increase = changing_scoreboard_in & right_in & match_in & together;
    wire right_shift_decrease = changing_scoreboard_in & right_in & ~match_in;

    wire [5:0] RP_left  = {right_q[4], right_q[3], right_q[2], right_q[1], right_q[0], 1'b1};
    wire [5:0] RP_right = {1'b0, right_q[5], right_q[4], right_q[3], right_q[2], right_q[1]};
    wire [5:0] RP_stay  = right_q;

    wire [5:0] RP_mask_increase = {6{right_shift_increase}};
    wire [5:0] RP_mask_decrease = {6{right_shift_decrease}};
    wire [5:0] RP_mask_stay = {6{~right_shift_increase & ~right_shift_decrease}};

    assign right_next = (RP_left  & RP_mask_increase) |
                        (RP_right & RP_mask_decrease) |
                        (RP_stay  & RP_mask_stay);
    
    
    // Shifting Logic for the Left-side Player
    wire left_shift_increase = changing_scoreboard_in & left_in &  match_in & together;
    wire left_shift_decrease = changing_scoreboard_in & left_in & ~match_in;

    wire [5:0] LP_left  = {left_q[4], left_q[3], left_q[2], left_q[1], left_q[0], 1'b1};
    wire [5:0] LP_right = {1'b0, left_q[5], left_q[4], left_q[3], left_q[2], left_q[1]};
    wire [5:0] LP_stay  = left_q;

    wire [5:0] LP_mask_increase = {6{left_shift_increase}};
    wire [5:0] LP_mask_decrease = {6{left_shift_decrease}};
    wire [5:0] LP_mask_stay = {6{~left_shift_increase & ~left_shift_decrease}};

    assign left_next = (LP_left  & LP_mask_increase) |
                       (LP_right & LP_mask_decrease) |
                       (LP_stay  & LP_mask_stay);

    
    // Right-side Player's Score (using Flip-Flops)
    FDRE #(.INIT(1'b1)) right0 (.C(clk_in), .CE(1'b1), .R(1'b0), .D(right_next[0]), .Q(right_q[0]));
    FDRE #(.INIT(1'b1)) right1 (.C(clk_in), .CE(1'b1), .R(1'b0), .D(right_next[1]), .Q(right_q[1]));
    FDRE #(.INIT(1'b1)) right2 (.C(clk_in), .CE(1'b1), .R(1'b0), .D(right_next[2]), .Q(right_q[2]));
    FDRE #(.INIT(1'b0)) right3 (.C(clk_in), .CE(1'b1), .R(1'b0), .D(right_next[3]), .Q(right_q[3]));
    FDRE #(.INIT(1'b0)) right4 (.C(clk_in), .CE(1'b1), .R(1'b0), .D(right_next[4]), .Q(right_q[4]));
    FDRE #(.INIT(1'b0)) right5 (.C(clk_in), .CE(1'b1), .R(1'b0), .D(right_next[5]), .Q(right_q[5]));

    // Left-side Player's Score (using Flip-Flops)
    FDRE #(.INIT(1'b1)) left0 (.C(clk_in), .CE(1'b1), .R(1'b0), .D(left_next[0]), .Q(left_q[0]));
    FDRE #(.INIT(1'b1)) left1 (.C(clk_in), .CE(1'b1), .R(1'b0), .D(left_next[1]), .Q(left_q[1]));
    FDRE #(.INIT(1'b1)) left2 (.C(clk_in), .CE(1'b1), .R(1'b0), .D(left_next[2]), .Q(left_q[2]));
    FDRE #(.INIT(1'b0)) left3 (.C(clk_in), .CE(1'b1), .R(1'b0), .D(left_next[3]), .Q(left_q[3]));
    FDRE #(.INIT(1'b0)) left4 (.C(clk_in), .CE(1'b1), .R(1'b0), .D(left_next[4]), .Q(left_q[4]));
    FDRE #(.INIT(1'b0)) left5 (.C(clk_in), .CE(1'b1), .R(1'b0), .D(left_next[5]), .Q(left_q[5]));


    // Different LED Outputs
    assign q_out[5:0] = right_q;
    assign q_out[7] = right_in;
    assign q_out[8] = left_in;
    
    assign q_out[10] = left_q[5];
    assign q_out[11] = left_q[4];
    assign q_out[12] = left_q[3];
    assign q_out[13] = left_q[2];
    assign q_out[14] = left_q[1];
    assign q_out[15] = left_q[0];

    // Logic When Game is Over
    wire zero_Right = ~(right_q[0] | right_q[1] | right_q[2] | right_q[3] | right_q[4] | right_q[5]);
    wire win_Right  = right_q[5];
    wire zero_Left = ~(left_q[0] | left_q[1] | left_q[2] | left_q[3] | left_q[4] | left_q[5]);
    wire win_Left  = left_q[5];
     
    assign gameOver_out = (win_Left & ~win_Right) | (~win_Left & win_Right) | (zero_Left & ~zero_Right) | (~zero_Left & zero_Right);

endmodule

