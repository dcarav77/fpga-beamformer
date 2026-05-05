// ===== TESTBENCH =====
module tb_blinky;

  reg clk;
  reg reset;
  wire JA1;

  top_module uut (
    .clk(clk),
    .reset(reset),
    .JA1(JA1)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_blinky);

    clk = 0;
    reset = 1;

    #20;
    reset = 0;

    #200;
    $finish;
  end

  initial begin
    $monitor("time=%0t reset=%b q=%0d JA1=%b",
             $time, reset, uut.q, JA1);
  end

endmodule