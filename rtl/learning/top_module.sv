module top_module (
    input wire clk, 
    input wire rst,  
    output wire pulse_out
);

    //Internal wire- Blinky's pulse becomes the trigger source
    wire pulse_from_blinky;

    blinky dut1 (
        .clk(clk),
        .rst(rst),                 
        .enable(1'b1),              //.enable(enable) If you wanted a phyical switch/button to control enable. 
        //.JA1(),                   //not connected
        .pulse(pulse_from_blinky)   //output goes to internal
    );


    single_pulse dut2 (
        .clk(clk),
        .rst(rst),
        .trigger(pulse_from_blinky),  //input comes from same wire
        .pulse_out(pulse_out)
    );

endmodule