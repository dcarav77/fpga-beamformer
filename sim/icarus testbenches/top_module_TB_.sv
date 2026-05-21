`timescale 1ns/1ps

// =====================================================
// BLINKY MODULE
// =====================================================
module blinky (
    input wire clk,
    input wire rst,
    input wire enable,
    output reg JA1,
    output reg pulse
);

    reg [3:0] q;

    always @(posedge clk) begin
        if (rst) begin
            q <= 0;
            JA1 <= 0;
            pulse <= 0;
        end
        else if (enable) begin
            if (q == 4) begin
                q <= 0;
                JA1 <= ~JA1;
                pulse <= 1;
            end
            else begin
                q <= q + 1;
                pulse <= 0;
            end
        end
    end

endmodule


// =====================================================
// SINGLE PULSE MODULE
// =====================================================
module single_pulse (
    input wire clk,
    input wire rst,
    input wire trigger,
    output reg pulse_out
);

    reg [3:0] counter;
    reg trigger_prev;
    reg busy;

    always @(posedge clk) begin

        if (rst) begin
            counter <= 0;
            trigger_prev <= 0;
            busy <= 0;
            pulse_out <= 0;
        end

        else begin

            trigger_prev <= trigger;

            if ((trigger && !trigger_prev) && !busy) begin
                busy <= 1;
                pulse_out <= 1;
                counter <= 0;
            end

            else if (busy) begin

                if (counter == 4) begin
                    busy <= 0;
                    pulse_out <= 0;
                    counter <= 0;
                end

                else begin
                    counter <= counter + 1;
                end
            end
        end
    end

endmodule


// =====================================================
// TOP MODULE
// =====================================================
module top_module (
    input wire clk,
    input wire rst,
    output wire pulse_out
);

    wire pulse_from_blinky;

    blinky dut1 (
        .clk(clk),
        .rst(rst),
        .enable(1'b1),
        .JA1(),
        .pulse(pulse_from_blinky)
    );

    single_pulse dut2 (
        .clk(clk),
        .rst(rst),
        .trigger(pulse_from_blinky),
        .pulse_out(pulse_out)
    );

endmodule


// =====================================================
// TESTBENCH
// =====================================================
module tb_top;

    reg clk;
    reg rst;

    wire pulse_out;

    top_module uut (
        .clk(clk),
        .rst(rst),
        .pulse_out(pulse_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);

        rst = 1;

        #20;
        rst = 0;

        #300;

        $finish;
    end

    initial begin
        $display("------------------------------------------------");
        $display(" time | blink_pulse | pulse_out ");
        $display("------------------------------------------------");
    end

    always @(posedge clk) begin
        $display("%5.1f |      %b      |      %b",
                 $realtime,
                 uut.pulse_from_blinky,
                 pulse_out);
    end

endmodule