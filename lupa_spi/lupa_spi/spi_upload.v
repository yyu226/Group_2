`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:15:32 01/15/2016 
// Design Name: 
// Module Name:    spi_upload 
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
module spi_upload(
		clock_20,
		start,
		nrg,

		spi_clk,
		spi_en,
	   spi_dat
    );

input clock_20;				//20Mhz
input start;					//Trigger start
input [3:0] nrg;

output spi_clk;
output reg spi_en;
output reg spi_dat;

/****************** Reg List *******************/
reg [5:0] state, next;
reg [3:0] addr;
reg [11:0] dat;
reg [3:0] nrc;					//number of regs have been configured
//***************** Logic Description ***********
initial
begin
		state <= 0;
		next  <= 0;
		nrc <= 0;
		
		addr <= 4'b0000;
		dat  <= 12'h029;
end

assign spi_clk = clock_20;

always@(negedge clock_20)
		state <= next;
		
always@(state)
begin
		case (state)
			0: spi_en <= 1;
			
			1: begin
					spi_en <= 0;						//Select the bus
					spi_dat <= addr[3];
				end
			2: spi_dat <= addr[2];
			3: spi_dat <= addr[1];
			4: spi_dat <= addr[0];
			
			5: spi_dat <= dat[11];
			6: spi_dat <= dat[10];
			7: spi_dat <= dat[9];
			8: spi_dat <= dat[8];
			9: spi_dat <= dat[7];
		  10: spi_dat <= dat[6];
		  11: spi_dat <= dat[5];
		  12: spi_dat <= dat[4];
		  13: spi_dat <= dat[3];
		  14: spi_dat <= dat[2];
		  15: spi_dat <= dat[1];
		  16: begin
					spi_dat <= dat[0];
					nrc <= nrc + 1;
				end
		  
		  17: spi_en <= 1;				//Deselect the bus
		  endcase
end

always@(posedge clock_20 or posedge start)
begin
		if(!start)
			next <= 0;
		else
		begin
				case (state)
					0: next <= 1;
					
					1: next <= 2;
				  17: begin
								if(nrc==nrg)
										next <= 17;
								else
								begin
										next <= 0;
										case (nrc)
											1: begin addr <= 4'b0001; dat <= 12'h000; end
											2: begin addr <= 4'b0010; dat <= 12'h000; end
											3: begin addr <= 4'b0011; dat <= 12'h0a0; end
											4: begin addr <= 4'b0100; dat <= 12'h002; end
											5: begin addr <= 4'b0101; dat <= 12'h000; end
											6: begin addr <= 4'b0110; dat <= 12'h000; end
											7: begin addr <= 4'b0111; dat <= 12'h1e1; end
											8: begin addr <= 4'b1000; dat <= 12'h04a; end
											9: begin addr <= 4'b1001; dat <= 12'h06b; end
										  10: begin addr <= 4'b1010; dat <= 12'h055; end
										  11: begin addr <= 4'b1011; dat <= 12'h0f0; end
										  12: begin addr <= 4'b1100; dat <= 12'hff0; end				//12'hfb0
										  13: begin addr <= 4'b1101; dat <= 12'hadf; end
										  14: begin addr <= 4'b1110; dat <= 12'h6db; end
										  15: begin addr <= 4'b1111; dat <= 12'h0db; end
											default: begin addr <= 4'b1111; dat <= 12'habc; end
										endcase
								end
						end
				  default: next <= next + 1;
				endcase
		end
end

endmodule
