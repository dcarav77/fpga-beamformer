//It's also a state machine, that decides which byte to send next

// Checks that the FIFO is not empty.
// Checks that UART is not busy.
// Pulses fifo_read_enable.
// Receives fifo_data_out.
// Sends its four bytes through the UART FSM.

module echo_uart_bridge (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] echo_count,
    input  wire        fifo_empty,

    input  wire        busy,
    output reg  [7:0]  byte_to_send,
    output reg         tx_start,
    output reg         fifo_read_enable  //read command
);

    localparam IDLE      = 3'd0;
    localparam WAIT_FIFO = 3'd1;
    localparam LOAD_BYTE = 3'd2;
    localparam REQUEST_TX  = 3'd3;  
    localparam WAIT_BUSY = 3'd4;


    reg [2:0]  state; 
    reg [31:0] echo_count_snapshot; 
    reg [2:0]  byte_index;

    always @(posedge clk) begin
        if (rst) begin
            state              <= IDLE;
            byte_to_send       <= 8'd0;
            tx_start           <= 1'b0;       
            echo_count_snapshot<= 32'd0;
            byte_index         <= 3'd0;
            fifo_read_enable   <= 1'b0;  //new 
        
        end else begin
            
            tx_start            <= 1'b0;
            fifo_read_enable    <= 1'b0;

            case (state)
                IDLE: begin
                    if (!fifo_empty && !busy) begin
                        fifo_read_enable    <= 1'b1;                    
                        byte_index          <= 3'd0;
                        state               <= WAIT_FIFO;
                    end
                end

                WAIT_FIFO: begin
                    //FIFO reads here 
                    state <= LOAD_BYTE;
                end


                LOAD_BYTE: begin
                    case (byte_index)
                        
                        3'd0: begin
                            echo_count_snapshot <= echo_count;
                            byte_to_send        <= 8'hAA;
                        end

                        3'd1: byte_to_send <= echo_count_snapshot[7:0];
                        3'd2: byte_to_send <= echo_count_snapshot[15:8];
                        3'd3: byte_to_send <= echo_count_snapshot[23:16];
                        3'd4: byte_to_send <= echo_count_snapshot[31:24];
                        
                        default: byte_to_send <= 8'd0;
                    endcase
                    state <= REQUEST_TX; 
                end

                REQUEST_TX: begin 
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