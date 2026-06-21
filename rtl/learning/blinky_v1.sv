//-------------------------------------------------------------
// Purpose:
// Generates a slow timing event (once per second).
//
// This module DOES NOT directly drive the HC-SR04 sensor.
//
// It simply creates a short "pulse" every 1 second that tells
// single_pulse.sv when to generate a precise trigger pulse.
//
// Architecture:
//
// blinky
//    ↓
// pulse
//    ↓
// single_pulse
//    ↓
// pulse_out -> JA1 -> HC-SR04 TRIG
//-------------------------------------------------------------

module blinky (
	input clk,
	input rst,
    input enable,
	
    output reg JA1,
    output reg pulse     //this will need to go to a pin (constraints)
   
);
  
  reg [26:0] q; 
  
  localparam ONE_SECOND = 27'd99_999_999;  
  
always @(posedge clk) begin
    if (rst) begin  //reset must clear pulse too
       q <= 27'd0;
       JA1 <= 1'b0;
       pulse <= 1'b0; 
    end
    
    else if (enable) begin      
        if (q == ONE_SECOND) begin
            // Terminal count: wrap, generate pulse, toggle LED
            q <= 27'd0;  
            JA1 <= ~JA1;
            pulse <= 1'b1;         

        end
        else begin
            // Normal increment
            q <= q + 1'b1;
            pulse <= 1'b0;  //clear pulse on non terminal cycles
        end
    end
        else begin
            pulse <= 1'b0;
        end
end

endmodule 