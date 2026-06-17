module top_module (
    input  wire clk, 
    input  wire rst,
    input  wire echo_in,
    output wire pulse_out,
    output wire uart_tx
);

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

    echo_timer dut3 (
        .clk(clk),
        .rst(rst),
        .echo_in(echo_in),
        .echo_count(echo_count)
    );

    fsm_uart_tx dut4 (
        .clk(clk),
        .rst(rst),
        .byte_to_send(byte_to_send),
        .tx_start(tx_start),
        .uart_tx(uart_tx),
        .busy(busy)
    );

endmodule



