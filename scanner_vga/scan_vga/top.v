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
module top(
			//////////// CLOCK //////////
	CLOCK_12,

	//////////// VGA //////////
	VGA_R,
	VGA_G,
	VGA_B,
	VGA_VS,
	VGA_HS,
	VGA_BLANK_N,
	VGA_SYNC_N,
	VGA_CLK,
	
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
	
	
	SCK,
	MISO,
	MOSI,
	CS,
	CS_FLASH,
	
	//LED
	SYNC_INPUT1,
	SYNC_INPUT2,
	SYNC_OUTPUT1,
	SYNC_OUTPUT2
);

//=======================================================
//  PARAMETER declarations
//=======================================================
`include  "Sdram_Params.h"

//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input 	CLOCK_12;

//////////// VGA //////////
output		     [7:0]		VGA_R;
output		     [7:0]		VGA_G;
output		     [7:0]		VGA_B;
output		          		VGA_VS;
output		          		VGA_HS;
output		          		VGA_BLANK_N;
output		          		VGA_SYNC_N;				//PSAVE_N
output		          		VGA_CLK;
/////////// SDRAM /////////
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

/////////// SD CARD ////////
output SCK;
input MISO;
output MOSI;
output CS;
output CS_FLASH;

output     SYNC_INPUT1;
output reg SYNC_INPUT2;
input 	  SYNC_OUTPUT1;
input		  SYNC_OUTPUT2;
////////// LEDs ///////////
//output [7:0] LED;
//=======================================================
//  REG/WIRE declarations
//=======================================================
reg [7:0] red, green, blue;
reg clock_25m;
reg [31:0] cntr;
reg [`ASIZE-1:0] maxADDR, minADDR;
reg [2:0] rLED;

wire CLOCK_50;
wire clock_45M, clock_25;
wire clk_100ld, clk_sdram;
wire CLOCK_VGA;
wire reset;

wire goo, vSYNC;
wire [15:0] vdata;
wire [15:0] SDATA;
wire [7:0] iRED, iGREEN, iBLUE;

wire NR;
wire RW_SYNC;
wire wr_clk;

wire [1:0] pMode;
wire [7:0] fNo;
wire START;
/****************************/
reg switch, sgnl;
reg [1:0] delay_st;
wire [7:0] wRED, wGREEN, wBLUE;
//=======================================================
//  Structural coding
//=======================================================
initial
begin
		cntr <= 0;
		clock_25m <= 0;
		
		delay_st <= 2'b11;
		SYNC_INPUT2 <= 0;
end 

pll PLL0(
			.CLK_IN1		(CLOCK_12),
			
			.CLK_OUT1	(CLOCK_50)
		  );			
dcm DCM0(
			.CLK_IN1		(CLOCK_50),
			
			.CLK_OUT1	(clk_sdram),				//DRAM itself clk_100
			.CLK_OUT2	(clk_100ld),				//DRAM controller, -150degree leading
			.CLK_OUT3	(clock_45M)					//microSD
		  );
		  
ODDR2 SDR(
			.Q				(DRAM_CLK),
			.C0			(clk_sdram),
			.C1			(~clk_sdram),
			.CE			(1'b1),
			.D0			(1'b1),
			.D1			(1'b0),
			.R				(1'b0),
			.S				(1'b0)
		);
	 
always@(posedge CLOCK_50)
	clock_25m = ~clock_25m;

assign clock_25 = clock_25m;
assign CLOCK_VGA = ~clock_25m;
assign VGA_CLK = clock_25m;

assign	VGA_BLANK_N = 1'b1;
//assign	VGA_SYNC_N = 1'b1;


/*VGA_Controller VCTR(	//	Host Side
						.iRed					(iRED),
						.iGreen				(iGREEN),
						.iBlue				(iBLUE),
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
						.iCLK					(clk_25m),
						.iRST_N				(1'b1),
						.iZOOM_MODE_SW		()
							);*/
							
vga_pcb	OWNVGA(
						.iVGA_R				(wRED),
						.iVGA_G				(wGREEN),
						.iVGA_B				(wBLUE),
						
						//	VGA Side
						.oVGA_R				(VGA_R),
						.oVGA_G				(VGA_G),
						.oVGA_B				(VGA_B),
						.oVGA_H_SYNC		(VGA_HS),
						.oVGA_V_SYNC		(VGA_VS),
						.oPSAVE_N			(VGA_SYNC_N),
						.oVGA_CLK			(),
						
						.oRequest			(goo),
						//	Control Signal
						.iCLK25				(clock_25)
							);
assign vSYNC = VGA_VS;
/*hdmi_top  HDMI_PORT2(
					.clock_pixel			(clock_25M),
					.clock_TMDS				(clock_250M),
					.iRed						(iRED),
					.iGreen					(iGREEN),
					.iBlue					(iBLUE),
					
					.oRequest				(goo),
					.SYNC_V					(vSYNC),
					.TMDSp					(TMDS_POSITIVE),
					.TMDSn					(TMDS_NEGTIVE),
					.TMDSp_clock			(TMDS_CLOCK_P),
					.TMDSn_clock			(TMDS_CLOCK_N),
					.LED						()
    );*/
/*always@(posedge clock_50M)
		cntr <= cntr + 1;
assign LED[7:6] = {cntr[26], ~cntr[26]};
assign LED[2:0] = rLED;*/
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
	 .WR_MAX_ADDR			(maxADDR),						//307200*6
	 .WR_LENGTH				(8'd32),							//8'd32
	 .WR_CLK					(wr_clk),
	 .WR_DATA				(SDATA),
	 .wr						(NR),
	 .RW_SYNC				(RW_SYNC),

	 .RD					(vSYNC),								//from vga, timing control FRAME_SYNC
	 .RDR					(goo),								//ROW_SYNC
		//	FIFO Read Side 1
	 .RD1_ADDR			(minADDR),							//BASE ADDRESS
	 .RD1_MAX_ADDR		(minADDR + 307200),				//307200*6
	 .RD1_LENGTH		(8'd64),
	 .RD1_CLK			(~CLOCK_VGA),
		//	FIFO Read Side 2
	 .RD2_ADDR			(minADDR),
	 .RD2_MAX_ADDR		(minADDR + 307200),						//307200*6
	 .RD2_LENGTH		(8'd64),
	 .RD2_CLK			(~CLOCK_VGA),
	 
	 .DATA_TO_VGA		(vdata),
	 .PIXEL_MODE		(pMode),
	 .FRAME_No			(fNo),
	 
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

spi_host  IS0(
					.cryst				(clock_45M),
					.sck					(SCK),
					.miso					(MISO),
					.mosi					(MOSI),
					.cs					(CS),
					.cs_flash			(CS_FLASH),		//ONLY available for XULA-2
					.rLED					(/*LED[3]*/),
					.gLED					(/*LED[4])*/),
					.yLED					(/*LED[5]*/),
					.data					(SDATA),
					.wr_avl				(NR),
					.rw_sync				(RW_SYNC),
					.wr_clk				(wr_clk),
					.pixel_mode			(pMode),						//01: 1-bit; 10: 8-bit; 11: 16-bit
					.frame_no			(fNo),
					.start				(START)							//0: Not Ready; 1: Ready
    );
	 
always@(posedge clk_100ld)
begin
		case (pMode)
				2'b00: maxADDR <= 307200; 
				2'b01: begin maxADDR <= 38400 * fNo;	rLED <= 3'b100; end 				//307200/8 = 38400
				2'b10: begin maxADDR <= 307200 * fNo;	rLED <= 3'b010; end
				2'b11: begin maxADDR <= 307200 * fNo;	rLED <= 3'b001; end
			  default: begin maxADDR <= 307200;  rLED <= 3'b000; end
		endcase
end
assign iRED = (pMode==2'b11) ? {vdata[7:3], vdata[7:5]} : vdata[7:0];								//{vdata[15:11], vdata[15:13]}
assign iGREEN = (pMode==2'b11) ? {vdata[2:0], vdata[15:13], vdata[2:1]} : vdata[7:0];			//{vdata[10:5], vdata[10:9]}
assign iBLUE = (pMode==2'b11) ? {vdata[12:8], vdata[12:10]} : vdata[7:0];								//{vdata[4:0], vdata[4:2]}

/*****************************************************

					Camera Control Logic
					
*****************************************************/
always@(posedge vSYNC)
begin
	if(SYNC_OUTPUT1 == 1'b1)
		sgnl = 1'b1;
	else
		sgnl = 1'b0;
end	
assign wRED = 	 (sgnl == 1'b0) ? 8'b00000000 : iRED;
assign wGREEN = (sgnl == 1'b0) ? 8'b00000000 : iGREEN;
assign wBLUE =  (sgnl == 1'b0) ? 8'b00000000 : iBLUE;

always@(negedge vSYNC or negedge SYNC_OUTPUT1)
begin
		if(SYNC_OUTPUT1 == 0)
			minADDR = 0;
		else if(SYNC_OUTPUT2 == 1)
		begin
				if(minADDR < maxADDR - 307200)
						minADDR = minADDR + 307200;
				else
						minADDR = 0;
		end
		else
			minADDR = minADDR;
end

always@(negedge vSYNC or negedge SYNC_OUTPUT1)
begin
	if(SYNC_OUTPUT1 == 0)
		begin
			switch = 0;
			delay_st = 2'b11;
		end
	else if(SYNC_OUTPUT2 == 0)
		begin
			switch = 0;
			delay_st = delay_st;
		end
	else
	begin
			if(delay_st == 2'b11)
			begin
				delay_st = 2'b10;
				switch = 0;
			end
			else if(delay_st == 2'b10)
			begin
				delay_st = 2'b01;
				switch = 0;
			end
			else if(delay_st == 2'b01)
			begin
				delay_st = 2'b00;
				switch = 1;
			end
			else
			begin 
				delay_st = 2'b00;
				switch = 1;  
			end
	end
end
	/** Above is the Camera output end **/
	/** Below is the Camera input  end **/
assign SYNC_INPUT1 = (switch == 1'b1) ? vSYNC : 0;

always@(minADDR)
begin
	if(minADDR == 0)
	begin
		if(SYNC_OUTPUT1 == 1)
			SYNC_INPUT2 = 1;
		else
			SYNC_INPUT2 = 0;
	end
	else
		SYNC_INPUT2 = 1;
end
endmodule


/*************************************************************************
##Revision Log
##Dec. 17th: changed the initial value of "frame_no" from 0 to 2
##
##
##
##
##
**************************************************************************/
