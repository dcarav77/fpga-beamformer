//---------------------------------------------------------------
// echo_uart_bridge.sv
//
// Purpose:
// Bridge module between echo_timer and fsm_uart_tx.
//
// Problem:
// echo_timer outputs a 32-bit echo_count.
// fsm_uart_tx sends one 8-bit byte at a time.
//
// This version sends echo_count[7:0] whenever echo_count changes
// and the UART is not busy.
//---------------------------------------------------------------

module echo_uart_bridge (
    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] echo_count,      // from echo_timer
    input  wire        busy,            // from fsm_uart_tx

    output reg  [7:0]  byte_to_send,    // to fsm_uart_tx
    output reg         tx_start         // to fsm_uart_tx
);

    reg [31:0] last_echo_count;

    always @(posedge clk) begin
        if (rst) begin
            byte_to_send    <= 8'd0;
            tx_start        <= 1'b0;
            last_echo_count <= 32'd0;
        end else begin
            tx_start <= 1'b0; // default: no send

            if ((echo_count != last_echo_count) && !busy) begin
                byte_to_send    <= echo_count[7:0];
                tx_start        <= 1'b1;       // one-clock pulse
                last_echo_count <= echo_count;
            end
        end
    end

endmodule