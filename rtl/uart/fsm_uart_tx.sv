// IDLE
// tx_start ? START : IDLE

// START
// clk_count == CLKS_PER_BIT - 1 ? DATA : START

// DATA
// clk_count == CLKS_PER_BIT - 1 ?
//     TRUE:
//         bit_index == 7 ?
//             TRUE: STOP
//             FALSE: DATA
//     FALSE:
//         DATA

// STOP
// clk_count == CLKS_PER_BIT - 1 ? IDLE : STOP

module fsm_uart_tx #(
    
    // 115,200 bits/sec UART. 1/115,200 = 8.68    
    // 8.68 µs / 10 ns≈ 868 clock cycles
    parameter CLKS_PER_BIT = 868
)(
    //Port Declarations
    input wire clk,
    input wire rst,
    input wire [7:0] byte_to_send, //Entire byte enters the UART at once
    input wire tx_start,

    output reg uart_tx, //Serial protocol
    output reg busy
);

    localparam IDLE =  2'b00;
    localparam START = 2'b01;
    localparam DATA =  2'b10;
    localparam STOP =  2'b11;
    
    //Register Declarations
    reg [1:0]  state;
    reg [31:0] clk_count;
    reg [3:0]  bit_index;
    reg [7:0]  data_reg;


    always @ (posedge clk) begin
        if (rst) begin
            state        <= IDLE;
            clk_count    <= 32'd0;
            bit_index    <= 4'd0;
            data_reg     <= 8'd0;
            //Port Declarations
            uart_tx      <= 1'b1; //physical wire
            busy         <= 1'b0;     
        end 
        
        else begin
            case (state)
                
                IDLE: begin
                    //Register Assignment
                    clk_count   <= 32'd0;
                    bit_index   <= 4'd0;
                    uart_tx     <= 1'b1;
                    busy        <= 1'b0; //available

                if (tx_start) begin
                    data_reg <= byte_to_send;
                    busy     <= 1'b1;
                    state    <= START;
                end else begin
                    state    <= IDLE;
                end
            end

                START: begin
                    //state       <=        // stay START until one bit period is over ;
                    //clk_count   <=        // count up;
                    bit_index   <= 4'd0;    // stay 0, we haven't started sending data yet ;
                    //data_reg    <=        // don't change/need (keep the copied byte) ;
                    //Port Declarations
                    uart_tx     <= 1'b0;    // 0 (start bit) ;
                    busy        <= 1'b1;

                    //Condition:
                    if (clk_count == CLKS_PER_BIT - 1) begin
                    //True:
                        clk_count   <= 32'd0;
                        state       <= DATA;
                    //False:
                    end else begin
                        clk_count  <= clk_count + 1'b1; 
                        state      <= START;
                    end
                end

                DATA: begin
                   //Port Declartions
                    uart_tx     <=  data_reg[bit_index]; //<- One bit at a time
                    busy        <= 1'b1;    //true busy

                    //Condition 1:
                    //Has the current DATA bit been held long enough?
                    if (clk_count == CLKS_PER_BIT - 1) begin

                        //TRUE:
                        //Current bit is finished
                        clk_count <= 32'd0;

                        //Condition 2:
                        //Was this the last data bit?
                        if (bit_index == 4'd7) begin

                        //TRUE:
                        //Finished bit 7, go to STOP
                        bit_index <= 4'd0;
                        state     <= STOP;

                        end else begin

                        //FALSE
                        //not the last bit, move to the next bit
                        bit_index <= bit_index + 1'b1;
                        state     <= DATA;
                        end
                    
                    end else begin

                        //FALSE:
                        //current bit is not finished yet
                        clk_count <= clk_count + 1'b1;
                        state     <= DATA;
                    end
                end

                STOP: begin
                    //state     <= //stay STOP until one bit period ;
                    //clk_count <= //count one UART bit period;
                    //bit_index <= //stay 0 ;
                    //data_reg  <= //hold the saved byte ;
                    //Port Declarations
                    uart_tx   <= 1'b1;  
                    busy      <= 1'b1; 

                    //Condition 1:
                    //Has the current STOP bit been held long enough?
                    if (clk_count == CLKS_PER_BIT - 1) begin                    
                    //TRUE:
                    //stop bit finished, transmission complete
                    clk_count <= 32'd0;
                    bit_index <= 4'd0;
                    busy      <= 1'b0;
                    state     <= IDLE;

                    end else begin

                    //FALSE 
                    //stop bit NOT finished 
                    clk_count <= clk_count + 1'b1;
                    state     <= STOP;
                    end
                end
            endcase
        end
    end
endmodule


                        








        



                    






                    







