`timescale 1 ns / 1 ns
module camera_configure_tb();
//input
reg clk;
reg start;
//output
wire sioc;
wire siod;
wire done;


initial begin
    #0  clk<=1;
        start <=0;
    #240    start <=1;
    #40     start <=1;
    #52000    start <=0;
    #40     start <=1;
    #5000000;
end





always #20 clk<= ~clk;

camera_configure
    #(
    .CLK_FREQ   (25000000)
    )
    camera_config_0
    (
    .clk    (clk),
    .start  (start),
    .sioc   (sioc), 
    .siod   (siod),
    .done   (done)
    );


endmodule
