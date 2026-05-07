`timescale 1ns/1ps  // 1 time unit = 1ns, precision = 1ps

// =====================================================
// DUT
// =====================================================
module top_module #(
    parameter ONE_SECOND = 27'd4  // ONE_SECOND=4 for fast simulation
)(
    input clk,
    input reset,
    input enable,

    output reg JA1,
    output reg pulse
);
    reg [26:0] q; 

    always @(posedge clk) begin
        if (reset) begin
            q <= 0;
            JA1 <= 0;
            pulse <= 0;
        end
        else if (enable) begin
            if (q == ONE_SECOND) begin
                q <= 0;
                JA1 <= ~JA1;
                pulse <= 1;
            end
            else begin
                q <= q + 1;
                pulse <= 0;
            end
        end
        else begin
            pulse <= 0;       //Enable=0 means counter is stopped, q stays at 0
        end
    end

endmodule

// =====================================================
// TESTBENCH
// =====================================================
module tb_blinky;

    // inputs to DUT
    reg clk;
    reg reset;
    reg enable;

    // outputs from DUT
    wire JA1;
    wire pulse;

    // instantiate DUT
    top_module uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .JA1(JA1),
        .pulse(pulse)
    );

    // clock generation - 100MHz (10ns period)
    initial begin
        clk = 0;
        forever #5ns clk = ~clk;  // 5ns half-cycle = 10ns period = 100MHz
    end

    // initialize Inputs
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_blinky);

        reset  = 1;
        enable = 0;
        
        #20ns;  // Hold reset for 20ns
        reset = 0;
        
        #10ns;  // Wait 10ns then enable
        enable = 1;

        #200ns;  // Run for 200ns then finish
        $finish;
    end

    // Monitor signals (prints when any signal changes)
    initial begin
        $monitor(
            "time=%0t reset=%b enable=%b q=%0d JA1=%b pulse=%b",
            $time, reset, enable, uut.q, JA1, pulse
        );
    end
  
    // Add edge-by-edge for detailed view
    always @(posedge clk) begin
        $display("EDGE %0t: q=%0d pulse=%b JA1=%b", 
                 $time, uut.q, pulse, JA1);
    end

    // Count rollovers
    initial begin
        integer rollover_count = 0;
        forever @(posedge pulse) begin
            rollover_count = rollover_count + 1;
            $display("ROLLOVER #%0d at time %0t, JA1=%b", 
                     rollover_count, $time, JA1);
        end
    end

    // Verify clock period (debug)
    initial begin
        integer last_time = 0;
        forever @(posedge clk) begin
            if (last_time != 0) begin
                if ($time - last_time != 10)
                    $display("WARNING: Clock period = %0t ns (expected 10ns)", 
                             $time - last_time);
            end
            last_time = $time;
        end
    end

endmodule