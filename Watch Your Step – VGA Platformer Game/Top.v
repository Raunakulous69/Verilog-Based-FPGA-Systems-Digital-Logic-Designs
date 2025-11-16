`timescale 1ns / 1ps

module Top 
(
  input wire [15:0] sw,     
  input wire clkin,
  input wire btnU,  
  input wire btnC,
  input wire btnL,
  input wire btnR, 

  output wire [15:0] led,
  output wire [6:0] seg,
  output wire [3:0] an,
  output wire dp,
  
  output wire [3:0] vgaBlue,
  output wire [3:0] vgaGreen,
  output wire [3:0] vgaRed,
  output wire Hsync,
  output wire Vsync 
);

  // labVGA_clks Instantiation
  wire clk, digsel;
  labVGA_clks clock_generation (.clkin(clkin), .greset(btnR), .clk(clk), .digsel(digsel));

  // Syncs Instantation 
  wire [9:0] x_val, y_val;
  wire tick_frame, active_region;
  Syncs snychronization (.clk_in(clk), .reset_in(btnR), .H_sync(Hsync), .V_sync(Vsync), .x_val(x_val), .y_val(y_val), .active_region(active_region), .sync_frame(tick_frame));

  // LFSR Instantiation
  wire [7:0] rand_num;
  LFSR lfsr_in (.clk_in(clk), .reset_in(btnR), .q_out(rand_num));

  // X-pos of the game's player
  wire [9:0] x_val_player = 10'd100;
  wire [9:0] x_val_player_leftward  = 10'd50 + x_val_player;
  wire [9:0] x_val_player_rightward = 10'd15 + x_val_player_leftward;

  // Logic for the hole dimensions and detecting overlaps 
  wire [9:0] x_hole, ending_hole;
  wire [6:0] y_hole;
  wire moving_left_hole;
  wire hole_std_overlap = !moving_left_hole && (x_val_player_leftward >= x_hole) && (x_val_player_rightward <= x_hole + y_hole);
  wire hole_wrapping_overlap = moving_left_hole && (x_val_player_leftward < ending_hole) && (x_val_player_rightward > 10'd0);
  wire hole_overlap = hole_std_overlap || hole_wrapping_overlap;

  // Logic for the state that's falling
  wire state_falling, nxt_falling_state;
  wire constricted_frame = tick_frame & ~state_falling;
  wire resuming = (num_lives != 2'd0) && btnL && falling_stop;
  
  // btnC Logic
  wire pressing_btnC;
  wire nxt_pressing_btnC = btnC | pressing_btnC;
  FDRE #(.INIT(1'b0)) ff_btnC (.R(btnR), .C(clk), .CE(1'b1), .D(nxt_pressing_btnC), .Q(pressing_btnC));

  // Generating a new hole
  wire making_hole = (btnC & ~pressing_btnC) || resuming;

  // Hole Control Instantiation
  Hole_Control HC (.clk_in(clk), .reset_in(btnR), .tick_frame(constricted_frame), .going_in(making_hole), .rand_num(rand_num), .x_hole(x_hole), .y_hole(y_hole), .moving_left_hole(moving_left_hole), .ending_hole(ending_hole));

  // Logic for Player's vertically-vased movement 
  wire resetting_player = btnR || resuming;
  wire [9:0] po;
  wire [6:0] pb;
  
  // Player Control Instantiation
  Player_Control PC (.clk_in(clk), .reset_in(resetting_player), .btnU(btnU & ~state_falling), .tick_frame(tick_frame), .player_out(po), .power_bar(pb));

  // Falling occurs if player is right over the hole at a particular Y-pos
  wire falling_start = hole_overlap && tick_frame && (po == 10'd328);
  wire falling_new = !state_falling && falling_start;

  // Y-pos of player increases gradually
  wire [9:0] y_val_player_display, y_val_player_display_nxt;
  FDRE #(.INIT(1'b0)) ff_player_y0 (.R(resuming || btnR), .C(clk), .CE(tick_frame), .D(y_val_player_display_nxt[0]), .Q(y_val_player_display[0]));
  FDRE ff_player_y [9:1] (.R(resuming || btnR), .C(clk), .CE(tick_frame), .D(y_val_player_display_nxt[9:1]), .Q(y_val_player_display[9:1]));

  wire [9:0] stepping_downward = (10'd2 + y_val_player_display <= 10'd440) ? y_val_player_display + 10'd2 : 10'd440;
  assign y_val_player_display_nxt = (state_falling && tick_frame) ? stepping_downward 
                                    : (falling_start && tick_frame) ? po  
                                    : y_val_player_display;

  // Once bottom is reached, stop falling 
  wire falling_stop = (y_val_player_display == 10'd440) && state_falling;

  // Updating the register for the falling player's state
  assign nxt_falling_state = state_falling | falling_start;
  FDRE #(.INIT(1'b0)) ff_FP (.R(resuming || btnR), .C(clk), .CE(1'b1), .D(nxt_falling_state), .Q(state_falling));

  // Counting the number of lives 
  wire [1:0] num_lives;
  wire [1:0] player_lives = btnR ? 2'd3 
                            : falling_new ? num_lives - 2'd1 
                            : num_lives;
                            
  wire enabling_lives = falling_new || btnR;
  FDRE #(.INIT(1'b1)) ff_LIVES [1:0] (.R(1'b0), .C(clk), .CE(enabling_lives), .D(player_lives), .Q(num_lives));

  // Logic for falling player's flashing impact 
  wire flashing_player;
  wire [5:0] flashing_player_count, nxt_flashing_player_count;
  wire allow_flashing = falling_stop || state_falling;
  wire flashing_player_count_ending = allow_flashing & tick_frame & (flashing_player_count == 6'd29);
  
  assign nxt_flashing_player_count = flashing_player_count_ending ? 6'd0 
                                     : (tick_frame & allow_flashing) ? flashing_player_count + 6'd1 
                                     : flashing_player_count;
  
  FDRE #(.INIT(1'b0)) ff_player_count0 (.R(resuming || btnR), .C(clk), .CE(1'b1), .D(nxt_flashing_player_count[0]), .Q(flashing_player_count[0]));
  FDRE ff_player_count [5:1] (.R(resuming || btnR), .C(clk), .CE(1'b1), .D(nxt_flashing_player_count[5:1]), .Q(flashing_player_count[5:1]));

  // When counting is done, enable the flashing signal 
  wire flashing_signal = flashing_player_count_ending ? ~flashing_player : flashing_player;
  FDRE #(.INIT(1'b0)) ff_pflash (.C(clk), .CE(1'b1), .D(flashing_signal), .Q(flashing_player), .R(btnR || resuming));

  // Helps move the ball and keeping track of the scoreboard
  wire [9:0] x_val_ball, y_val_ball;
  wire [7:0] scoreboard;
  wire ball, flashing_ball;

  wire [9:0] y_val_disp = state_falling ? y_val_player_display : po;
  wire [9:0] top_pixel_y = 10'd16 + y_val_disp;
  wire [9:0] bottom_pixel_y = 10'd15 + top_pixel_y;

  // Detecting any collides between ball and player 
  wire overlapping0 = (bottom_pixel_y > y_val_ball) && (top_pixel_y  < y_val_ball + 10'd8);
  wire overlapping1 = (x_val_player_rightward > x_val_ball) && (x_val_player_leftward < x_val_ball + 10'd8);
  wire tagging = overlapping0 && overlapping1 && ball;

  // Ball Control Instantiation
  Ball_Control BC 
  (
    .clk_in(clk),
    .reset_in(btnR),
    .tick_frame(tick_frame),
    .rand_num(rand_num),
    .tagging(tagging),
    .going_in(making_hole),
    .x_val_ball(x_val_ball),
    .y_val_ball(y_val_ball),
    .ball(ball),
    .flashing_ball(flashing_ball),
    .scoreboard(scoreboard)
  );

  // Pixel Address Instantiation (Converting the states of the objects into pixelated colors)
  Pixel_Address PA 
  (
    .clk_in(clk),
    .reset_in(btnR),
    .active_region(active_region),
    .x_val(x_val),
    .y_val(y_val),
    .x_val_pixel(x_val_player),
    .y_val_pixel(y_val_disp),
    .x_hole(x_hole),
    .y_hole(y_hole),
    .moving_left_hole(moving_left_hole),
    .ending_hole(ending_hole),
    .x_val_coin(10'd0), 
    .y_val_coin(10'd0),
    .tagging(tagging),
    .power_bar(pb),
    .x_val_ball(x_val_ball),
    .y_val_ball(y_val_ball),
    .ball(ball & ~state_falling),
    .flashing_ball(flashing_ball & ~state_falling),
    .flashing_player(flashing_player),
    .Red_VGA(vgaRed),
    .Green_VGA(vgaGreen),
    .Blue_VGA(vgaBlue)
  );

  // Logic for Scoreboard 
  wire [15:0] n = {8'd0, scoreboard}; 
  wire [3:0]  H, DATA;

  
  // Hex7Seg Instantiation
  hex7seg H7S (.N(H), .Seg(seg));
  
  // Ring Counter Instantiation
  ring_counter RC (.advance_in(digsel), .clk_in(clk), .data_out(DATA));

  // Selector Instantiation (for scoreboard)
  selector sel (.n(n), .Sel(DATA), .h(H));
  

  // only 2 digits are allowed
  assign an[3:2] = 2'b11;
  assign an[1:0] = ~DATA;
  

  // Using the LEDs to display the player's lives
  assign led[15:3] = 13'b0;
  assign led[2] = (num_lives > 2'd2);
  assign led[1] = (num_lives > 2'd1);
  assign led[0] = (num_lives > 2'd0);
  
  // Deep Port assignment
  assign dp = 1'b1;

endmodule