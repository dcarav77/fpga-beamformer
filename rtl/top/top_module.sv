module top_module (
    input  wire clk, 
    input  wire rst,
    input  wire echo_in,
    output wire pulse_out,
    output wire uart_tx
);
    
    //Connecting Wires (Cables)
    wire measurement_tick;          // Connects output of periodic_pulse_generator → Input of single_pulse.trigger
    wire [31:0] echo_count;         // Stores measured ECHO pulse width in clock cycles
    wire [7:0]  byte_to_send;       // 8 bit data that will transmitted over UART
    wire        tx_start;           // One clock cycle signal that tells UART to begin transmitting
    wire        busy;


    //FIFO wires 
    wire        fifo_read_enable;
    wire        full;
    wire        empty;
    wire [31:0] echo_count_out;
    wire        measurement_ready;

    //left  side of. is the module port
    //right side of. is the wire                 

    periodic_pulse_generator #(
        .CLOCK_HZ(100_000_000),
        .PERIOD_MS(5000) //was 1000
    ) dut1 (
        .clk(clk),
        .rst(rst),                                  
        .pulse_out(measurement_tick)
    );

    single_pulse dut2 (
        .clk(clk),
        .rst(rst),
        .trigger(measurement_tick),
        .pulse_out(pulse_out)
    );

    echo_timer dut3 (
        .clk(clk),
        .rst(rst),
        .echo_in(echo_in),
        .echo_count(echo_count),
        .measurement_ready(measurement_ready)
    );

    fsm_uart_tx dut4 (
        .clk(clk),
        .rst(rst),
        .byte_to_send(byte_to_send),
        .tx_start(tx_start),
        .uart_tx(uart_tx),
        .busy(busy)
    );

    echo_uart_bridge dut5 (
        .clk(clk),
        .rst(rst),
        .echo_count(echo_count_out),
        .fifo_empty(empty),
        .busy(busy),
        .byte_to_send(byte_to_send),
        .tx_start(tx_start),
        .fifo_read_enable(fifo_read_enable)
    );

    fifo_echo_bridge dut6 (
        .clk(clk),
        .rst(rst),
        .echo_count_in(echo_count),
        .measurement_ready_in(measurement_ready),
        .echo_count_out(echo_count),
        .fifo_read_enable(fifo_read_enable),
        .full(full),
        .empty(empty)     
    );

endmodule



