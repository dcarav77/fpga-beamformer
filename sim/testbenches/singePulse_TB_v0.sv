`timescale 1ns/1ps

// =====================================================
// DUT
// =====================================================

module top_module (
    input wire clk,
    input wire rst,    
    input wire trigger,
    output reg pulse_out 
);

    localparam PULSE_CYCLES = 10'd1000;

    reg [9:0] counter;
    reg trigger_prev;
    reg busy;

    always @(posedge clk) begin
        if (rst) begin
            trigger_prev  <= 1'b0;
            counter       <= 10'd0;
            pulse_out     <= 1'b0; 
            busy          <= 1'b0;
        end
        else begin 
            trigger_prev  <= trigger; 

            if ((trigger && !trigger_prev) && !busy) begin     
                busy        <= 1'b1;
                pulse_out   <= 1'b1;
                counter     <= 10'd0;
            end
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

// =====================================================
// TESTBENCH
// =====================================================

module tb_singlePulse;
    reg clk;
    reg rst;
    reg trigger;
    wire pulse_out;

    top_module uut (
        .clk(clk),
        .rst(rst),
        .trigger(trigger),
        .pulse_out(pulse_out)
    );

    // 100 MHz clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_singlePulse);

        rst = 1;
        trigger = 0;

        #20;
        rst = 0;

        #10;
        trigger = 1;

        #20;
        trigger = 0;

        #11000; //was #200
        $finish;
    end

initial begin
    $display("-------------------------------------------------------------");
    $display(" time(ns) | rst | trig | count | busy | pulse_out ");
    $display("-------------------------------------------------------------");
end

always @(posedge clk) begin
    $display("%8.1f |  %b  |  %b   | %5d |  %b   |     %b",
             $realtime, rst, trigger, uut.counter, uut.busy, pulse_out);
end

endmodule