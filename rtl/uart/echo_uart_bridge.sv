module echo_uart_bridge (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] echo_count,
    input  wire        measurement_ready,  // ← NEW!
    input  wire        busy,
    output reg  [7:0]  byte_to_send,
    output reg         tx_start
);

    localparam IDLE      = 2'd0;
    localparam LOAD_BYTE = 2'd1;
    localparam START_TX  = 2'd2;
    localparam WAIT_BUSY = 2'd3;

    reg [1:0]  state; 
    reg [31:0] echo_count_snapshot;
    reg [2:0]  byte_index;

    always @(posedge clk) begin
        if (rst) begin
            state              <= IDLE;
            byte_to_send       <= 8'd0;
            tx_start           <= 1'b0;       
            echo_count_snapshot<= 32'd0;
            byte_index         <= 3'd0;
        
        end else begin
            
            tx_start <= 1'b0;

            case (state)
                IDLE: begin
                    if (measurement_ready) begin
                        echo_count_snapshot <= echo_count;  //Freeze, take a photo!               
                        byte_index          <= 3'd0;
                        state               <= LOAD_BYTE;
                    end
                end

                LOAD_BYTE: begin
                    case (byte_index)
                        3'd0: byte_to_send <= 8'hAA;
                        3'd1: byte_to_send <= echo_count_snapshot[7:0];
                        3'd2: byte_to_send <= echo_count_snapshot[15:8];
                        3'd3: byte_to_send <= echo_count_snapshot[23:16];
                        3'd4: byte_to_send <= echo_count_snapshot[31:24];
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

                default: state <= IDLE;
            endcase
        end
    end
endmodule