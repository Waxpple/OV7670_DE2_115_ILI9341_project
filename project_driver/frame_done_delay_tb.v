module frame_done_delay_tb();

//input
reg frame_done;
reg irst_n;
reg clk;
//output
wire frame_enable;


initial begin
#0  clk =1;
    irst_n =0;
    frame_done =0;
#10 irst_n = 1;
#100 frame_done =1;
#10 frame_done =0;
#500;


end

always #5 clk = ~clk;

frame_done_delay u1(
.frame_done (frame_done),
.irst_n (irst_n),
.clk    (clk),
.frame_enable   (frame_enable)
);
// assign frame_enable = (frame_done)? 1 :frame_enable;

endmodule