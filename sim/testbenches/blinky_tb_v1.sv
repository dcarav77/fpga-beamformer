`timescale 1ns/1ps  //1 = one nanosecond

// =====================================================
// DUT
// =====================================================
module top_module #(
    parameter ONE_SECOND = 27'd4 //ONE_SECOND=4
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

    else if (enable) begin //enable gates the entire counter - When enable=0, nothing changes (q, JA1, pulse all hold values)

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
      pulse <= 0;
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

// clock generation //how do i make this 100mhz?
initial begin
    clk = 0;
    forever #5 clk = ~clk;
    end

// initialize Inputs
initial begin
    reset  = 1;
    enable = 0;
    
    #20;
    reset = 0;
    
    #10;
    enable =1;

    //pulse  = 0;   these are outputs from the DUT
    //JA1    = 0;


    #100;
    $finish;
end

    // Monitor signals
    initial begin
        $monitor(
            "time=%0t reset=%b enable=%b q=%0d JA1=%b pulse=%b",
            $time,
            reset,
            enable,
            uut.q,
            JA1,
            pulse
        );
    end

endmodule

