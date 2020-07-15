`timescale 1ns / 1ns
module SCCB_interface_tb();

//input
reg clk;
reg start;
reg [7:0] address;
reg [7:0] data;
//output
wire ready;
wire SIOC_oe;
wire SIOD_oe;
wire [11:0] counter;
initial begin

    clk <=0;
    start <=0;
    address <= 8'h11;
    data <= 8'h01;
    #100 start <=1;
    #5000;


end

always #20 clk=~clk;

SCCB_interface #(
    .CLK_FREQ (25000000),
    .SCCB_FREQ (100000)
) interface1

(
    .clk    (clk),
    .start  (start),
    .address    (address),
    .data   (data),
    .ready  (ready),
    .SIOC_oe    (SIOC_oe),
    .SIOD_oe    (SIOD_oe),
    .counter (counter)
    );

endmodule