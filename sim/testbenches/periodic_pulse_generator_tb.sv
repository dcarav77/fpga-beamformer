`timescale 1ns/1ps

module periodic_pulse_generator_tb;

    logic clk;
    logic rst;
    logic pulse_out;

    periodic_pulse_generator #(
        .CLOCK_HZ(100_000_000),
        .PERIOD_MS(1)
    ) dut (
        .clk(clk),
        .rst(rst),
        .pulse_out(pulse_out)
    );

    // 100 MHz clock = 10 ns period
    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;

        #25;
        rst = 1'b0;


        #1_200_000;     //wait 1.2 ms

        $finish;
    end

endmodule