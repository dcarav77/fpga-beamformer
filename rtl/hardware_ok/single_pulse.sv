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

module single_pulse #(
    parameter int CLOCK_HZ = 100_000_000,   // System clock frequency
    parameter int PULSE_US = 10             // Desired pulse width in µs
)(
    input wire clk,
    input wire rst,    
    input wire trigger, //external button  (periodic pulse gen output comes here)
    output reg pulse_out 

);
  // Calculate how many clock cycles for the pulse
  localparam int PULSE_CYCLES = (CLOCK_HZ / 1_000_000) * PULSE_US;

  // Calculate how many bits needed for the counter
  localparam int COUNTER_WIDTH = $clog2(PULSE_CYCLES);

    //internal registers:
    reg[COUNTER_WIDTH - 1:0] counter;
    reg trigger_prev;
    reg busy;

    //on reset, you should clear all state registers
    always @ (posedge clk) begin
        if (rst) begin
            trigger_prev  <= 1'b0;
            counter       <= 0;
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
            counter     <= 0;
          //counter     <= 24'd0;
        end
        
        //else if busy 
            //keep pulse running and count
        else if (busy) begin
            if (counter == PULSE_CYCLES - 1) begin
                busy        <= 1'b0;
                pulse_out   <= 1'b0;
                counter     <= 0;
              //counter     <= 24'd0;
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
    end
end
  
endmodule