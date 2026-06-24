// 1. FPGA sends TRIG pulse
// 2. HC-SR04 sends 8 ultrasonic bursts
// 3. ECHO goes HIGH
// 4. Your FPGA counter starts
// 5. Sound hits book and returns
// 6. ECHO goes LOW
// 7. Your FPGA saves counter value

// At 100 MHz: 1 counter tick = 10 ns
// So if echo_count = 100,000 then: 100,000 × 10 ns = 1 ms
// That means the echo pulse was high for 1 ms

module echo_timer (
    input wire clk,
    input wire rst,
    input wire echo_in, // ← INPUT from sensor
    output reg [31:0] echo_count,
    output reg measurement_ready
    
   
);
    //internal registers
    reg measuring;
    reg [31:0] counter;


    //on reset, you should clear all state registers
    always @ (posedge clk) begin
        if (rst) begin
                echo_count          <= 32'd0;
                counter             <= 32'd0;
                measuring           <= 1'b0;
                measurement_ready   <= 1'b0;
            end

        //Echo goes HIGH, start measuring
        else begin
            if (!measuring && echo_in) begin
                measuring           <= 1'b1;
                counter             <= 32'd0;
            end
        
        //Echo is still HIGH → keep counting
        else if ((measuring && echo_in)) begin 
                counter <= counter + 1'b1;
            end

        // Echo signal finished -> save the final counter value
        else if ((measuring && !echo_in))begin               
                measuring         <= 1'b0;
                echo_count        <= counter;
                measurement_ready <= 1'b1;
            end
        end
    end
endmodule







