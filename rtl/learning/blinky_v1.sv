
module blinky (
	input clk,
	input reset,
    input enable,
	
    output reg JA1,
    output reg pulse     //this will need to go to a pin (constraints)
   
);
  
  reg [26:0] q; 
  
  localparam ONE_SECOND = 27'd99_999_999;  
  
always @(posedge clk) begin
    if (reset) begin  //reset must clear pulse too
       q <= 27'd0;
       JA1 <= 1'b0;
       pulse <= 1'b0; // i clear pulse but never set it to 1 first

    end
    
    else if (enable) begin
            // ONLY HERE does counting happen
            
        
        if (q == ONE_SECOND) begin
            // Terminal count: wrap, generate pulse, toggle LED
            q <= 27'd0;  
            JA1 <= ~JA1;
            pulse <= 1'b1;         

        end
        else begin
            // Normal increment
            q <= q + 1'b1;
            pulse <= 1'b0;  //clear pulse on non terminal cycles
        end
    end
        else begin
            pulse <= 1'b0;
        end
end

endmodule 