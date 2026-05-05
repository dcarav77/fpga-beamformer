module blinky (
	input clk,
	input reset,
	output reg JA1,
    //output reg [26:0] q // i don't want this as an output becauase it would need 27 pins
    
);
  
  reg [26:0] q; // make this internal
  
  localparam ONE_SECOND = 27'd99_999_999;  // 100 MHz clock
  
   always @ (posedge clk) begin
     if (reset) begin
       q <= 27'd0;
       JA1 <= 1'b0;
     end
     
     else if (q == ONE_SECOND) begin		//count to 99 million
       q <= 27'd0;        //wrap
       JA1 <= ~JA1;
     end
     
     else begin
        q <= q + 1'b1;
     end
   end
  
   
 endmodule 