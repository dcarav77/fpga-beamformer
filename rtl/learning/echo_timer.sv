// What the echo counter does
// Instead of counting to create a pulse, it counts while ECHO is high.

// single_pulse:
// counting CREATES time

// echo_timer:
// counting MEASURES time

module echo_time (
    input wire clk,
    input wire rst,
    input wire echo_in, // ← INPUT from sensor
    output reg [31:0] echo_count
   
);
    //internal registers
    reg measuring;
    reg [31:0] counter;


    //on reset, you should clear all state registers
    always @ (posedge clk) begin
        if (rst) begin
                echo_count      <= 32'd0;
                counter         <= 32'd0;
                measuring       <= 1'b0;
            end

        else begin
            //Echo goes HIGH, start measuring
            if (!measuring && echo_in) begin
                // Echo just went HIGH → start measuring
                measuring <= 1'b1;
                counter   <= 32'd0;
            end

        else if ((measuring && echo_in)) begin
                //Echo is still HIGH → keep counting
                counter <= counter + 1'b1;
            end

        else if ((measuring && !echo_in))begin
                // Echo signal finished- save the final counter value
                measuring   <= 1'b0;
                echo_count  <= counter;
            end
        end
    end
endmodule







