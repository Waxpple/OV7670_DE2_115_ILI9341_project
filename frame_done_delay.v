module frame_done_delay(
input frame_done,
input irst_n,
output frame_enable
);

reg [1:0] counter =0;
reg frame_enable_r;
assign frame_enable = frame_enable_r;


always @(negedge frame_done or negedge irst_n)begin



    if(!irst_n)begin
        frame_enable_r <=0;
		  counter <=0;
    end
	else if(!frame_done)begin
		if(counter<2'd3)counter <= counter +1;
        else if(counter ==2'd3) frame_enable_r <=1;
	end



end



endmodule