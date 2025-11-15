`timescale 1ns / 1ps

module top
(
    input  wire [15:0] sw,
    input  wire clkin,           
    input  wire btnU,     
    input  wire btnC,     
    input  wire btnR,     
    
    output wire [15:0] led,
    output wire [6:0] seg,
    output wire [3:0] an,           
    output wire dp        
);

    //  qsec clk Instantiation
    wire clk, dig_sel, q_sec;
    qsec_clks slowit(.clkin(clkin), .greset(btnR), .clk(clk), .digsel(dig_sel), .qsec(q_sec));

    // Edge Detector Instantiation
    wire going_pulse, stopping_pulse;
    edge_detector edge_going(.clk_in(clk), .signal_in(btnC), .edge_out(going_pulse));
    edge_detector edge_stopping(.clk_in(clk), .signal_in(btnU), .edge_out(stopping_pulse));

    // LFSR Instantiation 
    wire [7:0] random_q;
    lfsr rand_num(.clk_in(clk), .CE_in(q_sec),.q_out(random_q));

    // Time Counter Instantiation 
    wire [5:0] second;
    wire time_to_reset;
    time_counter TC(.clk_in(clk), .inc_in(q_sec), .reset_in(time_to_reset), .q_out(second));

    wire any_second   = second[5] | second[4] | second[3] | second[2] | second[1] | second[0];
    wire two_seconds  = ~second[2] & ~second[1] & ~second[0] & any_second;        
    wire four_seconds =  second[4] & ~second[3] & ~second[2] & ~second[1] & ~second[0]; 

    
    wire loading_target;
    wire loading_rand_numbers;
    wire shr;
    wire shl;
    wire flashing_both;
    wire flashing_alt;
    wire matching;
    
    
    // FSM Instantiation 
    fsm adding
    (
        .clk_in(clk),
        .go_in(going_pulse),
        .stop_in(stopping_pulse),
        .two_secs_in(two_seconds),
        .four_secs_in(four_seconds),
        .match_in(matching),
        .load_target_out(loading_target),
        .reset_timer_out(time_to_reset),
        .load_numbers_out(loading_rand_numbers),
        .shr_out(shr),
        .shl_out(shl),
        .flash_both_out(flashing_both),
        .flash_alt_out(flashing_alt)
    );

    // LED Shifter Instantiation
    led_shifter LS (.clk_in(clk), .in_in(shl), .shl_in(shl), .shr_in(shr), .q_out(led));
    
    // 2nd Edge Detector Instantiation 
    wire two_ticks;
    edge_detector ED_TT(.clk_in(clk), .signal_in(two_seconds), .edge_out(two_ticks));
    wire loading_num_ticks = two_ticks & loading_rand_numbers;

    
    wire [2:0] A_val, B_val;
    wire [3:0] S_val;
    FDRE #(.INIT(1'b0)) A0(.C(clk),.CE(loading_num_ticks),.D(random_q[0]),.Q(A_val[0]));
    FDRE #(.INIT(1'b0)) A1(.C(clk),.CE(loading_num_ticks),.D(random_q[1]),.Q(A_val[1]));
    FDRE #(.INIT(1'b0)) A2(.C(clk),.CE(loading_num_ticks),.D(random_q[2]),.Q(A_val[2]));
    FDRE #(.INIT(1'b0)) B0(.C(clk),.CE(loading_num_ticks),.D(random_q[3]),.Q(B_val[0]));
    FDRE #(.INIT(1'b0)) B1(.C(clk),.CE(loading_num_ticks),.D(random_q[4]),.Q(B_val[1]));
    FDRE #(.INIT(1'b0)) B2(.C(clk),.CE(loading_num_ticks),.D(random_q[5]),.Q(B_val[2]));
    FDRE #(.INIT(1'b0)) S0(.C(clk),.CE(loading_target),.D(random_q[4]),.Q(S_val[0]));
    FDRE #(.INIT(1'b0)) S1(.C(clk),.CE(loading_target),.D(random_q[5]),.Q(S_val[1]));
    FDRE #(.INIT(1'b0)) S2(.C(clk),.CE(loading_target),.D(random_q[6]),.Q(S_val[2]));
    FDRE #(.INIT(1'b0)) S3(.C(clk),.CE(loading_target),.D(random_q[7]),.Q(S_val[3]));

    
    wire [7:0] sum_8;
    wire ovfl, cout;
    
    // adder9 Instantiation
    adder8 u_adder(.a({5'b0, A_val}), .b({5'b0, B_val}), .cin(1'b0), .s(sum_8), .ovfl(ovfl), .cout(cout));

    wire [3:0] num_sum = sum_8[3:0];
    assign matching = &(~(num_sum ^ S_val)) | sw[14];

    wire [15:0] display_nibs;
    assign display_nibs = { S_val, num_sum, {1'b0,B_val}, {1'b0,A_val} };

    
    // Ring Counter Instantiation
    wire [3:0] digit_active;
    ring_counter RC(.clk_in(clk), .advance_in(dig_sel), .reset_in(btnR), .data_out(digit_active));

    // Selector Instantiation 
    wire [3:0] num;
    selector sel(.Sel(digit_active), .n(display_nibs), .h(num));
    
    // Hex7Seg Instantiation
    wire [6:0] raw_segment;
    hex7seg H7S(.N(num), .Seg(raw_segment));

    wire invalid_num = num[3] & (num[2] | num[1]);
    wire cheating_on = sw[15];
    wire blank_num = invalid_num & ~(digit_active[3] | (digit_active[2] & cheating_on));
    
    assign seg = raw_segment | {7{blank_num}};
    assign dp = 1'b1;

    wire [3:0] base_anode;
    assign base_anode = {
        ~digit_active[3],
        ~digit_active[2] | ~cheating_on,
        ~digit_active[1],
        ~digit_active[0]
    };

    wire state = second[0];

    wire losing = flashing_both;
    wire winning  = flashing_alt;
    wire disp_3 = (losing & state) | (winning  &  state);
    wire disp_2 = 1'b0;
    wire disp_1 = (losing & state) | (winning  & ~state);
    wire disp_0 = disp_1;
    wire [3:0] flashing_disp = {disp_3, disp_2, disp_1, disp_0};

    assign an = base_anode | flashing_disp;

endmodule
