`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:41:50 08/04/2016 
// Design Name: 
// Module Name:    lupa_spi_v2 
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
module lupa_spi_v2(
				clock_40,
				start,
				nrg,

				spi_clk,
				spi_en,
				spi_dat,
				
				cfg_DONE
    );
	 
input clock_40;				//20Mhz
input start;					//Trigger start
input [3:0] nrg;

output reg spi_clk;
output reg spi_en;
output reg spi_dat;
output reg cfg_DONE;

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
		dat  <= 12'h000;								//default value at 0000, 12'h029
		cfg_DONE <= 0;
end


always@(negedge clock_40)
		state <= next;
		
always@(state)
begin
		case (state)
			0: begin
					spi_en  <= 1;
					spi_clk <= 0;
					spi_dat <= 0;
				end
			
			1: spi_en <= 0;
			
			2: spi_dat <= addr[3];
			3: spi_clk <= 1;
			4: begin
					spi_clk <= 0;
					spi_dat <= addr[2];
				end
			5: spi_clk <= 1;
			6: begin
					spi_clk <= 0;
					spi_dat <= addr[1];
				end
			7: spi_clk <= 1;
			8: begin
					spi_clk <= 0;
					spi_dat <= addr[0];
				end
			9: spi_clk <= 1;
			
		  10: begin
					spi_clk <= 0;
					spi_dat <= dat[11];
				end
		  11: spi_clk <= 1;
		  12: begin
					spi_clk <= 0;
					spi_dat <= dat[10];
				end
		  13: spi_clk <= 1;
		  14: begin
					spi_clk <= 0;
					spi_dat <= dat[9];
				end
		  15: spi_clk <= 1;
		  16: begin
					spi_clk <= 0;
					spi_dat <= dat[8];
				end
		  17: spi_clk <= 1;
		  18: begin
					spi_clk <= 0;
					spi_dat <= dat[7];
				end
		  19: spi_clk <= 1;
		  20: begin
					spi_clk <= 0;
					spi_dat <= dat[6];
				end
		  21: spi_clk <= 1;
		  22: begin
					spi_clk <= 0;
					spi_dat <= dat[5];
				end
		  23: spi_clk <= 1;
		  24: begin
					spi_clk <= 0;
					spi_dat <= dat[4];
				end
		  25: spi_clk <= 1;
		  26: begin
					spi_clk <= 0;
					spi_dat <= dat[3];
				end
		  27: spi_clk <= 1;
		  28: begin
					spi_clk <= 0;
					spi_dat <= dat[2];
				end
		  29: spi_clk <= 1;
		  30: begin
					spi_clk <= 0;
					spi_dat <= dat[1];
				end
		  31: spi_clk <= 1;
		  32: begin
					spi_clk <= 0;
					spi_dat <= dat[0];
				end
		  33: spi_clk <= 1;
		  
		  34: begin
					spi_clk <= 0;
					spi_en <= 1;
					nrc <= nrc + 1;
				end
		
		  
		  35: begin
					spi_en  <= 1;
					spi_clk <= 0;
				end
		  endcase
end

always@(posedge clock_40 /*or posedge start*/)
begin
		if(!start)
			next <= 0;
		else
		begin
				case (state)
					0: next <= 1;
					
					1: next <= 2;
				  35: begin
								if(nrc==nrg)
								begin
										next <= 35;
										cfg_DONE <= 1;
								end
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
										  12: begin addr <= 4'b1100; dat <= 12'hfb0; end            //begin addr <= 4'b1100; dat <= 12'hff0; end				//12'hfb0
										  13: begin addr <= 4'b1101; dat <= 12'hadf; end
										  14: begin addr <= 4'b1110; dat <= 12'h6db; end
										  15: begin addr <= 4'b1111; dat <= 12'h0db; end
										  default: begin addr <= 4'b1111; dat <= 12'h0db; end
										endcase
								end
						end
				  default: next <= next + 1;
				endcase
		end
end

endmodule
