`timescale 1ns / 1ps

module Syncs 
(
  input  wire clk_in,     
  input  wire reset_in,   
  
  output wire [15:0] x_val,       
  output wire [15:0] y_val,
  output wire H_sync,
  output wire V_sync,      
  output wire sync_frame,  
  output wire active_region    
);

  // Counting horizontally from 0 to 799
  wire [15:0] H_count, next_H_count;
  wire wrap_H = (H_count == 16'd799);

  assign next_H_count = wrap_H ? 16'd0 : (H_count + 16'd1);

  FDRE #(.INIT(1'b0)) ff_H [15:0] (.R(reset_in), .C(clk_in), .CE(1'b1), .D(next_H_count[15:0]), .Q(H_count[15:0]));

  wire [15:0] V_count, next_V_count;
  wire increase_V  = wrap_H;                
  wire wrap_V = wrap_H && (V_count == 16'd524);

  assign next_V_count = wrap_V ? 16'd0 
                        : increase_V  ? (V_count + 16'd1) 
                        : V_count;

  FDRE #(.INIT(1'b0)) ff_V [15:0] (.R(reset_in), .C(clk_in), .CE(1'b1), .D(next_V_count[15:0]), .Q(V_count[15:0]));

  // Sync Pulse (horizontal) that is active low between 656 nd 751
  wire H_sync_pulse = ~((H_count < 16'd752) && (H_count >= 16'd656));
  
  // Sync Pulse (vertical) that is active low between 489 and 490
  wire V_sync_pulse = ~((V_count < 16'd491) && (V_count >= 16'd489));
  
  // Outputs for Hsync and Vsync
  assign H_sync = H_sync_pulse;
  assign V_sync = V_sync_pulse;

  // Within the 640*480 display area, the region should be active
  assign active_region = (H_count < 16'd640) && (V_count < 16'd480);

  // Coordinates for the pixels (Pixel Outputs)
  assign x_val = H_count;
  assign y_val = V_count;

  // Detecting Vsync's rising edge to determine the starting of a new frame
  wire prev_V;
  FDRE #(.INIT(1'b0)) ff_Vprev (.R(reset_in), .C(clk_in), .CE(1'b1), .D(V_sync), .Q(prev_V));
  
  assign sync_frame = V_sync && (~prev_V);

endmodule
