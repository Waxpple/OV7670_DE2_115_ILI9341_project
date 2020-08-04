module tft_top(
    input tft_sdo, 
	output wire tft_sck, 
	output wire tft_sdi, 
	output wire tft_dc, 
	output wire tft_reset, 
	output wire tft_cs,
	input			rst_n,
	input [15:0] tft_pixel_read,
    //clk100
	input tft_clk,
	output fbClk,
    //tft_Read
    output reg start,
	output [4:0] r,
	output [5:0] g,
	output [4:0] b,
    input [3:0] RESULT,
    output tft_Read
);

	assign r=   {tft_pixel_read[15],tft_pixel_read[14],tft_pixel_read[13],tft_pixel_read[12],
                tft_pixel_read[11]};
	assign g=   {tft_pixel_read[10],tft_pixel_read[9],tft_pixel_read[8],tft_pixel_read[7],
                tft_pixel_read[6],tft_pixel_read[5]};
	assign b=   {tft_pixel_read[4],tft_pixel_read[3],tft_pixel_read[2],tft_pixel_read[1],
                tft_pixel_read[0]};


    tft_ili9341 #(.INPUT_CLK_MHZ(100)) tft(tft_clk, tft_sdo, tft_sck, tft_sdi, tft_dc, tft_reset, tft_cs, {g[2],g[1],g[0],r[4],r[3],r[2],r[1],r[0],b[4],b[3],b[2],b[1],b[0],g[5],g[4],g[3]}, fbClk,tft_Read);


endmodule