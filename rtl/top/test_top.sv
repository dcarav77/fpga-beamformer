module top_module (
    input  wire clk, 
    input  wire rst,
    input  wire echo_in,
    output wire pulse_out,
    output wire uart_tx
);

    wire pulse_from_blinky;
    logic [31:0] echo_count;

    // UART test signals
    logic start;
    logic [7:0] tx_byte;
    wire busy;

    // Send ASCII "A"
    assign tx_byte = 8'h41;

    // simple 1-second timer to trigger UART
    logic [26:0] one_sec_count;

    always_ff @(posedge clk) begin
        if (rst) begin
            one_sec_count <= 0;
            start <= 1'b0;
        end else begin
            start <= 1'b0;

            if (one_sec_count == 27'd99_999_999) begin
                one_sec_count <= 0;

                if (!busy)
                    start <= 1'b1;   // one-clock pulse
            end else begin
                one_sec_count <= one_sec_count + 1'b1;
            end
        end
    end

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

    uart_tx dut4 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .tx_byte(tx_byte),
        .uart_tx(uart_tx),
        .busy(busy)
    );

endmodule



