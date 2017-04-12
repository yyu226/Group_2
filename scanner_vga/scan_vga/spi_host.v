`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:39:04 09/15/2015 
// Design Name: 
// Module Name:    spi_host 
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
module spi_host(
	 input cryst,
    output sck,
    input miso,
    output mosi,
    output cs,
	 output cs_flash,
	 output rLED,
	 output gLED,
	 output yLED,
	 
	 output reg[15:0] data,
	 
	 input wr_avl,
	 output reg rw_sync,
	 output wr_clk,
	 output reg[1:0] pixel_mode,
	 output reg[7:0] frame_no,
	 output reg start
    );
	 
//Register List
	 reg mo, m2;
	 reg [7:0] dctr;
	 reg [7:0] state, nxt, s2, n2;
	 reg [2:0] led_control, led_control2;			//{red, green, yellow}
	 
	 
	 reg [6:0] cntr;
	 reg [7:0] rcmd1, rcmd2, rcmd3, rcmd4, rcmd5, rcmd6;
	 reg [7:0] rcmd1i, rcmd2i, rcmd3i, rcmd4i, rcmd5i, rcmd6i;
	 reg [7:0] rcvb, rcvb2;
	 reg reset;
	 reg [4:0] ncr, ncr2;
	 
	 reg [31:0] block;			//need to read roughly 7816 bolcks
	 reg [9:0] bc;					//byte counter 0~512
	 
	 reg clk_sel;
	 reg cs1, cs2;
	 reg [10:0] delay;
	 
	 //reg [7:0] ram_buffer [511:0];		//RAM cell to store ONE block data
	 //Cannot use RAM ARRAY, it generates so many wires which is eventually going to run out all the LUTs

	 reg [7:0] recev_byte;
	 reg WR_CLK;
	 reg RD_EN;
	 
	 reg [7:0] header[2:0];
	 //Memory Array
	 reg [15:0] cache0 [31:0];
	 reg [15:0] cache1 [31:0];
	 
	 reg [2:0] stt;
	 reg [1:0] even_odd, flip;
	 reg [5:0] idx;

//Wire List	
	 wire /*clk_45M,*/ clk_400K, clk_23M;
	 wire wlck_sel;
	 wire wcntr0, wcntr6;
	 
	 wire empty;
	 
	 
initial
begin
		mo <= 1'b0;
		dctr <= 0;
		state <= 0;
		nxt <= 0;
		cs1 <= 0;
		led_control <= 3'b000;
		cntr <= 0;
		rcvb <= 8'h00;
		reset <= 1'b0;
		ncr <= 0;
		block <= 32'h00000000;
		bc <= 0;
		clk_sel <= 1'b0;
		
		led_control2 = 3'b000;
		m2 <= 1'b1;
		n2 <= 8'h00;
		s2 <= 8'h00;
		cs2 <= 1'b1;
		ncr2 <= 0;
		
		delay <= 0;
		
		//WR_EN <= 0;
		RD_EN <= 0;
		WR_CLK <= 0;
		even_odd <= 2'b00;
		flip <= 2'b00;
		stt <= 3'b000;
		idx <= 6'b000000;
		
		pixel_mode <= 0;
		frame_no <= 2;
		start <= 0;
end

	
always@(posedge cryst)
          cntr <= cntr + 1;


assign clk_400K = cntr[6];	
assign clk_23M = cntr[2]; 

assign sck = (clk_sel==1'b0) ? clk_400K : clk_23M;

assign rLED = (clk_sel==1'b0) ? led_control[2] : led_control2[2];
assign gLED = (clk_sel==1'b0) ? led_control[1] : led_control2[1];
assign yLED = (clk_sel==1'b0) ? led_control[0] : led_control2[0];


assign cs_flash = 1'b1;
assign mosi = (clk_sel==1'b0) ? mo : m2;
assign cs = (clk_sel==1'b0) ? cs1 : cs2;
/**************************************************************************************
**Initialization Process
*/			
always@(negedge clk_400K)
begin
		case(state)
			//74 clock delay
			8'h00: begin
							cs1 <= 1'b1;
							mo <= 1'b1;
					 end
			8'h01: begin
							rcmd1 <= 8'h40;
							rcmd2 <= 8'h00;
							rcmd3 <= 8'h00;
							rcmd4 <= 8'h00;
							rcmd5 <= 8'h00;
							rcmd6 <= 8'h95;
					 end
		
			//Xmit CMD0
			            //
			8'h02: begin
							mo <= 1;
							cs1 <= 1;
					 end
			8'h03: mo <= 1;
			8'h04: mo <= 1;
			8'h05: mo <= 1;
			8'h06: mo <= 1;
			8'h07: mo <= 1;
			8'h08: mo <= 1;
			8'h09: mo <= 1;			
		  8'h0a: cs1 <= 0;
		  8'h0b: mo <= 1;
		  8'h0c: mo <= 1;
		  8'h0d: mo <= 1;
		  8'h0e: mo <= 1;
		  8'h0f: mo <= 1;
		  8'h10: mo <= 1;
		  8'h11: mo <= 1;
		  8'h12: mo <= 1;
			/*0x40*/
		  8'h13: mo <= rcmd1[7];
		  8'h14: mo <= rcmd1[6];
		  8'h15: mo <= rcmd1[5];
		  8'h16: mo <= rcmd1[4];
		  8'h17: mo <= rcmd1[3];
		  8'h18: mo <= rcmd1[2];
		  8'h19: mo <= rcmd1[1];
		  8'h1a: mo <= rcmd1[0];
		  /*0x00*/
		  8'h1b: mo <= rcmd2[7];
		  8'h1c: mo <= rcmd2[6];
		  8'h1d: mo <= rcmd2[5];
		  8'h1e: mo <= rcmd2[4];
		  8'h1f: mo <= rcmd2[3];
		  8'h20: mo <= rcmd2[2];
		  8'h21: mo <= rcmd2[1];
		  8'h22: mo <= rcmd2[0];
		  /*0x00*/
		  8'h23: mo <= rcmd3[7];
		  8'h24: mo <= rcmd3[6];
		  8'h25: mo <= rcmd3[5];
		  8'h26: mo <= rcmd3[4];
		  8'h27: mo <= rcmd3[3];
		  8'h28: mo <= rcmd3[2];
		  8'h29: mo <= rcmd3[1];
		  8'h2a: mo <= rcmd3[0];
		  /*0x00*/
		  8'h2b: mo <= rcmd4[7];
		  8'h2c: mo <= rcmd4[6];
		  8'h2d: mo <= rcmd4[5];
		  8'h2e: mo <= rcmd4[4];
		  8'h2f: mo <= rcmd4[3];
		  8'h30: mo <= rcmd4[2];
		  8'h31: mo <= rcmd4[1];
		  8'h32: mo <= rcmd4[0];
		  /*0x00*/
		  8'h33: mo <= rcmd5[7];
		  8'h34: mo <= rcmd5[6];
		  8'h35: mo <= rcmd5[5];
		  8'h36: mo <= rcmd5[4];
		  8'h37: mo <= rcmd5[3];
		  8'h38: mo <= rcmd5[2];
		  8'h39: mo <= rcmd5[1];
		  8'h3a: mo <= rcmd5[0];
		  /*0x95*/
		  8'h3b: mo <= rcmd6[7];
		  8'h3c: mo <= rcmd6[6];
		  8'h3d: mo <= rcmd6[5];
		  8'h3e: mo <= rcmd6[4];
		  8'h3f: mo <= rcmd6[3];
		  8'h40: mo <= rcmd6[2];
		  8'h41: mo <= rcmd6[1];
		  8'h42: begin
						mo <= rcmd6[0];
						ncr <= 0;
					end
		  
		  //Response of CMD0
		   8'h43: mo <= 1;
		   8'h44: begin
							mo <= 1'b1;
							ncr <= ncr + 1;
					 end
			8'h45: mo <= 1'b1;
			8'h46: mo <= 1'b1;
			8'h47: mo <= 1'b1;
			8'h48: mo <= 1'b1;
		   8'h49: mo <= 1'b1;
			8'h4a: mo <= 1'b1;	
		  //above is the 8 byte NCR
		  
		  8'h4b: mo <= 1'b1;						//rcvb[6]
		  8'h4c: mo <= 1'b1;						//rcvb[5]
		  8'h4d: mo <= 1'b1;						//rcvb[4]
		  8'h4e:	mo <= 1'b1;						//rcvb[3]
		  8'h4f:	mo <= 1'b1;						//rcvb[2]
		  8'h50: mo <= 1'b1;						//rcvb[1]
		  8'h51:	mo <= 1'b1;						//rcvb[0]
		  
		  8'h52: mo <= 1'b1;									//Transition wait to check the received response
		  8'h53: begin
						rcmd1 <= 8'h48;
						rcmd2 <= 8'h00;
						rcmd3 <= 8'h00;
						rcmd4 <= 8'h01;
						rcmd5 <= 8'haa;
						rcmd6 <= 8'h87;
					end
		  8'h54: ncr <= 0;								//immediately get started to receive R7 BIT[30]
						
		  8'h55: mo <= 1'b1;
		  8'h56: ncr <= ncr + 1;
		  8'h57: mo <= 1'b1;
		  8'h58: mo <= 1'b1;
		  8'h59: mo <= 1'b1;
			//repeat 6 times --- R7 BIT[29]~BIT[0] loop{8'h55 ~ 8'h59}

			
			/****The END of COMMAND8
				****/
				//BEGINNING OF ACMD41
			8'h5a: begin
							rcmd1 <= 8'h77;
							rcmd2 <= 8'h00;
							rcmd3 <= 8'h00;
							rcmd4 <= 8'h00;
							rcmd5 <= 8'h00;
							rcmd6 <= 8'h65;
							
							mo <= 1'b1;
							cs1 <= 1'b1;
					 end
			8'h5b: mo <= 1;
			8'h5c: mo <= 1;
			8'h5d: mo <= 1;
			8'h5e: mo <= 1;
			8'h5f: mo <= 1;
			8'h60: mo <= 1;
			8'h61: mo <= 1;			
		   8'h62: cs1 <= 0;
		   8'h63: mo <= 1;
		   8'h64: mo <= 1;
		   8'h65: mo <= 1;
		   8'h66: mo <= 1;
		   8'h67: mo <= 1;
		   8'h68: mo <= 1;
		   8'h69: mo <= 1;
		   8'h6a: mo <= 1;
			/*0x40*/
		  8'h6b: mo <= rcmd1[7];
		  8'h6c: mo <= rcmd1[6];
		  8'h6d: mo <= rcmd1[5];
		  8'h6e: mo <= rcmd1[4];
		  8'h6f: mo <= rcmd1[3];
		  8'h70: mo <= rcmd1[2];
		  8'h71: mo <= rcmd1[1];
		  8'h72: mo <= rcmd1[0];
		  /*0x00*/
		  8'h73: mo <= rcmd2[7];
		  8'h74: mo <= rcmd2[6];
		  8'h75: mo <= rcmd2[5];
		  8'h76: mo <= rcmd2[4];
		  8'h77: mo <= rcmd2[3];
		  8'h78: mo <= rcmd2[2];
		  8'h79: mo <= rcmd2[1];
		  8'h7a: mo <= rcmd2[0];
		  /*0x00*/
		  8'h7b: mo <= rcmd3[7];
		  8'h7c: mo <= rcmd3[6];
		  8'h7d: mo <= rcmd3[5];
		  8'h7e: mo <= rcmd3[4];
		  8'h7f: mo <= rcmd3[3];
		  8'h80: mo <= rcmd3[2];
		  8'h81: mo <= rcmd3[1];
		  8'h82: mo <= rcmd3[0];
		  /*0x00*/
		  8'h83: mo <= rcmd4[7];
		  8'h84: mo <= rcmd4[6];
		  8'h85: mo <= rcmd4[5];
		  8'h86: mo <= rcmd4[4];
		  8'h87: mo <= rcmd4[3];
		  8'h88: mo <= rcmd4[2];
		  8'h89: mo <= rcmd4[1];
		  8'h8a: mo <= rcmd4[0];
		  /*0x00*/
		  8'h8b: mo <= rcmd5[7];
		  8'h8c: mo <= rcmd5[6];
		  8'h8d: mo <= rcmd5[5];
		  8'h8e: mo <= rcmd5[4];
		  8'h8f: mo <= rcmd5[3];
		  8'h90: mo <= rcmd5[2];
		  8'h91: mo <= rcmd5[1];
		  8'h92: mo <= rcmd5[0];
		  /*0x95*/
		  8'h93: mo <= rcmd6[7];
		  8'h94: mo <= rcmd6[6];
		  8'h95: mo <= rcmd6[5];
		  8'h96: mo <= rcmd6[4];
		  8'h97: mo <= rcmd6[3];
		  8'h98: mo <= rcmd6[2];
		  8'h99: mo <= rcmd6[1];
		  8'h9a: mo <= rcmd6[0];
		  8'h9b: ncr <= 0;
		  
		  8'h9c: begin									//ACMD41
							rcmd1 <= 8'h69;
							rcmd2 <= 8'h40;
							rcmd3 <= 8'h00;
							rcmd4 <= 8'h00;
							rcmd5 <= 8'h00;
							rcmd6 <= 8'hff;
							
							mo <= 1'b1;
							cs1 <= 1'b1;
					end
		  8'h9d: cs1 <= 1'b1;										//END OF SUCCESSFUL INITIALIZATION
		  8'h9e: begin
							rcmd1 <= 8'h46;							//CMD6 switch mode (HIGH SPEED)
							rcmd2 <= 8'h80;
							rcmd3 <= 8'h00;
							rcmd4 <= 8'h00;
							rcmd5 <= 8'h01;
							rcmd6 <= 8'hff;

							mo <= 1'b1;
					end

		  8'h9f: clk_sel <= 1'b1;										//Switch to a faster sclk, maximize the performance of data reading
		  		 
		endcase			
end

always@(posedge clk_400K)
begin
	case(state)
		8'h00: nxt <= 8'h00;
		8'h01: nxt <= 8'h02;
		/*8'h02: nxt <= 8'h03; 3: nxt <= 4; 4: nxt <= 5; 5: nxt <= 6; 6: nxt <= 7;
		7: nxt <= 8; 8: nxt <= 9; 9: nxt <= 10; 10: nxt <= 11; 11: nxt <= 12;
		
		12: nxt <= 13; 13: nxt <= 14; 14: nxt <= 15; 15: nxt <= 16; 16: nxt <= 17;
		17: nxt <= 18; 18: nxt <= 19; 19: nxt <= 20; 20: nxt <= 21; 21: nxt <= 22;
		
		22: nxt <= 23; 23: nxt <= 24; 24: nxt <= 25; 25: nxt <= 26; 26: nxt <= 27;
		27: nxt <= 28; 28: nxt <= 29; 29: nxt <= 30; 30: nxt <= 31; 31: nxt <= 32;
		
		32: nxt <= 33; 33: nxt <= 34; 34: nxt <= 35; 35: nxt <= 36; 36: nxt <= 37;
		37: nxt <= 38; 38: nxt <= 39; 39: nxt <= 40; 40: nxt <= 41; 41: nxt <= 42;
		
		42: nxt <= 43; 43: nxt <= 44; 44: nxt <= 45; 45: nxt <= 46; 46: nxt <= 47;
		47: nxt <= 48; 48: nxt <= 49; 49: nxt <= 50; 50: nxt <= 51; 51: nxt <= 52;
		
		52: nxt <= 53; 53: nxt <= 54; 54: nxt <= 55; 55: nxt <= 56; 56: nxt <= 57;
		57: nxt <= 58; 58: nxt <= 59; 59: nxt <= 60; 60: nxt <= 61; 61: nxt <= 62;
		
		62: nxt <= 63; 63: nxt <= 64; 64: nxt <= 65; 65: nxt <= 66; 66: nxt <= 67;*/
		
	  
	  8'h43: begin								//67		
					if(miso==1'b0)
					begin
						rcvb <= rcvb & 8'b01111111;
						nxt <= 8'h4b;
					end
					else
					begin
						rcvb <= rcvb | 8'b10000000;
						nxt <= 8'h44;
					end
				end
	  8'h44: begin
					if(miso==1'b0)
					begin
						rcvb <= rcvb & 8'b01111111;
						nxt <= 8'h4b;
					end
					else
					begin
						rcvb <= rcvb | 8'b10000000;
						nxt <= 8'h45;
					end
				end
	  8'h45: begin
					if(miso==1'b0)
					begin
						rcvb <= rcvb & 8'b01111111;
						nxt <= 8'h4b;
					end
					else
					begin
						rcvb <= rcvb | 8'b10000000;
						nxt <= 8'h46;
					end
				end
	  8'h46: begin
					if(miso==1'b0)
					begin
						rcvb <= rcvb & 8'b01111111;
						nxt <= 8'h4b;
					end
					else
					begin
						rcvb <= rcvb | 8'b10000000;
						nxt <= 8'h47;
					end
				end
		8'h47: begin
					if(miso==1'b0)
					begin
						rcvb <= rcvb & 8'b01111111;
						nxt <= 8'h4b;
					end
					else
					begin
						rcvb <= rcvb | 8'b10000000;
						nxt <= 8'h48;
					end
				 end
	  8'h48: begin
					if(miso==1'b0)
					begin
						rcvb <= rcvb & 8'b01111111;
						nxt <= 8'h4b;
					end
					else
					begin
						rcvb <= rcvb | 8'b10000000;
						nxt <= 8'h49;
					end
				end
	  8'h49: begin
					if(miso==1'b0)
					begin
						rcvb <= rcvb & 8'b01111111;
						nxt <= 8'h4b;
					end
					else
					begin
						rcvb <= rcvb | 8'b10000000;
						nxt <= 8'h4a;
					end
				end
	  8'h4a: begin
					if(miso==1'b0)
					begin
						rcvb <= rcvb & 8'b01111111;
						nxt <= 8'h4b;
					end
					else
					begin
						if(ncr < 4'b1110)
							nxt <= 8'h43;
						else
							nxt <= 8'h02;
					end
				end	
	  /*****************************************
				**************************************/
	  8'h4b: begin												//75  rcvb[6]
					nxt <= 8'h4c;
					if(miso==1'b0)
						rcvb <= rcvb & 8'b10111111;
					else
						rcvb <= rcvb | 8'b01000000;
				end
	  8'h4c: begin												//rcvb[5]
					led_control <= 3'b001;
					nxt <= 8'h4d;
					if(miso==1'b0)
						rcvb <= rcvb & 8'b11011111;
					else
						rcvb <= rcvb | 8'b00100000;
				end  
	  8'h4d: begin												//rcvb[4]
					nxt <= 8'h4e;
					if(miso==1'b0)
						rcvb <= rcvb & 8'b11101111;
					else
						rcvb <= rcvb | 8'b00010000;
				end  
	  8'h4e: begin												//rcvb[3]
					nxt <= 8'h4f;
					if(miso==1'b0)
						rcvb <= rcvb & 8'b11110111;
					else
						rcvb <= rcvb | 8'b00001000;
				end 
	  8'h4f: begin												//rcvb[2]
					nxt <= 8'h50;
					if(miso==1'b0)
						rcvb <= rcvb & 8'b11111011;
					else
						rcvb <= rcvb | 8'b00000100;
				end 
	  8'h50: begin												//rcvb[1]
					nxt <= 8'h51;
					if(miso==1'b0)
						rcvb <= rcvb & 8'b11111101;
					else
						rcvb <= rcvb | 8'b00000010;
				end  
	  8'h51: begin												//rcvb[0]
					nxt <= 8'h52;
					if(miso==1'b0)
						rcvb <= rcvb & 8'b11111110;
					else
						rcvb <= rcvb | 8'b00000001;
				end 
			
	  8'h52: begin
						if(rcmd1 == 8'h40)
						begin
								if(rcvb == 8'h01)
									nxt <= 8'h53;
								else
									nxt <= 8'h02;
						end
						else if(rcmd1 == 8'h48)
						begin
								if(rcvb == 8'h01)
									nxt <= 8'h54;
								else
									nxt <= 8'h02;
						end
						else if(rcmd1 == 8'h69)
						begin
								if(rcvb == 8'h00)
									nxt <= 8'h9d;
								else
									nxt <= 8'h5a;			//restart CMD55-ACMD41
						end
						else if(rcmd1 == 8'h46)
						begin
								if(rcvb == 8'h00)
								begin
									nxt <= 8'h9f;
									//led_control <= 3'b100;
								end
								else
									nxt <= 8'h02;
						end
				end
	  8'h53: nxt <= 8'h02;
	  
	  8'h54: begin												//continue to read R7
						nxt <= 8'h55;
						if(miso==1'b1)
							rcvb <= rcvb | 8'b01000000;
						else
							rcvb <= rcvb & 8'b10111111;
				end
/*loop (5 x 6)*/		
		8'h55: begin
						nxt <= 8'h56;
						if(miso==1'b1)
							rcvb <= rcvb | 8'b10000000;
						else
							rcvb <= rcvb & 8'b01111111;
				 end
		8'h56: begin
						nxt <= 8'h57;
						if(miso==1'b1)
							rcvb <= rcvb | 8'b10000000;
						else
							rcvb <= rcvb & 8'b01111111;
				 end
		8'h57: begin
						nxt <= 8'h58;
						if(miso==1'b1)
							rcvb <= rcvb | 8'b10000000;
						else
							rcvb <= rcvb & 8'b01111111;
				 end
		8'h58: begin
						nxt <= 8'h59;
						if(miso==1'b1)
							rcvb <= rcvb | 8'b10000000;
						else
							rcvb <= rcvb & 8'b01111111;
				 end
	  8'h59: begin
						if(ncr < 6)
							nxt <= 8'h55;
						else
							nxt <= 8'h5a;
				end
		 /***************************/
		  /***************************/
		8'h5b: nxt <= 8'h5c;
		
		8'h9b: begin
						if(rcmd1 == 8'h77)				//CMD55
							nxt <= 8'h9c;
						else if(rcmd1 == 8'h69)			//ACMD41
							nxt <= 8'h43;
				 end
		8'h9c: nxt <= 8'h5b;
		
		8'h9e: nxt <= 8'h02;
		8'h9f: nxt <= 8'h9f;
			
		default: nxt <= state + 1;
	endcase
end

always@(negedge clk_400K or posedge reset)				//MOSI is always changing at the falling edge of sclk
begin
		if(reset==1'b1)
			state <= 8'h01;
		else
			state <= nxt;
end

/********************************************************************************************************************
***************************************************************
**  S T A T E             M A C H I N E              No. 2
*****************************************************************
*************************************************************
******************/
always@(negedge clk_23M)
begin
		if(clk_sel==1'b0)
				s2 <= 8'h00;
		else
				s2 <= n2;
end

always@(posedge clk_23M)
begin
		case(s2)
			  8'h00: n2 <= 8'h66;
			  
			  8'h43: begin								//67
							if(miso==1'b0)
							begin
								rcvb2 <= rcvb2 & 8'b01111111;
								n2 <= 8'h4b;
							end
							else
							begin
								rcvb2 <= rcvb2 | 8'b10000000;
								n2 <= 8'h44;
							end
						 end
				  8'h44: begin
								if(miso==1'b0)
								begin
									rcvb2 <= rcvb2 & 8'b01111111;
									n2 <= 8'h4b;
								end
								else
								begin
									rcvb2 <= rcvb2 | 8'b10000000;
									n2 <= 8'h45;
								end
							end
				  8'h45: begin
								if(miso==1'b0)
								begin
									rcvb2 <= rcvb2 & 8'b01111111;
									n2 <= 8'h4b;
								end
								else
								begin
									rcvb2 <= rcvb2 | 8'b10000000;
									n2 <= 8'h46;
								end
							end
				  8'h46: begin
								if(miso==1'b0)
								begin
									rcvb2 <= rcvb2 & 8'b01111111;
									n2 <= 8'h4b;
								end
								else
								begin
									rcvb2 <= rcvb2 | 8'b10000000;
									n2 <= 8'h47;
								end
							end
					8'h47: begin
								if(miso==1'b0)
								begin
									rcvb2 <= rcvb2 & 8'b01111111;
									n2 <= 8'h4b;
								end
								else
								begin
									rcvb2 <= rcvb2 | 8'b10000000;
									n2 <= 8'h48;
								end
							 end
				  8'h48: begin
								if(miso==1'b0)
								begin
									rcvb2 <= rcvb2 & 8'b01111111;
									n2 <= 8'h4b;
								end
								else
								begin
									rcvb2 <= rcvb2 | 8'b10000000;
									n2 <= 8'h49;
								end
							end
				  8'h49: begin
								if(miso==1'b0)
								begin
									rcvb2 <= rcvb2 & 8'b01111111;
									n2 <= 8'h4b;
								end
								else
								begin
									rcvb2 <= rcvb2 | 8'b10000000;
									n2 <= 8'h4a;
								end
							end
				  8'h4a: begin
									if(miso==1'b0)
									begin
										rcvb2 <= rcvb2 & 8'b01111111;
										n2 <= 8'h4b;
									end
									else
									begin
										if(ncr2 < 4'b1010)
											n2 <= 8'h43;
										else
											n2 <= 8'h01;
									end
							 end
					//rcvb2[6] ~ rcvb2[0]
					8'h4b: begin
									n2 <= 8'h4c;
									if(miso==1'b0)
											rcvb2 <= rcvb2 & 8'b10111111;
									else
											rcvb2 <= rcvb2 | 8'b01000000;
							 end
					8'h4c: begin
									n2 <= 8'h4d;
									if(miso==1'b0)
											rcvb2 <= rcvb2 & 8'b11011111;
									else
											rcvb2 <= rcvb2 | 8'b00100000;
							 end
					8'h4d: begin
									n2 <= 8'h4e;
									if(miso==1'b0)
											rcvb2 <= rcvb2 & 8'b11101111;
									else
											rcvb2 <= rcvb2 | 8'b00010000;
							 end
					8'h4e: begin
									n2 <= 8'h4f;
									if(miso==1'b0)
											rcvb2 <= rcvb2 & 8'b11110111;
									else
											rcvb2 <= rcvb2 | 8'b00001000;
							 end
					8'h4f: begin
									n2 <= 8'h50;
									if(miso==1'b0)
											rcvb2 <= rcvb2 & 8'b11111011;
									else
											rcvb2 <= rcvb2 | 8'b00000100;
							 end
					8'h50: begin
									n2 <= 8'h51;
									if(miso==1'b0)
											rcvb2 <= rcvb2 & 8'b11111101;
									else
											rcvb2 <= rcvb2 | 8'b00000010;
							 end
					8'h51: begin
									n2 <= 8'h52;
									if(miso==1'b0)
											rcvb2 <= rcvb2 & 8'b11111110;
									else
											rcvb2 <= rcvb2 | 8'b00000001;
							 end
					/***************************************/
					8'h52: begin
									//led_control2 <= 3'b010;
									if(rcvb2==8'h00)
											n2 <= 8'h53;
									else
											n2 <= 8'h01;
							 end
 
			
			//POLL FOR 0xFE
			  8'h53: begin
								n2 <= 8'h54;
								rcvb2 <= 0;
						end
			  8'h54: begin
							if(miso==1'b1)
							begin
								n2 <= 8'h55;
								rcvb2 <= (rcvb2 << 1) + 1;
							end
							else
							begin
									if(rcvb2<<1 == 8'hfe)
											n2 <= 8'h5c;
									else
									begin
											n2 <= 8'h55;
											rcvb2 <= rcvb2 << 1;
									end
							end
						end
			  8'h55: begin
							if(miso==1'b1)
							begin
									n2 <= 8'h56;
									rcvb2 <= (rcvb2 << 1) + 1;
							end
							else
							begin
									if(rcvb2<<1 == 8'hfe)
											n2 <= 8'h5c;
									else
									begin
											n2 <= 8'h56;
											rcvb2 <= rcvb2 << 1;
									end
							end
						end
				8'h56: begin
							if(miso==1'b1)
							begin
									n2 <= 8'h57;
									rcvb2 <= (rcvb2 << 1) + 1;
							end
							else
							begin
									if(rcvb2<<1 == 8'hfe)
											n2 <= 8'h5c;
									else
									begin
											n2 <= 8'h57;
											rcvb2 <= rcvb2 << 1;
									end
							end
						 end
				8'h57: begin
							if(miso==1'b1)
							begin
									n2 <= 8'h58;
									rcvb2 <= (rcvb2 << 1) + 1;
							end
							else
							begin
									if(rcvb2<<1 == 8'hfe)
											n2 <= 8'h5c;
									else
									begin
											n2 <= 8'h58;
											rcvb2 <= rcvb2 << 1;
									end
							end
						 end
				8'h58: begin
							if(miso==1'b1)
							begin
									n2 <= 8'h59;
									rcvb2 <= (rcvb2 << 1) + 1;
							end
							else
							begin
									if(rcvb2<<1 == 8'hfe)
											n2 <= 8'h5c;
									else
									begin
											n2 <= 8'h59;
											rcvb2 <= rcvb2 << 1;
									end
							end
						 end
				8'h59: begin
							if(miso==1'b1)
							begin
									n2 <= 8'h5a;
									rcvb2 <= (rcvb2 << 1) + 1;
							end
							else
							begin
									if(rcvb2<<1 == 8'hfe)
											n2 <= 8'h5c;
									else
									begin
											n2 <= 8'h5a;
											rcvb2 <= rcvb2 << 1;
									end
							end
						 end
				8'h5a: begin
							if(miso==1'b1)
							begin
									n2 <= 8'h5b;
									rcvb2 <= (rcvb2 << 1) + 1;
							end
							else
							begin
									if(rcvb2<<1 == 8'hfe)
											n2 <= 8'h5c;
									else
									begin
											n2 <= 8'h5b;
											rcvb2 <= rcvb2 << 1;
									end
							end
						 end
				8'h5b: begin
								if(ncr2 < 60)
								begin
										if(miso==1'b1)
										begin
												n2 <= 8'h54;
												rcvb2 <= (rcvb2 << 1) + 1;
										end
										else
										begin
												if(rcvb2<<1 == 8'hfe)
														n2 <= 8'h5c;
												else
												begin
														n2 <= 8'h54;
														rcvb2 <= rcvb2 << 1;
												end
										end
								end
								else
										n2 <= 8'h01;
						 end
				
				
				/*****START TO RECEIVE VALID DATA (1 BLOCK)*************
																		*/
				8'h5c: begin
								n2 <= 8'h5d;
								if(miso==1'b1)
									rcvb2 <= rcvb2 | 8'b10000000;
								else
									rcvb2 <= rcvb2 & 8'b01111111;
						 end
				8'h5d: begin
								n2 <= 8'h5e;
								if(miso==1'b1)
									rcvb2 <= rcvb2 | 8'b01000000;
								else
									rcvb2 <= rcvb2 & 8'b10111111;
						 end
				8'h5e: begin
								n2 <= 8'h5f;
								if(miso==1'b1)
									rcvb2 <= rcvb2 | 8'b00100000;
								else
									rcvb2 <= rcvb2 & 8'b11011111;
						 end
				8'h5f: begin
								n2 <= 8'h60;
								if(miso==1'b1)
									rcvb2 <= rcvb2 | 8'b00010000;
								else
									rcvb2 <= rcvb2 & 8'b11101111;
						 end
				8'h60: begin
								n2 <= 8'h61;
								if(miso==1'b1)
									rcvb2 <= rcvb2 | 8'b00001000;
								else
									rcvb2 <= rcvb2 & 8'b11110111;
						 end
				8'h61: begin
								n2 <= 8'h62;
								if(miso==1'b1)
									rcvb2 <= rcvb2 | 8'b00000100;
								else
									rcvb2 <= rcvb2 & 8'b11111011;
						 end
				8'h62: begin
								n2 <= 8'h63;
								if(miso==1'b1)
									rcvb2 <= rcvb2 | 8'b00000010;
								else
									rcvb2 <= rcvb2 & 8'b11111101;
						 end
				8'h63: begin
								if(miso==1'b1)
									rcvb2 <= rcvb2 | 8'b00000001;
								else
									rcvb2 <= rcvb2 & 8'b11111110;
									
								if(bc <= 512)
									n2 <= 8'h5c;
								else
								begin
									n2 <= 8'h64;				//read next block
									block <= block + 1;
								end
						 end
						 
				
				 8'h65: begin
									n2 <= 8'h01;
									if(block > 32'h00001c20)															//END OF 6501 blocks
											led_control2 <= 3'b100;
									else
									begin
											led_control2 <= 3'b010;
											if(block == 1)
											begin
													pixel_mode <= (header[0]==8'h01) ? 2'b01 : ((header[0]==8'h08) ? 2'b10 : 2'b11);
													frame_no <= header[1];
													start <= 1;
											end
											else;
									end
						  end
				
				//DELAY
				 8'h6a: begin
								if(delay < 2000)
									n2 <= 8'h66;
								else
									n2 <= 8'h01;
						  end
			
			
			default: n2 <= s2 + 1;
		endcase
end

always@(negedge clk_23M)
begin
		case(s2)
			8'h00: begin
							m2 <= 1'b1;
							cs2 <= 1'b1;
					 end
			8'h01: begin									//CMD17  start reading single block data
						rcmd1i <= 8'h51;
						rcmd2i <= block[31:24];
						rcmd3i <= block[23:16];
						rcmd4i <= block[15:8];
						rcmd5i <= block[7:0];
						rcmd6i <= 8'hff;
						
						m2  <= 1'b1;
						cs2 <= 1'b1;
					 end
			8'h02: m2 <= 1;
			8'h03: m2 <= 1;
			8'h04: m2 <= 1;
			8'h05: m2 <= 1;
			8'h06: m2 <= 1;
			8'h07: m2 <= 1;
			8'h08: m2 <= 1;			
		   8'h09: cs2 <= 0;
		   8'h0a: m2 <= 1;
		   8'h0b: m2 <= 1;
		   8'h0c: m2 <= 1;
		   8'h0d: m2 <= 1;
		   8'h0e: m2 <= 1;
		   8'h0f: m2 <= 1;
		   8'h10: m2 <= 1;
		   8'h11: m2 <= 1;
			/*0x51*/
		  8'h12: m2 <= rcmd1i[7];
		  8'h13: m2 <= rcmd1i[6];
		  8'h14: m2 <= rcmd1i[5];
		  8'h15: m2 <= rcmd1i[4];
		  8'h16: m2 <= rcmd1i[3];
		  8'h17: m2 <= rcmd1i[2];
		  8'h18: m2 <= rcmd1i[1];
		  8'h19: m2 <= rcmd1i[0];
		  /*block[3]*/
		  8'h1a: m2 <= rcmd2i[7];
		  8'h1b: m2 <= rcmd2i[6];
		  8'h1c: m2 <= rcmd2i[5];
		  8'h1d: m2 <= rcmd2i[4];
		  8'h1e: m2 <= rcmd2i[3];
		  8'h1f: m2 <= rcmd2i[2];
		  8'h20: m2 <= rcmd2i[1];
		  8'h21: m2 <= rcmd2i[0];
		  /*block[2]*/
		  8'h22: m2 <= rcmd3i[7];
		  8'h23: m2 <= rcmd3i[6];
		  8'h24: m2 <= rcmd3i[5];
		  8'h25: m2 <= rcmd3i[4];
		  8'h26: m2 <= rcmd3i[3];
		  8'h27: m2 <= rcmd3i[2];
		  8'h28: m2 <= rcmd3i[1];
		  8'h29: m2 <= rcmd3i[0];
		  /*block[1]*/
		  8'h2a: m2 <= rcmd4i[7];
		  8'h2b: m2 <= rcmd4i[6];
		  8'h2c: m2 <= rcmd4i[5];
		  8'h2d: m2 <= rcmd4i[4];
		  8'h2e: m2 <= rcmd4i[3];
		  8'h2f: m2 <= rcmd4i[2];
		  8'h30: m2 <= rcmd4i[1];
		  8'h31: m2 <= rcmd4i[0];
		  /*block[0]*/
		  8'h32: m2 <= rcmd5i[7];
		  8'h33: m2 <= rcmd5i[6];
		  8'h34: m2 <= rcmd5i[5];
		  8'h35: m2 <= rcmd5i[4];
		  8'h36: m2 <= rcmd5i[3];
		  8'h37: m2 <= rcmd5i[2];
		  8'h38: m2 <= rcmd5i[1];
		  8'h39: m2 <= rcmd5i[0];
		  /*0x05*/
		  8'h3a: m2 <= rcmd6i[7];
		  8'h3b: m2 <= rcmd6i[6];
		  8'h3c: m2 <= rcmd6i[5];
		  8'h3d: m2 <= rcmd6i[4];
		  8'h3e: m2 <= rcmd6i[3];
		  8'h3f: m2 <= rcmd6i[2];
		  8'h40: m2 <= rcmd6i[1];
		  8'h41: m2 <= rcmd6i[0];
		  8'h42: ncr2 <= 0;
		  
		  //R1 RESPONSE           VALID: 0x00
		  8'h43: m2 <= 1'b1;
		   8'h44: begin
							m2 <= 1'b1;
							ncr2 <= ncr2 + 1;
					 end
			8'h45: m2 <= 1'b1;
			8'h46: m2 <= 1'b1;
			8'h47: m2 <= 1'b1;
			8'h48: m2 <= 1'b1;
		   8'h49: m2 <= 1'b1;
			8'h4a: m2 <= 1'b1;	
		  //above is the 8 byte NCR
		  
		  8'h4b: m2 <= 1'b1;						//rcvb[6]
		  8'h4c: m2 <= 1'b1;						//rcvb[5]
		  8'h4d: m2 <= 1'b1;						//rcvb[4]
		  8'h4e:	m2 <= 1'b1;						//rcvb[3]
		  8'h4f:	m2 <= 1'b1;						//rcvb[2]
		  8'h50: m2 <= 1'b1;						//rcvb[1]
		  8'h51:	m2 <= 1'b1;						//rcvb[0]
		  
		  8'h52: m2 <= 1'b1;						//CHECK FOR VALID RESPONSE
					
		  //poll for the DATA TOKEN of the packet 0xFE
		   8'h53: begin
							ncr2 <= 0;
							m2 <= 1'b1;
					 end
		   8'h54: bc <= 0;
		   8'h55: bc <= 0;
			8'h56: bc <= 0;
			8'h57: bc <= 0;
			8'h58: bc <= 0;
			8'h59: bc <= 0;
		   8'h5a: begin
							bc <= 0;
							ncr2 <= ncr2 + 1;
					 end
			8'h5b: bc <= 0;
			//
			//data token been found
			
			8'h5c: begin
							m2 <= 1'b1;
							if(bc==0)
									even_odd <= 2'b00;
							else;
					 end
			8'h5d: m2 <= 1;
			8'h5e: m2 <= 1;
			8'h5f: bc <= bc + 1;
			8'h60: m2 <= 1;
			8'h61: m2 <= 1;
			8'h62: m2 <= 1;
			8'h63: begin
							m2 <= 1;
							if(block == 0)						//Read HEADER --> 3 bytes
							begin
									even_odd <= 2'b00;
									if(bc==1)
											header[0] <= rcvb2;
									else if(bc==2)
											header[1] <= rcvb2;
									else if(bc==3)
											header[2] <= rcvb2;
									else;
							end
							
							else
							begin
									if((pixel_mode==2'b10) || (pixel_mode==2'b01))				//8-bit gray-scale OR 1-bit
									begin
											if(bc[4:0]==0)
											begin
													if(bc[5]==1'b1)
													begin
															cache0[31] <= {8'h00, rcvb2};
															even_odd <= 2'b01;
													end
													else
													begin
															cache1[31] <= {8'h00, rcvb2};
															even_odd <= 2'b10;
													end
											end
											else
											begin
													if(bc[5]==0)
														cache0[bc[4:0]-1] <= {8'h00, rcvb2};
													else
														cache1[bc[4:0]-1] <= {8'h00, rcvb2};
											end
									end
									
									else if(pixel_mode==2'b11)				//16-bit color
									begin
											if(bc[5:0]==0)
											begin
													if(bc[6]==1'b1)
													begin
															cache0[31] <= (cache0[31] & 16'hff00) + rcvb2;
															even_odd <= 2'b01;
													end
													else
													begin
															cache1[31] <= (cache1[31] & 16'hff00) + rcvb2;
															even_odd <= 2'b10;
													end
											end
											else if(bc[0]==1'b1)
											begin
													if(bc[6]==0)
															cache0[bc[5:1]] <= rcvb2 << 8;
													else
															cache1[bc[5:1]] <= rcvb2 << 8;
											end
											else		//bc[0]==0
											begin
													if(bc[6]==0)
															cache0[bc[5:1]-1] <= (cache0[bc[5:1]-1] & 16'hff00) + rcvb2;
													else
															cache1[bc[5:1]-1] <= (cache1[bc[5:1]-1] & 16'hff00) + rcvb2;
											end
									end
									
									else									//1-bit 0x00 or 0xFF
											;	//To to continued ...
							end
					 end
			
			//2 bits CRC
			8'h64: m2 <= 1'b1;
			8'h65: m2 <= 1'b1;
			
			//delay at the beginning to let the clock become stable
			8'h66: m2 <= 1'b1;
			8'h67: delay <= delay + 1;
			8'h68: m2 <= 1'b1;
			8'h69: m2 <= 1'b1;
			8'h6a: m2 <= 1'b1;
			
		endcase
end
/*****/
/******************
OUTPUT DATA
******************/
/*fifo_block_read	FIFO_8x512(
								  .rst				(0),
								  .wr_clk			(WR_CLK),
								  .rd_clk			(cryst),
								  .din				(recev_byte),
								  .wr_en				(WR_EN),
								  .rd_en				(RD_EN && wr_avl),
								  .dout				(data),
								  .full				(),
								  .empty				(empty),
								  .rd_data_count	(rd_index),
								  .wr_data_count	(wr_index)
);*/


always@(posedge cryst)
begin
				case(stt)
					0: begin
								WR_CLK <= 0;
								RD_EN <= 0;
								idx <= 0;
						end
					/*OUTPUT*/
					1: begin
								RD_EN <= 1;
									
								if(even_odd==2'b01)
									data <= cache0[idx];
								else
									data <= cache1[idx];
						end
					2: WR_CLK <= 1'b1;
					3: begin
								if(idx < 32)
									idx <= idx + 1;
								else
									idx <= 32;
						end
					4: WR_CLK <= 0;
					default: WR_CLK <= 0;
				endcase		
end

always@(posedge cryst)
begin
		case(stt)
			0: begin
						if(even_odd==0)
							stt <= 0;
						else
						begin
								if((even_odd != flip) /*&& (wr_avl==1'b1)*/)
								begin
										stt <= 1;
										rw_sync <= 1'b1;
								end
								else
									stt <= 0;
						end
				end
			1: stt <= 2;
			2:	stt <= 3;
			3: stt <= 4;
			4: begin
					if(idx < 32)
							stt <= 1;
					else
					begin
							stt <= 0;
							rw_sync <= 0;
							flip <= even_odd;
					end
				end
			default: stt <= 0;
		endcase
end
assign wr_clk = WR_CLK;
/******************************************************
**Delay 74 clock
*/
always@(negedge clk_400K)
begin
		if(dctr < 8'h64)
		begin
			dctr <= dctr + 1;
			reset <= 0;
		end
		else if((dctr >= 100) && (dctr < 102))
		begin
			dctr <= 8'h70;
			reset <= 1;
		end
		else
			reset <= 0;
end
endmodule
