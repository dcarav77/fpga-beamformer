// reset works
// trigger starts pulse

// pulse stays high for 1000 cycles // 10 bits
// pulse goes low after terminal count

// busy high during pulse
// trigger during busy is ignored
// second trigger after done works


module circuit (
    input wire clk,
    input wire rst,    
    input wire trigger, //external button  
    output reg pulse_out 

);

    localparam PULSE_CYCLES = 10'd1000;

    //internal registers: 
    reg [9:0] counter;
    reg edge_detector;
    reg trigger_prev;
    reg busy;

    //on reset, you should clear all state registers
    always @ (posedge clk) begin
        if (rst) begin
            trigger_prev  <= 1'b0;
            counter       <= 10'd0;
            pulse_out     <= 1'b0; 
            edge_detector <= 1'b0;
            busy          <= 1'b0;
        end
        
        else begin 
            // Store previous trigger value 
            trigger_prev  <= trigger; 

        //if edge_detector AND not busy: 
            //start pulse
        if ((trigger && !trigger_prev) && !busy) begin     
            busy        <= 1'b1;
            pulse_out   <= 1'b1;
            counter     <= 10'd0;
        end
        
        //else if busy 
            //keep pulse running and count
        else if (busy) begin
            if (counter == PULSE_CYCLES - 1) begin
                busy        <= 1'b0;
                pulse_out   <= 1'b0;
                counter     <= 10'd0;
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
    end
end
  
endmodule