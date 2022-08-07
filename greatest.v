module greatest(
	//clocks & reset
	input wire clk50,             
	input wire rst,
	input wire start_gray_kn,
	//OV7670
	input wire [7:0] data_cam,
	input wire VSYNC_cam,
	input wire HREF_cam,
	input wire PCLK_cam,
	output wire XCLK_cam,
	output wire res_cam,
	output wire on_off_cam,
	output wire sioc,
	output wire siod,
	//VGA
	output wire [4:0] r,  
	output wire [5:0] g,
	output wire [4:0] b, 	
	    // VGA
   output        VGA_CLK,     // VGA Clock
   output        VGA_HS,      // VGA H_SYNC
   output        VGA_VS,      // VGA V_SYNC
   output        VGA_BLANK,   // VGA BLANK
   output        VGA_SYNC,    // VGA SYNC
   output [7:0]  VGA_R,       // VGA Red[7:0]
   output [7:0]  VGA_G,       // VGA Green[7:0]
   output [7:0]  VGA_B,       // VGA Blue[7:0]

	//SDRAM
	output wire cs_n,
	output wire ras_n,
	output wire cas_n,
	output wire we_n,
	output wire [3:0] dqm,
	output wire [12:0] sd_addr,
	output wire [1:0] ba,
	output wire Cke,
	inout wire [31:0] sd_data, 
	output wire sdram_clk, 
	
	//TFT
	input tft_sdo,
	output wire tft_sck, 
	output wire tft_sdi, 
	output wire tft_dc, 
	output wire tft_reset, 
	output wire tft_cs,
	//LED
	output wire [7:0] LED,
	output wire frame_done_0
);
wire fbClk;
wire [15:0]tft_pixel_read;
wire tft_Read;
wire rst_n;
wire clk25;
wire clk100;
wire clk24;
wire clk143;
wire clk500;
wire [15:0] input_fifo_to_sdram;
assign frame_done_0 = frame_done;
assign rst_n = rst;
wire locked;
wire [11:0] output_rdusedw_TFT;
wire start_image;
wire [3:0] RESULT;
reg GO_NEIROSET;
wire end_neiroset;
reg [3:0] RESULT_2;

wire ctrl_busy;
wire [23:0] wr_addr;
wire wr_enable;
wire [15:0] rd_data;
reg [23:0] rd_addr;
wire rd_ready;
reg ready;
assign XCLK_cam = clk24;


// reset camera with overall reset from button
assign res_cam    = rst_n;
assign on_off_cam = !rst_n;

//LED
assign LED[0] = wr_enable;
assign LED[1] = !wr_enable;
assign LED[2] = 1'b0;
assign LED[3] = 1'b0;
assign LED[4] = done_SCCB;
assign LED[5] = wraddr[0];
assign LED[6] = frame_enable;
assign LED[7] = clk100;

//assign LED[7] = 1'b0;

pll_for_camera pll_for_camera_0
(
	.areset   ( !rst_n ),
	.inclk0   ( clk50 ),
	.c0       ( clk100 ),
	.c2       ( clk25 ),
	.c3       ( clk24 ),
	.locked   ( locked )
);

//TFT display
//
tft_top TFT(
	.tft_sdo            ( tft_sdo ), 
	.tft_sck            ( tft_sck ), 
	.tft_sdi            ( tft_sdi ), 
	.tft_dc             ( tft_dc ), 
	.tft_reset          ( tft_reset ), 
	.tft_cs             ( tft_cs ),
	.rst_n              ( rst_n ),

	.tft_pixel_read     ( tft_pixel_read ),
	.tft_clk            ( clk100 ),
	.fbClk              ( fbClk ),
	.r                  ( r ),
	.g                  ( g ),
	.b                  ( b ),
   .tft_Read			  ( tft_Read)
);


//hellosoc_top TFT(
//	.tft_sdo            ( tft_sdo ), 
//	.tft_sck            ( tft_sck ), 
//	.tft_sdi            ( tft_sdi ), 
//	.tft_dc             ( tft_dc ), 
//	.tft_reset          ( tft_reset ), 
//	.tft_cs             ( tft_cs ),
//	.rst_n              ( rst_n ),
//	.clk_sdram          ( !rd_ready ),
//	.wr_fifo            ( (!wr_enable) && ready ),
//	.sdram_data         ( rd_data ),
//	.tft_clk            ( clk100 ),
//	.output_rdusedw     ( output_rdusedw_TFT ),
//	.fbClk              ( fbClk ),
//	.r                  ( r ),
//	.g                  ( g ),
//	.b                  ( b ),
//	.start_28           ( start_image ),
//	.RESULT             ( RESULT_2 )
//);

//pll_for_sdram_controller pll_for_sdram_controller_0(
//	.areset   ( !rst_n ),
//	.inclk0   ( clk50 ),
//	.c0       ( clk143 )
//);
//sampling_freq sampling_freq_0(
//	.areset   ( !rst_n ),
//	.inclk0   ( clk50 ),
//	.c0       ( clk500 )
//);

// start camera inititalization
reg [2:0] strt;

always @(posedge clk25 or negedge rst_n)
	if (!rst_n)
		strt <= 3'h0;
	else
	begin
		if (locked)
			begin
				if ( &strt )
					strt	<= strt;
				else
					strt	<= strt + 1'h1;
			end
	end
	
wire done_SCCB;
// camera inititalization
camera_configure 
#(	
	.CLK_FREQ 	( 25000000 )
)
camera_configure_0
(
	.clk   ( clk25            ),	
	.start ( ( strt == 3'h6 ) ),
	.sioc  ( sioc             ),
	.siod  ( siod             ),
	.done  ( done_SCCB        )
);
wire 	[15:0] pixel_data;
wire 	pixel_valid;
wire	frame_done;
wire [18:0] wraddr;
camera_read camera_read_0
(
	.p_clock	(PCLK_cam),
	.vsync	(VSYNC_cam),
	.href	(HREF_cam),
	.p_data	(data_cam),
	.pixel_data	(pixel_data),
	.pixel_valid	(pixel_valid),
	.frame_done	(frame_done),
	.wraddr	(wraddr)
);
wire frame_enable;

frame_done_delay frame_done_delay(
.frame_done (frame_done),
.irst_n	(rst_n),
.frame_enable   (frame_enable)
);


wire [15:0] pixel_read;

//
//camera_data RAM (
//	.data	(pixel_data[10:5]),
//	.inclock	(pixel_valid),
//	.outclock	(clk25),
//	.rdaddress	(mVGA_ADDR[18:0]),
//	.wraddress	({wraddr-19'd1}),
//	.wren	(frame_enable),
//	.rden	(VGA_Read),
//	.q	(pixel_read)
//	
//	);

wire [4:0] CMOS_R;
wire [5:0] CMOS_G;
wire [4:0] CMOS_B;
assign CMOS_R = pixel_read[15:11];
assign CMOS_G = pixel_read[10:5];
assign CMOS_B = pixel_read[4:0];
wire [9:0]	mVGA_R;				//memory output to VGA 8bit only
wire [9:0]	mVGA_G;
wire [9:0]	mVGA_B;
wire [21:0]	mVGA_ADDR;

assign mVGA_R = {CMOS_R,{5{1'b0}}};
assign mVGA_G = {CMOS_G,{4{1'b0}}};
assign mVGA_B = {CMOS_B,{5{1'b0}}};

wire [9:0] vga_r10;
wire [9:0] vga_g10;
wire [9:0] vga_b10;
assign VGA_R = vga_r10[9:2];
assign VGA_G = vga_g10[9:2];
assign VGA_B = vga_b10[9:2];
wire VGA_Read;
VGA_Ctrl			u9	(	//	Host Side
							.iRed(mVGA_R),
							.iGreen(mVGA_G),
							.iBlue(mVGA_B),
							.oCurrent_X(),
							.oCurrent_Y(),
							.oAddress	(mVGA_ADDR),
							.oRequest(VGA_Read),
							//	VGA Side
							.oVGA_R(vga_r10 ),
							.oVGA_G(vga_g10 ),
							.oVGA_B(vga_b10 ),
							.oVGA_HS(VGA_HS),
							.oVGA_VS(VGA_VS),
							.oVGA_SYNC(VGA_SYNC),
							.oVGA_BLANK(VGA_BLANK),
							.oVGA_CLOCK(VGA_CLK),
							//	Control Signal
							.iCLK(clk25),
							.iRST_N(rst_n)	);

Sdram_Control_4Port Sdram_Control_4Port_0(
		//	HOST Side
      .REF_CLK		(clk50),
      .RESET_N		(rst_n),
		.CLK			(),
		//	FIFO Write Side 1
      .WR1_DATA		(pixel_data),
		.WR1				(frame_enable),
		.WR1_ADDR		(0),
		//VGA 640x320, tft 320x240
		.WR1_MAX_ADDR	(320*240-1),
		.WR1_LENGTH		(9'h80),
		.WR1_LOAD		(!rst_n),
		.WR1_CLK			(pixel_valid),
		.WR1_FULL		(),
		.WR1_USE			(),
		//	FIFO Write Side 2
      .WR2_DATA		(),
		.WR2				(),
		.WR2_ADDR		(),
		.WR2_MAX_ADDR	(),
		.WR2_LENGTH		(),
		.WR2_LOAD		(),
		.WR2_CLK			(),
		.WR2_FULL		(),
		.WR2_USE			(),
		//	FIFO Read Side 1
      .RD1_DATA		(pixel_read),
		.RD1				(VGA_Read),
		.RD1_ADDR		(0),
		.RD1_MAX_ADDR	(640*480-1),
		.RD1_LENGTH		(9'h80),
		.RD1_LOAD		(!rst_n),	
		.RD1_CLK			(clk25),
		.RD1_EMPTY		(),
		.RD1_USE			(),
		//	FIFO Read Side 2
      .RD2_DATA		(tft_pixel_read),
		.RD2				(tft_Read),
		.RD2_ADDR		(0),
		.RD2_MAX_ADDR	(320*240-1),
		.RD2_LENGTH		(9'h80),
		.RD2_LOAD		(!rst_n),
		.RD2_CLK			(fbClk),
		.RD2_EMPTY		(),
		.RD2_USE			(),
		//	SDRAM Side
      .SA				(sd_addr),
      .BA				(ba),
      .CS_N				(cs_n),
      .CKE				(Cke),
      .RAS_N			(ras_n),
      .CAS_N			(cas_n),
      .WE_N				(we_n),
      .DQ				(sd_data),
      .DQM				({dqm[1],dqm[0]}),
		.SDR_CLK			(sdram_clk),
		.CLK_18			()
        );
endmodule