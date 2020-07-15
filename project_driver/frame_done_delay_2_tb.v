
module frame_done_delay_2_tb();

//input
reg frame_done;
reg irst_n;
//output
wire frame_enable;


initial begin
#0  irst_n = 0;
    frame_done =1;
#1  irst_n =1 ; 
#100 frame_done =0;
#10 frame_done =1;
#50  
    frame_done =1;

#100 frame_done =0;
#10 frame_done =1;
#50  
    frame_done =1;

#100 frame_done =0;
#10 frame_done =1;
#50  
    frame_done =1;

#100 frame_done =0;
#10 frame_done =1;
#50  
    frame_done =1;

#100 frame_done =0;
#10 frame_done =1;
#50  
    frame_done =1;

#100 frame_done =0;
#10 frame_done =1;
#50  
    frame_done =1;

#100 frame_done =0;
#10 frame_done =1;
#500;


end


frame_done_delay_2 u1(
.frame_done (frame_done),
.irst_n (irst_n),
.frame_enable   (frame_enable)
);
// assign frame_enable = (frame_done)? 1 :frame_enable;

endmodule