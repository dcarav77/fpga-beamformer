//---------------------------------------------------------------
// echo_uart_bridge.sv
//
// Purpose:
// Packetize a 32-bit echo_count value and send it over UART.
//
// Packet format:
//   0xAA
//   echo_count[7:0]
//   echo_count[15:8]
//   echo_count[23:16]
//   echo_count[31:24]
//
// Notes:
// - UART sends one byte at a time.
// - byte_to_send is loaded first.
// - tx_start is pulsed one clock later.
//---------------------------------------------------------------

module echo_uart_bridge (
    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] echo_count,
    input  wire        busy,

    output reg  [7:0]  byte_to_send,
    output reg         tx_start
);

    localparam IDLE      = 2'd0;
    localparam LOAD_BYTE = 2'd1;
    localparam START_TX  = 2'd2;
    localparam WAIT_BUSY = 2'd3;

    reg [1:0]  state;
    reg [31:0] last_echo_count;
    reg [31:0] latched_echo_count;
    reg [2:0]  byte_index;

    always @(posedge clk) begin
        if (rst) begin
            state              <= IDLE;
            byte_to_send       <= 8'd0;
            tx_start           <= 1'b0;
            last_echo_count    <= 32'd0;
            latched_echo_count <= 32'd0;
            byte_index         <= 3'd0;
        end else begin
            tx_start <= 1'b0;

            case (state)

                IDLE: begin
                    if (echo_count != last_echo_count) begin
                        latched_echo_count <= echo_count;
                        last_echo_count    <= echo_count;
                        byte_index         <= 3'd0;
                        state              <= LOAD_BYTE;
                    end
                end

                LOAD_BYTE: begin
                    case (byte_index)
                        3'd0: byte_to_send <= 8'hAA;                    // ← START BYTE added here!
                        3'd1: byte_to_send <= latched_echo_count[7:0];
                        3'd2: byte_to_send <= latched_echo_count[15:8];
                        3'd3: byte_to_send <= latched_echo_count[23:16];
                        3'd4: byte_to_send <= latched_echo_count[31:24];
                        default: byte_to_send <= 8'd0;
                    endcase

                    state <= START_TX;
                end

                START_TX: begin
                    if (!busy) begin
                        tx_start <= 1'b1;
                        state    <= WAIT_BUSY;
                    end
                end

                WAIT_BUSY: begin
                    if (busy) begin
                        state <= WAIT_BUSY;
                    end else begin
                        if (byte_index == 3'd4) begin
                            state <= IDLE;
                        end else begin
                            byte_index <= byte_index + 1'b1;
                            state      <= LOAD_BYTE;
                        end
                    end
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule