//-------------------------------------------------------------
// single_pulse_v0.sv
//
// Purpose:
// Generates a precise 10 µs trigger pulse.
//
// Triggered by:
//
// single pulse generator
//
// Output:
//
// pulse_out -> JA1 -> HC-SR04 TRIG
//
// Concepts:
// - One-shot pulse generation
// - Edge detection
// - Clock cycle counting
//-------------------------------------------------------------

module single_pulse (
    input wire clk,
    input wire rst,    
    input wire trigger, //external button  (periodic pulse gen output comes here)
    output reg pulse_out 

);

    localparam PULSE_CYCLES = 10'd1000;
  //localparam PULSE_CYCLES = 24'd5000000;

    //internal registers: 
    reg [9:0] counter;
  //reg [23:0] counter;
    reg trigger_prev;
    reg busy;

    //on reset, you should clear all state registers
    always @ (posedge clk) begin
        if (rst) begin
            trigger_prev  <= 1'b0;
            counter       <= 10'd0;
          //counter       <= 24'd0;
            pulse_out     <= 1'b0; 
            busy          <= 1'b0;
        end
        
        else begin 
            // Store previous trigger value 
            trigger_prev  <= trigger; 

            //start pulse
        if ((trigger && !trigger_prev) && !busy) begin     
            busy        <= 1'b1;
            pulse_out   <= 1'b1;
            counter     <= 10'd0;
          //counter     <= 24'd0;
        end
        
        //else if busy 
            //keep pulse running and count
        else if (busy) begin
            if (counter == PULSE_CYCLES - 1) begin
                busy        <= 1'b0;
                pulse_out   <= 1'b0;
                counter     <= 10'd0;
              //counter     <= 24'd0;
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
    end
end
  
endmodule