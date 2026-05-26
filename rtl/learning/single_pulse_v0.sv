// reset works
// trigger starts pulse

// pulse stays high for 1000 cycles // 10 bits
// pulse goes low after terminal count

// busy high during pulse
// trigger during busy is ignored
// second trigger after done works

//Pulse cycles = 1,000. at 100Mhz. 
//1,000 x 10 ns = 10 us (tiny pulse)

module single_pulse (
    input wire clk,
    input wire rst,    
    input wire trigger, //external button  (blinky pulse output comes here)
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