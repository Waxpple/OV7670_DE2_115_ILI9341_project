`timescale 1ns / 1ns
module camera_config_rom_tb();

//input
reg clk;
reg [7:0] addr;
//output
wire [15:0] dout;

integer i;
initial begin
    #0  clk<=0;
        addr<=0;
    for(i=0;i<256;i = i+1)begin
        addr <= i;
        #40;
    end

end

always #20 clk <= ~clk;

OV7670_config_rom rom1(
    .clk    (clk),
    .addr   (addr),
    .dout   (dout)
    );

endmodule
