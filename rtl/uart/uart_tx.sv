module uart_tx (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire [7:0] tx_byte,

    output reg        uart_tx,
    output reg        busy
);

    // 115,200 bits/sec UART. 1/115,200 = 8.68
    // 8.68 µs / 10 ns≈ 868 clock cycles
    localparam integer CLKS_PER_BIT = 868; 
//This line assumes:
//Baud rate = 115,200
//Clock frequency = 100 MHz
//100,000,000 / 115,200 ≈ 868
//If you move this module to a different board (e.g., with a 50 MHz clock or 125 MHz clock), it will fail. 
//The timing will be wrong, and your serial data will be garbage.

    reg [31:0] clk_count;
    reg [3:0]  bit_index;
    reg [7:0]  data_reg;

    always @(posedge clk) begin
        if (rst) begin
            uart_tx   <= 1'b1;  // UART IDLE's at HIGH
            busy      <= 1'b0;
            clk_count <= 32'd0;
            bit_index <= 4'd0;
            data_reg  <= 8'd0;
        end else begin

            if (!busy) begin
                uart_tx <= 1'b1;  //If not busy, keep line high

                if (start) begin
                    busy      <= 1'b1;
                    data_reg  <= tx_byte;
                    clk_count <= 32'd0;
                    bit_index <= 4'd0;
                    uart_tx   <= 1'b0; // start bit
                end
            end else begin
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 32'd0;

                    if (bit_index < 8) begin
                        uart_tx   <= data_reg[bit_index]; // LSB first
                        bit_index <= bit_index + 1'b1;
                    end else begin
                        uart_tx <= 1'b1; // stop bit
                        busy    <= 1'b0;
                    end

                end else begin
                    clk_count <= clk_count + 1'b1;
                end
            end
        end
    end

endmodule