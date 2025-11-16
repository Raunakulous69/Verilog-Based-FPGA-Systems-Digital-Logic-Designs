`timescale 1ns / 1ps

module Ball_Control 
(
  input  wire [7:0] rand_num,  
  input  wire clk_in,       
  input  wire reset_in,     
  input  wire tick_frame,  
  input  wire tagging,         
  input  wire going_in,        

  output wire [9:0] x_val_ball,      
  output wire [9:0] y_val_ball, 
  output wire [7:0] scoreboard,     
  output wire ball,    
  output wire flashing_ball           
);

  // Tagging signal's edge detection
  wire detect_tagging;
  wire pulse_tagging = tagging & ~detect_tagging;
  FDRE #(.INIT(1'b0)) register_tagged (.R(reset_in), .C(clk_in), .CE(1'b1), .D(tagging), .Q(detect_tagging));
   
  // State registers from Finite State Machine for flashing and moving modes
  wire moving, flashing, moving_next, flashing_next;
  FDRE #(.INIT(1'b0)) SR0 (.R(reset_in), .C(clk_in), .CE(1'b1), .D(moving_next), .Q(moving));
  FDRE #(.INIT(1'b0)) SR1 (.R(reset_in), .C(clk_in), .CE(1'b1), .D(flashing_next), .Q(flashing));

  // Conditions for the modes in Finite State Machine
  wire moving_mode  = ~flashing &  moving;
  wire flashing_mode =  flashing & ~moving;

  // Detecting when game's ball is leaving the screen's left edge
  wire leaving_left = (x_val_ball < 10'd4);

  // Logic for the flashing counter
  wire [7:0] flashing_counter; 
  wire exit_reloading = (moving_mode & leaving_left) | going_in; 
  wire zero_flashing = (flashing_counter == 8'd0);
  wire flashing_to = moving_mode & pulse_tagging; 
  wire flashing_exit = flashing_mode & (tick_frame & zero_flashing); 

  // Transitioning logic of Finite State Machine 
  assign moving_next = (moving_mode & ~pulse_tagging)
                       | (~flashing & ~moving & going_in)  
                       | (flashing_mode & flashing_exit);
  
  assign flashing_next = (flashing_mode & ~flashing_exit) | (moving_mode &  pulse_tagging);

  // Logic for updating the flashing counter
  wire [7:0] counting_next_flashing = flashing_to ? 8'd119 
                                      : (flashing_mode & tick_frame) ? flashing_counter - 8'd1 
                                      : flashing_counter;
  
  FDRE #(.INIT(1'b0)) flash_counter [7:0] (.R(reset_in), .C(clk_in), .CE(1'b1), .D(counting_next_flashing[7:0]), .Q(flashing_counter[7:0]));

  // Increasing the score after leaving the flashing mode
  wire [7:0] scoreboard_next = (flashing_exit ? 8'd1 : 8'd0) + scoreboard;
  FDRE #(.INIT(1'b0)) score_counter [7:0] (.R(reset_in), .C(clk_in), .CE(1'b1), .D(scoreboard_next[7:0]), .Q(scoreboard[7:0]));

  // Logic for controlling the game ball's positioning reload
  wire moving_from = moving_mode;
  wire moving_to = (moving_next & ~flashing_next);  
  wire flashing_from = flashing_mode;
  wire reloading = moving_to & (flashing_from | exit_reloading | ~moving_from);

  // If reloading is on, reset to right edge or else, decrease the X position otherwise
  wire [9:0] x_decreasing = x_val_ball - 10'd4;
  wire [9:0] x_next = reloading ? 10'd640 
                      : (moving_mode & tick_frame) ? x_decreasing 
                      : x_val_ball;

  // For the Y values, limiting the random numbers from only 0 to 60
  wire [5:0] raw_val_6 = rand_num[5:0];
  wire [5:0] random_module = (raw_val_6 <= 6'd60) ? raw_val_6 : raw_val_6 - 6'd61;

  // When reloading is on, start randomizing the vertical position
  wire [9:0] y_next = reloading ? (10'd192 + {4'b0, random_module}) : y_val_ball;

  // Register for Ball X's pos
  FDRE #(.INIT(1'b0)) ff_X0 (.R(1'b0), .C(clk_in), .CE(1'b1), .D(x_next[0]), .Q(x_val_ball[0]));
  FDRE ff_X [9:1] (.R(1'b0), .C(clk_in), .CE(1'b1), .D(x_next[9:1]), .Q(x_val_ball[9:1]));

  // Register for Ball Y's pos
  FDRE #(.INIT(1'b0)) ff_Y0 (.R(1'b0), .C(clk_in), .CE(1'b1), .D(y_next[0]), .Q(y_val_ball[0]));
  FDRE ff_Y [9:1] (.R(1'b0), .C(clk_in), .CE(1'b1), .D(y_next[9:1]), .Q(y_val_ball[9:1]));

  // Outputs for Ball Control
  assign flashing_ball = flashing_counter[5] & flashing_mode;
  assign ball = flashing_mode | moving_mode;
  
endmodule