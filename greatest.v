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
   output [9:0]  VGA_R,       // VGA Red[9:0]
   output [9:0]  VGA_G,       // VGA Green[9:0]
   output [9:0]  VGA_B,       // VGA Blue[9:0]

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
assign LED[4] = 1'b0;
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
//TFT display

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
	.done  ( 			        )
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

//Sdram_Control_4Port Sdram_Control_4Port_0(
//		//	HOST Side
//      .REF_CLK		(clk50),
//      .RESET_N		(rst_n),
//		.CLK			(),
//		//	FIFO Write Side 1
//      .WR1_DATA		(),
//		.WR1				(),
//		.WR1_ADDR		(),
//		.WR1_MAX_ADDR	(),
//		.WR1_LENGTH		(),
//		.WR1_LOAD		(),
//		.WR1_CLK			(pixel_valid),
//		.WR1_FULL		(),
//		.WR1_USE			(),
//		//	FIFO Write Side 2
//      .WR2_DATA		(),
//		.WR2				(),
//		.WR2_ADDR		(),
//		.WR2_MAX_ADDR	(),
//		.WR2_LENGTH		(),
//		.WR2_LOAD		(),
//		.WR2_CLK			(),
//		.WR2_FULL		(),
//		.WR2_USE			(),
//		//	FIFO Read Side 1
//      .RD1_DATA		(),
//		.RD1				(),
//		.RD1_ADDR		(),
//		.RD1_MAX_ADDR	(),
//		.RD1_LENGTH		(),
//		.RD1_LOAD		(),	
//		.RD1_CLK			(),
//		.RD1_EMPTY		(),
//		.RD1_USE			(),
//		//	FIFO Read Side 2
//      .RD2_DATA		(),
//		.RD2				(),
//		.RD2_ADDR		(),
//		.RD2_MAX_ADDR	(),
//		.RD2_LENGTH		(),
//		.RD2_LOAD		(),
//		.RD2_CLK			(),
//		.RD2_EMPTY		(),
//		.RD2_USE			(),
//		//	SDRAM Side
//      .SA				(sd_addr),
//      .BA				(ba),
//      .CS_N				(cs_n),
//      .CKE				(Cke),
//      .RAS_N			(ras_n),
//      .CAS_N			(cas_n),
//      .WE_N				(we_n),
//      .DQ				(sd_data),
//      .DQM				({dqm[1],dqm[0]}),
//		.SDR_CLK			(sdram_clk),
//		.CLK_18			()
//        );
wire [5:0] pixel_read;
camera_data RAM (
	.data	(pixel_data[10:5]),
	.inclock	(pixel_valid),
	.outclock	(clk25),
	.rdaddress	(mVGA_ADDR),
	.wraddress	(wraddr),
	.wren	(frame_enable),
	.q	(pixel_read)
	
	);
wire [9:0]	mVGA_R;				//memory output to VGA
wire [9:0]	mVGA_G;
wire [9:0]	mVGA_B;
wire [18:0]	mVGA_ADDR;
//wire [16:0] mVGA_ADDR_2;			//video memory address
wire [9:0]  Coord_X, Coord_Y;
//assign mVGA_ADDR_2 = Coord_Y[8:1]*320 + Coord_X[9:1]+1;
//assign mVGA_R = {{5{1'b0}},pixel_read[15:11]};
assign mVGA_R = {{10{1'b0}}};

assign mVGA_G = {{4{1'b0}},pixel_read};
//assign mVGA_B = {{5{1'b0}},pixel_read[4:0]};
assign mVGA_B = {{10{1'b0}}};
assign VGA_CLK = clk25;
VGA_Controller		u1	(	//	Host Side
							.iCursor_RGB_EN(4'b0111),
							.oAddress(mVGA_ADDR),
							.oCoord_X(Coord_X),
							.oCoord_Y(Coord_Y),
							.iRed(mVGA_R),
							.iGreen(mVGA_G),
							.iBlue(mVGA_B),
//							.iRed(pixel_read[15:11]),
//							.iGreen(pixel_read[10:5]),
//							.iBlue(pixel_read[4:0]),
							//	VGA Side
							.oVGA_R(VGA_R),
							.oVGA_G(VGA_G),
							.oVGA_B(VGA_B),
							.oVGA_H_SYNC(VGA_HS),
							.oVGA_V_SYNC(VGA_VS),
							.oVGA_SYNC(VGA_SYNC),
							.oVGA_BLANK(VGA_BLANK),
							//	Control Signal
							.iCLK(clk25),
							.iRST_N(rst_n)	);

endmodule