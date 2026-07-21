// count means the number of items currently store in the fifo

module fifo_echo_bridge (
    input wire  clk,
    input wire  rst,

//    input wire  write_enable,
//    input wire  read_enable,
//    input wire [31:0] data_in,
//    output reg [31:0] data_out,

    //From Echo Timer (write)
    input wire [31:0] echo_count_in,    //what to write
    input wire  measurement_ready_in,   //WHEN to write

    //To Bridge
    output reg [31:0] echo_count_out,

    //From Bridge
    input wire fifo_read_enable, //this is new

    output wire full,
    output wire empty
);

    reg [31:0] mem [0:15];
    reg [3:0]  write_pointer;
    reg [3:0]  read_pointer;
    reg [4:0]  count;
    

    assign full = (count == 5'd16);
    assign empty = (count == 5'd0);

    always @(posedge clk) begin
        if (rst) begin
            write_pointer  <= 4'd0;
            read_pointer   <= 4'd0;
            count          <= 5'd0;
            echo_count_out <= 32'd0;  
        end else begin
            // WRITE: Only if there's space
            if (measurement_ready_in && !full) begin
                mem[write_pointer] <= echo_count_in;
                write_pointer      <= write_pointer + 1'b1;  // ← Wraps automatically!
            end

            // READ: Only if there's data
            if (fifo_read_enable && !empty) begin
                echo_count_out     <= mem[read_pointer];
                read_pointer       <= read_pointer + 1'b1;         // ← Wraps automatically!
            end

            // UPDATE COUNT: Handle all 4 cases
            if (measurement_ready_in && !full && fifo_read_enable && !empty) begin
                count <= count;              // Both = no change
            end else if (measurement_ready_in && !full) begin
                count <= count + 1'b1;       // Write only = +1
            end else if (fifo_read_enable && !empty) begin
                count <= count - 1'b1;       // Read only = -1
            end
        end
    end
endmodule