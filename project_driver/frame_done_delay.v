module frame_done_delay(
input frame_done,
input irst_n,
input clk,
output reg frame_enable
);


always @(posedge clk or negedge irst_n)begin
	if(!irst_n)begin
		frame_enable <=0;
	end
	else begin
		if(frame_done)frame_enable<=1;
	end



end



endmodule
