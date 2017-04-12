`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:41:07 05/10/2015 
// Design Name: 
// Module Name:    vga_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga_top(
			//////////// CLOCK //////////
	CLOCK_12,

	//////////// VGA //////////
	VGA_B,
	VGA_BLANK_N,
	VGA_CLK,
	VGA_G,
	VGA_HS,
	VGA_R,
	VGA_SYNC_N,
	VGA_VS,
	
	//iso_gnd
	DRAM_CLK,
	SA,
	BA,
	CS_N,
	CKE,
	RAS_N,
	CAS_N,
	WE_N,
	UDQM,
	LDQM,
	DQ,
	
	//fpga_0_Generic_SPI_SCK_pin,					//ratio: 128 --> SCK = 390kHz
	//fpga_0_Generic_SPI_MISO_pin,
	//fpga_0_Generic_SPI_MOSI_pin, 
	//fpga_0_rst_1_sys_rst_pin,
	//SPI_CHIP_SELECT
	SCK,
	MISO,
	MOSI,
	CS,
	CS_FLASH
	
	//redl
);

//=======================================================
//  PARAMETER declarations
//=======================================================


//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input 		          		CLOCK_12;

//////////// VGA //////////
output		     [7:0]		VGA_B;
output		          		VGA_BLANK_N;
output		          		VGA_CLK;
output		     [7:0]		VGA_G;
output		          		VGA_HS;
output		     [7:0]		VGA_R;
output		          		VGA_SYNC_N;
output		          		VGA_VS;
//output led;
output DRAM_CLK;
output [12:0] SA;				//address output
output [1:0] BA;
output CS_N;
output CKE;
output RAS_N;
output CAS_N;
output WE_N;
output UDQM;
output LDQM;
inout [15:0] DQ;

//inout fpga_0_Generic_SPI_SCK_pin;					//ratio: 128 --> SCK = 390kHz
//inout fpga_0_Generic_SPI_MISO_pin;
//inout fpga_0_Generic_SPI_MOSI_pin; 
//input fpga_0_rst_1_sys_rst_pin;
//output SPI_CHIP_SELECT;
output SCK;
input MISO;
output MOSI;
output CS;
output CS_FLASH;

//output redl;
//=======================================================
//  REG/WIRE declarations
//=======================================================
reg [7:0] red, green, blue;
reg clk_25m;
reg we1, we2, re1, re2;

wire hon, von;
wire d, de, deb, debc;
wire r, rs, rsp, rspq;
wire rover;
wire [9:0] coln, rown;

wire clk_50, clk_50i;
wire clk_25, clk_45;
wire clk_100ld;
wire reset;

wire VGA_CLK;
wire [15:0] vdata;

wire go, goo;

wire [7:0] SDATA;						//wire [0:15] SDATA;
//wire [0:3] CSO;
//wire [0:1] CSI;
wire NR;
wire RW_SYNC;
wire wr_clk;
//=======================================================
//  Structural coding
//=======================================================
dcm DCM0(
  .CLK_IN1			(CLOCK_12),

  .CLK_OUT1			(clk_50i),
  .CLK_OUT2			(clk_50)
 );
 
 pll PLL0(
			.CLK_IN1		(clk_50),
			
			.CLK_OUT1	(clk_100ld),				//for DRAM itself clk_100
			.CLK_OUT2	(DRAM_CLK),					//for DRAM controller, -15degree leading
			.CLK_OUT3	(clk_45)					//for FSM
			);

	 
always@(posedge clk_50i)
	clk_25m = ~clk_25m;

assign clk_25 = clk_25m;
	
assign VGA_CLK = ~clk_25m;


assign	VGA_BLANK_N = 1'b1;
assign	VGA_SYNC_N = 1'b1;			//PSAVE_b new PCB
//assign 	reset = 1'b0;
//assign iso_gnd = 1'b0;

/*always@(posedge clk_25)				//cosd, cosd2
begin
	case ({cosd[7], cosd2[7]})
		2'b00:
					cdata = 128 + (cosd[6:0] + cosd2[6:0])/2;
		2'b01:
					cdata = 64 + (cosd[6:0] + cosd2[6:0])/2;
		2'b10:
					cdata = 64 + (cosd[6:0] + cosd2[6:0])/2;
		2'b11:
					cdata = (cosd[6:0] + cosd2[6:0])/2;
	endcase
end
*/
/*always@(negedge clk_25)						//posedge
begin
		red <= vdata[15:8];
		green <= 0;
		blue <= vdata[7:0];
end

//Starting point syncronization
always@(posedge clk_25)						//rown
begin
		if(rown < 480)
				go = 1;
		else
				go = 0;
end
always@(posedge clk_25)						//coln
begin
		if(coln<638)
				goo = 1;
		else if(coln>797)
				goo = 1;
		else
				goo = 0;
end

Hcounter HCM1(clk_25, reset, d, de, deb, debc, rover, coln);
Vcounter VCM1(rover, reset, r, rs, rsp, rspq, rown);

rsff HSYNC(clk_25, reset, de, deb, VGA_HS);					//D
rsff HDATO(clk_25, reset, d, debc, hon);						//O
rsff VSYNC(clk_25, reset, rs, rsp, VGA_VS);					//N
rsff VDATO(clk_25, reset, r, rspq, von);						//E
	
rgboen RED(VGA_R, hon, von, red);
rgboen GREEN(VGA_G, hon, von, green);
rgboen BLUE(VGA_B, hon, von, blue);*/
VGA_Controller VCTR(	//	Host Side
						.iRed					(vdata[7:0]),
						.iGreen				(vdata[7:0]),
						.iBlue				(vdata[7:0]),
						.oRequest			(goo),
						//	VGA Side
						.oVGA_R				(VGA_R),
						.oVGA_G				(VGA_G),
						.oVGA_B				(VGA_B),
						.oVGA_H_SYNC		(VGA_HS),
						.oVGA_V_SYNC		(VGA_VS),
						.oVGA_SYNC			(),
						.oVGA_BLANK			(),

						//	Control Signal
						.iCLK					(clk_25),
						.iRST_N				(1'b1),
						.iZOOM_MODE_SW		()
							);

/**************************Interface with SDR SDRAM**********************
***********A FIFO with 25Mhz clock freq.
***********FIFO depth is 1024, only 640 of them are being used
***********data width is 24-bit
*/
			  

/***************SDR SDRAM controller submodule********
*need appropriate inputs sequence
*
*/
sdram_top  SDRAMIF(
	 .RESET_N				(1'b1),
	 .CLK						(clk_100ld),

	 .WR_ADDR				(0),
	 .WR_MAX_ADDR			(307200*6),
	 .WR_LENGTH				(8'd32),							//8'd32
	 .WR_CLK					(/*CSO[2]*/wr_clk),
	 .WR_DATA				({8'h00, SDATA}),
	 .wr						(/*CSI[1]*/NR),
	 .RW_SYNC				(/*CSO[1]*/RW_SYNC),

	 .RD					(VGA_VS),				//from vga, timing control FRAME_SYNC
	 .RDR					(goo),			//ROW_SYNC
		//	FIFO Read Side 1
	 .RD1_ADDR			(0),				//BASE ADDRESS
	 .RD1_MAX_ADDR		(307200*6),
	 .RD1_LENGTH		(8'd32),
	 .RD1_CLK			(VGA_CLK),
		//	FIFO Read Side 2
	 .RD2_ADDR			(0),
	 .RD2_MAX_ADDR		(307200*6),
	 .RD2_LENGTH		(8'd32),
	 .RD2_CLK			(VGA_CLK),
	 
	 .DATA_TO_VGA		(vdata),
	 
    .SA					(SA),				//address output
    .BA					(BA),
    .CS_N				(CS_N),
    .CKE					(CKE),
    .RAS_N				(RAS_N),
    .CAS_N				(CAS_N),
    .WE_N				(WE_N),
    .DQ					(DQ),
	 .DQM					({UDQM, LDQM})
    );
	 
/*system_top MBZ0(
    .fpga_0_Generic_SPI_SCK_pin					(fpga_0_Generic_SPI_SCK_pin),
    .fpga_0_Generic_SPI_MISO_pin					(fpga_0_Generic_SPI_MISO_pin),
    .fpga_0_Generic_SPI_MOSI_pin					(fpga_0_Generic_SPI_MOSI_pin),
    .fpga_0_LEDS_GPIO_IO_O_pin					(SDATA),				//16 bits
    .fpga_0_LEDS_1_GPIO_IO_O_pin					(CSO),				//4 bits
    .fpga_0_Push_Buttons_GPIO_IO_I_pin			(CSI),				//2 bits
    .fpga_0_clk_1_sys_clk_pin						(clk_50i),
    .fpga_0_rst_1_sys_rst_pin						(fpga_0_rst_1_sys_rst_pin)
);
assign SPI_CHIP_SELECT = CSO[3];*/
spi_host  IS0(
					.cryst				(clk_45),
					.sck					(SCK),
					.miso					(MISO),
					.mosi					(MOSI),
					.cs					(CS),
					.cs_flash			(CS_FLASH),
					.rLED					(/*redl*/),
					.gLED					(),						//not used
					.yLED					(),						//not used
					.data					(SDATA),
					.wr_avl				(NR),
					.rw_sync				(RW_SYNC),
					.wr_clk				(wr_clk)
    );
endmodule
