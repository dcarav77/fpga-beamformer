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

    input  wire [31:0] echo_count,
    input  wire        busy,

    output reg  [7:0]  byte_to_send,
    output reg         tx_start
);

    reg [31:0] last_echo_count;
    reg [31:0] latched_echo_count;
    reg [1:0]  byte_index;
    reg        sending_packet;

    always @(posedge clk) begin
        if (rst) begin
            byte_to_send       <= 8'd0;
            tx_start           <= 1'b0;
            last_echo_count    <= 32'd0;
            latched_echo_count <= 32'd0;
            byte_index         <= 2'd0;
            sending_packet     <= 1'b0;
        end else begin
            tx_start <= 1'b0;

            if ((echo_count != last_echo_count) && !busy && !sending_packet) begin
                latched_echo_count <= echo_count;
                last_echo_count    <= echo_count;
                byte_index         <= 2'd0;
                sending_packet     <= 1'b1;
            end

            if (sending_packet && !busy) begin
                case (byte_index)
                    2'd0: byte_to_send <= latched_echo_count[7:0];
                    2'd1: byte_to_send <= latched_echo_count[15:8];
                    2'd2: byte_to_send <= latched_echo_count[23:16];
                    2'd3: byte_to_send <= latched_echo_count[31:24];
                endcase

                tx_start <= 1'b1;

                if (byte_index == 2'd3) begin
                    sending_packet <= 1'b0;
                end else begin
                    byte_index <= byte_index + 1'b1;
                end
            end
        end
    end

endmodule