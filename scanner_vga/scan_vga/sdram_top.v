`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:20:27 04/27/2015 
// Design Name: 
// Module Name:    sdram_top 
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
//////////////////////////IOSTANDARD: LVTTL 3.3v//////////////////////
module sdram_top (
		//	HOST Side
		RESET_N,
		CLK,
		
		WR_ADDR,
		WR_MAX_ADDR,
		WR_LENGTH,
		WR_CLK,
		WR_DATA,
		wr,
		RW_SYNC,
    
		RD,
		RDR,

		//	FIFO Read Side 1
		RD1_ADDR,
		RD1_MAX_ADDR,
		RD1_LENGTH,
		RD1_CLK,
		//	FIFO Read Side 2
		RD2_ADDR,
		RD2_MAX_ADDR,
		RD2_LENGTH,
		RD2_CLK,
		
		DATA_TO_VGA,
		PIXEL_MODE,
		FRAME_No,
		//	SDRAM Side
    SA,
    BA,
    CS_N,
    CKE,
    RAS_N,
    CAS_N,
    WE_N,
    DQ,
    DQM
);


//=======================================================
//  PARAMETER declarations
//=======================================================
`include  "Sdram_Params.h"


//=======================================================
//  PORT declarations
//=======================================================
//	HOST Side
input                           RESET_N;                //System Reset
input 							            CLK;
//	FIFO Write Side 1
/*input  [`DIOSIZE-1:0]           WR1_DATA;               //Data Input
input							         WR1;					          //Write Request
input	  [`ASIZE-1:0]			      WR1_ADDR;				        //Write Start Address
input	  [`ASIZE-1:0]			      WR1_MAX_ADDR;			      //Write Max Address
input	         [7:0]				  	WR1_LENGTH;     				//Write Length
//input							              WR1_LOAD;			         	//Write FIFO Clear
input							              WR1_CLK;				        //Write FIFO Clock
//	FIFO Write Side 2
input  [`DIOSIZE-1:0]           WR2_DATA;               //Data Input
input							         WR2;					          //Write Request
input	  [`ASIZE-1:0]			      WR2_ADDR;				        //Write Start Address
input	  [`ASIZE-1:0]			      WR2_MAX_ADDR;			      //Write Max Address
input	         [7:0]				  	WR2_LENGTH;     				//Write Length
//input							              WR2_LOAD;			         	//Write FIFO Clear
input							              WR2_CLK;				        //Write FIFO Clock*/

input		[`ASIZE-1:0]				WR_ADDR;
input		[`ASIZE-1:0]				WR_MAX_ADDR;
input		[7:0] 						WR_LENGTH;
input 									WR_CLK;
input    [15:0]						WR_DATA;
output									wr;
input										RW_SYNC;

input							         RD;					          //Read Request
input										RDR;

//	FIFO Read Side 1
input	  [`ASIZE-1:0]			      RD1_ADDR;				        //Read Start Address
input	  [`ASIZE-1:0]			      RD1_MAX_ADDR;			      //Read Max Address
input	         [7:0]					  RD1_LENGTH;				      //Read Length
//input						              	RD1_LOAD;				        //Read FIFO Clear
input							              RD1_CLK;				        //Read FIFO Clock
//	FIFO Read Side 2
input	  [`ASIZE-1:0]			      RD2_ADDR;				        //Read Start Address
input	  [`ASIZE-1:0]			      RD2_MAX_ADDR;			      //Read Max Address
input	         [7:0]					  RD2_LENGTH;				      //Read Length
//input						              	RD2_LOAD;				        //Read FIFO Clear
input							              RD2_CLK;				        //Read FIFO Clock
output	[15:0]						DATA_TO_VGA;
input		[1:0]							PIXEL_MODE;
input		[7:0]							FRAME_No;
//	SDRAM Side
output        [12:0]            SA;                     //SDRAM address output
output         [1:0]            BA;                     //SDRAM bank address
output         	              CS_N;                   //SDRAM Chip Selects
output                          CKE;                    //SDRAM clock enable
output                          RAS_N;                  //SDRAM Row address Strobe
output                          CAS_N;                  //SDRAM Column address Strobe
output                          WE_N;                   //SDRAM write enable
inout   [`DSIZE-1:0]            DQ;                     //SDRAM data bus
output [`DSIZE/8-1:0]           DQM;                    //SDRAM data mask lines



//=======================================================
//  Signal Declarations
//=======================================================
//	Controller
reg		[`ASIZE-1:0]			        mADDR;					        //Internal address
reg		       [7:0]			        mLENGTH;				        //Internal length


/*reg		[`ASIZE-1:0]			        rWR1_ADDR;			        //Register write address				
reg		[`ASIZE-1:0]			        rWR1_MAX_ADDR;	        //Register max write address				
reg		       [7:0]		 	        rWR1_LENGTH;		        //Register write length
reg		[`ASIZE-1:0]			        rWR2_ADDR;			        //Register write address				
reg		[`ASIZE-1:0]			        rWR2_MAX_ADDR;	        //Register max write address				
reg		       [7:0]			        rWR2_LENGTH;		        //Register write length*/

reg		[`ASIZE-1:0]			        rWR_ADDR;				
reg		[`ASIZE-1:0]			        rWR_MAX_ADDR;
reg		       [7:0]			        rWR_LENGTH;


reg		[`ASIZE-1:0]			        rRD1_ADDR;			        //Register read address
reg		[`ASIZE-1:0]			        rRD1_MAX_ADDR;	        //Register max read address
reg		       [7:0]			        rRD1_LENGTH;		        //Register read length
reg		[`ASIZE-1:0]			        rRD2_ADDR;			        //Register read address
reg		[`ASIZE-1:0]			        rRD2_MAX_ADDR;	        //Register max read address
reg		       [7:0]			        rRD2_LENGTH;		        //Register read length
reg		       [1:0]			        WR_MASK;				        //Write port active mask
reg		       [1:0]			        RD_MASK;				        //Read port active mask
reg								              mWR_DONE;				        //Flag write done, 1 pulse SDR_CLK
reg								              mRD_DONE;				        //Flag read done, 1 pulse SDR_CLK
reg								              mWR,Pre_WR;			        //Internal WR edge capture
reg							      	        mRD,Pre_RD;			        //Internal RD edge capture
reg 	       [9:0] 		          ST;						          //Controller status
reg		       [1:0] 			        CMD;					          //Controller command
reg								              PM_STOP;				        //Flag page mode stop
reg								              PM_DONE;				        //Flag page mode done
reg								              Read;					          //Flag read active
reg								              Write;					        //Flag write active
reg	   [`DSIZE-1:0]             mDATAOUT;               //Controller Data output 
wire   [`DSIZE-1:0]             	 mDATAIN;                //Controller Data input
//wire   [`DSIZE-1:0]             mDATAIN1;               //Controller Data input 1
//wire   [`DSIZE-1:0]             mDATAIN2;               //Controller Data input 2
wire                            CMDACK;                 //Controller command acknowledgement
//	DRAM Control                
reg  [`DSIZE/8-1:0]             DQM;                    //SDRAM data mask lines
reg          [12:0]             SA;                     //SDRAM address output
reg           [1:0]             BA;                     //SDRAM bank address
reg           		              CS_N;                   //SDRAM Chip Selects
reg                             CKE;                    //SDRAM clock enable
reg                             RAS_N;                  //SDRAM Row address Strobe
reg                             CAS_N;                  //SDRAM Column address Strobe
reg                             WE_N;                   //SDRAM write enable
wire    [`DSIZE-1:0]            DQOUT;					        //SDRAM data out link
wire  [`DSIZE/8-1:0]            IDQM;                   //SDRAM data mask lines
wire          [12:0]            ISA;                    //SDRAM address output
wire           [1:0]            IBA;                    //SDRAM bank address
wire           	              ICS_N;                  //SDRAM Chip Selects
wire                            ICKE;                   //SDRAM clock enable
wire                            IRAS_N;                 //SDRAM Row address Strobe
wire                            ICAS_N;                 //SDRAM Column address Strobe
wire                            IWE_N;                  //SDRAM write enable
//	FIFO Control                                        
reg						      		        OUT_VALID;			        //Output data request to read side fifo
reg								              IN_REQ;					        //Input	data request to write side fifo
wire           [6:0]		        write_side_fifo_rusedw;
wire           [6:0]		        write_side_fifo_wusedw;
wire           [6:0]		        read_side_fifo_wusedw1;
wire           [6:0]		        read_side_fifo_wusedw2;
//	DRAM Internal Control
wire    [`ASIZE-1:0]            saddr;
wire                            load_mode;
wire                            nop;
wire                            reada;
wire                            writea;
wire                            refresh;
wire                            precharge;
wire                            oe;
wire							              ref_ack;
wire							              ref_req;
wire							              init_req;
wire							              cm_ack;
wire							              active;

//Ying's regs and wires
reg [23:0] pixel_counter;
reg [15:0] SDCDATA;
reg rd1_en, rd2_en;
wire WR;
wire wr_clk;
wire [15:0] RD1_DATA, RD2_DATA;
wire EPT1, EPT2, EPT0;

wire RD_ONE;
wire [7:0] RD_EIGHT;
wire [18:0] PPF_CONSTANT;								//Pixels Per Frame

wire wFULL;
reg FULL;

reg [1:0] ppi;
reg rWR;
reg fifo_rst, pre_fifo_rst, rst_sync;
reg [7:0] fc;

initial
begin
		pixel_counter <= 0;
		//WR <= 0;
		rd1_en <= 0;
		rd2_en <= 0;
		
		CS_N <= 0;
		CKE <= 1;
		fc <= 0;
		ppi <= 0;
end
//=======================================================
//  Sub-module
//=======================================================
control_interface  u_control_interface (
        .CLK(CLK),
        .RESET_N(RESET_N),
        .CMD(CMD),
        .ADDR(mADDR),
        .REF_ACK(ref_ack),
        .CM_ACK(cm_ack),
        .NOP(nop),
        .READA(reada),
        .WRITEA(writea),
        .REFRESH(refresh),
        .PRECHARGE(precharge),
        .LOAD_MODE(load_mode),
        .SADDR(saddr),
        .REF_REQ(ref_req),
				.INIT_REQ(init_req),
        .CMD_ACK(CMDACK) );

command  u_command (
         .CLK(CLK),
         .RESET_N(RESET_N),
         .SADDR(saddr),
         .NOP(nop),
         .READA(reada),
         .WRITEA(writea),
         .REFRESH(refresh),
				 .LOAD_MODE(load_mode),
         .PRECHARGE(precharge),
         .REF_REQ(ref_req),
				 .INIT_REQ(init_req),
         .REF_ACK(ref_ack),
         .CM_ACK(cm_ack),
         .OE(oe),
				 .PM_STOP(PM_STOP),
				 .PM_DONE(PM_DONE),
         .SA(ISA),
         .BA(IBA),
         .CS_N(ICS_N),
         .CKE(ICKE),
         .RAS_N(IRAS_N),
         .CAS_N(ICAS_N),
         .WE_N(IWE_N) );
                
sdr_data_path  u_sdr_data_path (
         .CLK(CLK),
         .RESET_N(RESET_N),
         .DATAIN(mDATAIN),
         .DM(2'b00),
         .DQOUT(DQOUT),
         .DQM(IDQM) );


//MINE
fifo_8to1  ONE_BIT_OUT(
					.rst					(rst_sync),
				  .wr_clk				(CLK),								//100Mhz
				  .rd_clk				(RD1_CLK),							//25Mhz
				  .din					(mDATAOUT[7:0]),					//truncate to 8-bit
				  .wr_en					(OUT_VALID && RD_MASK[0] && (PIXEL_MODE==2'b01)),
				  .rd_en					(RDR && (PIXEL_MODE==2'b01)/*&& (!EPT1)*/),
				  .dout					(RD_ONE),							//1-bit wide
				  .full					(),
				  .empty					(),
				  .rd_data_count		(),
				  .wr_data_count		(read_side_fifo_wusedw2)
				);
assign RD_EIGHT = (RD_ONE == 1'b1) ? 8'b11111111 : 8'b00000000;
				
fifo_vga  RD_PING(
				  .rst					(rst_sync),
				  .wr_clk				(CLK),
				  .rd_clk				(RD1_CLK),
				  .din					(mDATAOUT),
				  .wr_en					(OUT_VALID && RD_MASK[0] && (PIXEL_MODE!=2'b01)),
				  .rd_en					(RDR && (!EPT1) && (PIXEL_MODE!=2'b01)),
				  .dout					(RD1_DATA),
				  .full					(),				//unused
				  .empty					(EPT1),				//
				  .rd_data_count		(),				//unused
				  .wr_data_count		(read_side_fifo_wusedw1)
				);


fifo_vga  WR_16x16(
				  .rst					(1'b0),
				  .wr_clk				(WR_CLK),
				  .rd_clk				(CLK),
				  .din					(WR_DATA),			//SDCDATA
				  .wr_en					(WR /*&&*/ ),
				  .rd_en					(IN_REQ && WR_MASK[0]),
				  .dout					(mDATAIN),							//output to SDRAM
				  .full					(),				//unused
				  .empty					(EPT0),
				  .rd_data_count		(write_side_fifo_rusedw),
				  .wr_data_count		(write_side_fifo_wusedw)
				 );


//=======================================================
//  Structural coding
//=======================================================
assign DQ = oe ? DQOUT : `DSIZE'hzzzz;
assign active	=	Read | Write;

//***test INPUT***LOOK AT line330
assign wr_clk = ~WR_CLK;

/*always@(posedge WR_CLK)
begin
		if(pixel_counter < 307200)
				pixel_counter <= pixel_counter + 1;
		else
				pixel_counter <= 307280;
end*/
//***END of test datain
/*microcontroller side*/
/*always@(posedge EPT0 or posedge WR_CLK)
begin
		if(EPT0 == 1)
				WR <= 1;
		else if(write_side_fifo_wusedw >= 80)
				WR <= 0;
end*/
/*always@(negedge wr_clk)
begin
		if(write_side_fifo_wusedw >= 80)
				FULL <= 0;
		else
				FULL <= 1;
end
assign wFULL = FULL;
always@(posedge EPT0 or negedge wFULL)
begin
		if((EPT0==1) && (wFULL==1))
				rWR <= 1;
		else if((wFULL==0) && (EPT0==0))
				rWR <= 0;
end*/

assign WR = ~mWR;
assign wr = WR;

assign PPF_CONSTANT = (PIXEL_MODE == 2'b01) ? 38400 : 307200;

/*VGA side*/
assign DATA_TO_VGA = (PIXEL_MODE == 2'b01) ? {8'h00, RD_EIGHT} : RD1_DATA;
always@(posedge CLK)
begin
		if(!RD)
		begin
				fifo_rst = pre_fifo_rst;
				pre_fifo_rst = 1'b1;
		end
		else
		begin
				fifo_rst = pre_fifo_rst;
				pre_fifo_rst = 1'b0;
		end
end
always@(posedge CLK)
begin
		if((fifo_rst==0) && (pre_fifo_rst==1))
				rst_sync <= 1'b1;
		else	rst_sync <= 1'b0;
end

/*always@(posedge RD or negedge RD or posedge EPT1 or posedge EPT2)		//Multiple edge trigger error: right click "Synthesize-XST -> Process Property -> 
																							//Other XST Command Line Options: type '-change_error_to_warning "HDLCompiler:1128"'
begin
		if((RD == 1) && (read_side_fifo_wusedw1 >= 79))						//Start from the 1st fifo---HIGHER priority
		begin
				rd1_en <= 1;
				rd2_en <= 0;
		end
		else if((RD == 1) && (read_side_fifo_wusedw2 >= 79))
		begin
				rd1_en <= 0;
				rd2_en <= 1;
		end
		else
		begin
			rd1_en <= 0;
			rd2_en <= 0;
		end
end*/

/**************************************************************
@@
@@					PORT from ALTERA DE2-115 SAMPLE CODE
@@
**************************************************************/		
always @ (posedge CLK)
begin
	  SA      <= (ST==SC_CL+mLENGTH) ? 13'h200	:	ISA;
    BA      <= IBA;
    CS_N    <= ICS_N;
    CKE     <= ICKE;
    RAS_N   <= (ST==SC_CL+mLENGTH) ? 1'b0 : IRAS_N;
    CAS_N   <= (ST==SC_CL+mLENGTH) ? 1'b1 : ICAS_N;
    WE_N    <= (ST==SC_CL+mLENGTH) ? 1'b0 : IWE_N;
	  PM_STOP	<= (ST==SC_CL+mLENGTH) ? 1'b1 : 1'b0;
	  PM_DONE	<= (ST==SC_CL+SC_RCD+mLENGTH+2)	?	1'b1 : 1'b0;
	  DQM		  <= (active && (ST>=SC_CL) )	 ? (((ST==SC_CL+mLENGTH) && Write)?	2'b11	:	2'b00	)	:	2'b11;
	  mDATAOUT<= DQ;
end

always@(posedge CLK or negedge RESET_N)
begin
	if(!RESET_N)
	begin
		CMD			  <= 0;
		ST			  <= 0;
		Pre_RD	  <= 0;
		Pre_WR	  <= 0;
		Read		  <= 0;
		Write		  <= 0;
		OUT_VALID	<= 0;
		IN_REQ		<= 0;
		mWR_DONE	<= 0;
		mRD_DONE	<= 0;
	end
	else
	begin
		Pre_RD	<=	mRD;
		Pre_WR	<=	mWR;
		case (ST)
		0:	begin
				if (!Pre_RD && mRD)
				begin
					Read	<=	1;
					Write	<=	0;
					CMD		<=	2'b01;
					ST		<=	1;
				end
				else if (!Pre_WR && mWR)
				begin
					Read	<=	0;
					Write	<=	1;
					CMD		<=	2'b10;
					ST		<=	1;
				end
		end
		1:	begin
				if (CMDACK)
				begin
					CMD   <=  2'b00;
					ST    <=  2;
				end
		end
		default:  begin	
				if (ST!=SC_CL+SC_RCD+mLENGTH+1)
					ST <= ST + 1;
				else
					ST    <=  0;
		end
		endcase
	
		if (Read)
		begin
			if (ST==SC_CL+SC_RCD+1)
			  OUT_VALID	<=	1;
			else if (ST==SC_CL+SC_RCD+mLENGTH+1)
			begin
				OUT_VALID	<=	0;
				Read		  <=	0;
				mRD_DONE	<=	1;
			end
		end
		else
		  mRD_DONE	  <=	0;
		
		if (Write)
		begin
			if (ST==SC_CL-1)
			  IN_REQ	<=	1;
			else if (ST==SC_CL+mLENGTH-1)
			  IN_REQ	<=	0;
			else if (ST==SC_CL+SC_RCD+mLENGTH)
			begin
				Write 	<=	0;
				mWR_DONE<=	1;
				if(pixel_counter < PPF_CONSTANT*FRAME_No)
							pixel_counter <= pixel_counter + 32;
				else
							pixel_counter <= PPF_CONSTANT*FRAME_No + 80;
			end
		end
		else
		  mWR_DONE  <=	0;
	end
end

//	Internal Address & Length Control
always@(posedge CLK or posedge rst_sync)				//RESET_N -> RD syncronization
	if (rst_sync)
	begin
		/*rWR1_ADDR		  <=	WR1_ADDR;
		rWR2_ADDR		  <=	WR2_ADDR;*/
		//rWR_ADDR			<= WR_ADDR;
		
		rRD1_ADDR		  <=	RD1_ADDR;
		rRD2_ADDR		  <=	RD2_ADDR;
		
		/*rWR1_MAX_ADDR	<=	WR1_MAX_ADDR;
		rWR2_MAX_ADDR	<=	WR2_MAX_ADDR;*/
		rWR_MAX_ADDR  <= WR_MAX_ADDR;
		
		rRD1_MAX_ADDR	<=	RD1_MAX_ADDR;
		rRD2_MAX_ADDR	<=	RD2_MAX_ADDR;

		/*rWR1_LENGTH		<=	WR1_LENGTH;
		rWR2_LENGTH		<=	WR2_LENGTH;*/
		rWR_LENGTH <= WR_LENGTH;
		rRD1_LENGTH		<=	RD1_LENGTH;
		rRD2_LENGTH		<=	RD2_LENGTH;
	end
	else
	begin
	/*
		//	Write Side 1
    if (mWR_DONE&&WR_MASK[0])
		begin
			if(rWR1_ADDR<rWR1_MAX_ADDR-rWR1_LENGTH)
				rWR1_ADDR	<= rWR1_ADDR+rWR1_LENGTH;
			else
				rWR1_ADDR	<= WR1_ADDR;
		end
		//	Write Side 2
		if (mWR_DONE&&WR_MASK[1])
		begin
			if(rWR2_ADDR<rWR2_MAX_ADDR-rWR2_LENGTH)
				rWR2_ADDR	<=	rWR2_ADDR+rWR2_LENGTH;
			else
				rWR2_ADDR	<=	WR2_ADDR;
		end
		*/
		if(mWR_DONE)
		begin
				if(rWR_ADDR<rWR_MAX_ADDR-rWR_LENGTH)
						rWR_ADDR <= rWR_ADDR + rWR_LENGTH;
				else
						rWR_ADDR <= WR_ADDR;
		end
		
		
		//	Read Side 1
		if (mRD_DONE&&RD_MASK[0])
		begin
			if(rRD1_ADDR<rRD1_MAX_ADDR-rRD1_LENGTH)
			begin
				rRD1_ADDR	<=	rRD1_ADDR+rRD1_LENGTH;
				rRD2_ADDR	<= rRD2_ADDR+rRD2_LENGTH;
			end
			else
			begin
				rRD1_ADDR	<=	RD1_ADDR;
				rRD2_ADDR	<= RD2_ADDR;
			end
		end
		//	Read Side 2
		/*if (mRD_DONE&&RD_MASK[1])
		begin
			if(rRD2_ADDR<rRD2_MAX_ADDR-rRD2_LENGTH)
			begin
				rRD2_ADDR	<=	rRD2_ADDR+rRD2_LENGTH;
				rRD1_ADDR	<=	rRD1_ADDR+rRD1_LENGTH;
			end
			else
			begin
				rRD2_ADDR	<=	RD2_ADDR;
				rRD1_ADDR	<=	RD1_ADDR;
			end
		end*/
	end

//	Auto Read/Write Control
always@(posedge CLK or negedge RESET_N)
	if (!RESET_N)
	begin
		mWR		<=	0;
		mRD		<=	0;
		mADDR   <=	0;
		mLENGTH	<=	0;
		RD_MASK <=	0; //Peli
		WR_MASK <=	0;
	end
	else
	begin
		if ( (mWR==0) && (mRD==0) && (ST==0) &&
			(WR_MASK==0)	&&	(RD_MASK==0) )
		begin
		/*
			//	Write Side 1
			if ( (write_side_fifo_rusedw1 >= rWR1_LENGTH) && (rWR1_LENGTH!=0) )
			begin
				mADDR	  <=	rWR1_ADDR;
				mLENGTH	<=	rWR1_LENGTH;
				WR_MASK	<=	2'b01;
				RD_MASK	<=	2'b00;
				mWR		  <=	1;
				mRD		  <=	0;
			end
			//	Write Side 2
			else if ( (write_side_fifo_rusedw2 >= rWR2_LENGTH) && (rWR2_LENGTH!=0) )
			begin
				mADDR	  <=	rWR2_ADDR;
				mLENGTH	<=	rWR2_LENGTH;
				WR_MASK	<=	2'b10;
				RD_MASK	<=	2'b00;
				mWR		  <=	1;
				mRD		  <=	0;
			end
			*/
			if(pixel_counter < PPF_CONSTANT*FRAME_No - 32)
			begin
				if((write_side_fifo_rusedw >= 32) && (RW_SYNC==0))
				begin
					mADDR <= rWR_ADDR;
					mLENGTH <= rWR_LENGTH;
					WR_MASK <= 2'b11;
					RD_MASK <= 2'b00;
					mWR <= 1;
					mRD <= 0;
				end
				else
				begin
					WR_MASK <= 2'b00;
					RD_MASK <= 2'b00;
					mWR <= 0;
					mRD <= 0;
				end
			end
			
			
			
			//	Read Side 1
			else if (((read_side_fifo_wusedw1<rRD1_LENGTH)&&(PIXEL_MODE!=2'b01)) || ((read_side_fifo_wusedw2<rRD1_LENGTH)&&(PIXEL_MODE==2'b01)))
			begin
				mADDR	  <=	rRD1_ADDR;
				mLENGTH	<=	rRD1_LENGTH;
				WR_MASK	<=	2'b00;
				RD_MASK	<=	2'b01;
				mWR		  <=	0;
				mRD		  <=	1;
			end
			//	Read Side 2
			/*else if (read_side_fifo_wusedw2 < rRD2_LENGTH)
			begin
				mADDR  	<=	rRD2_ADDR;
				mLENGTH	<=	rRD2_LENGTH;
				WR_MASK	<=	2'b00;
				RD_MASK	<=	2'b10;
				mWR		  <=	0;
				mRD		  <=	1;
			end*/
		end
		
		if (mWR_DONE)
		begin
			WR_MASK	<=	0;
			mWR		  <=	0;
		end
		
		if (mRD_DONE)
		begin
			RD_MASK	<=	0;
			mRD		  <=	0;
		end
	end

endmodule
