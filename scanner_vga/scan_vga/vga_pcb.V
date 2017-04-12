`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:35:06 02/10/2016 
// Design Name: 
// Module Name:    vga_pcb 
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
module	vga_pcb(
						//Image input
						iVGA_R,
						iVGA_G,
						iVGA_B,
						
						//	VGA Side
						oVGA_R,
						oVGA_G,
						oVGA_B,
						oVGA_H_SYNC,
						oVGA_V_SYNC,
						oPSAVE_N,
						oVGA_CLK,
						
						oRequest,
						//	Control Signal
						iCLK25
							);
input  [7:0] iVGA_R, iVGA_G, iVGA_B;
output [7:0] oVGA_R, oVGA_G, oVGA_B;
output oVGA_H_SYNC, oVGA_V_SYNC;
output oPSAVE_N;
output oVGA_CLK;
output reg oRequest;
input iCLK25;
/////////////////////////////////////////////////////
wire reset;
wire d, de, deb, debc, rover;
wire r, rs, rsp, rspq;
wire hon, von;
wire [9:0] coln, rown;

reg [7:0] red, green, blue;
////////////////////////////////////////////////////////
initial
begin
		oRequest <= 0;
end

assign oVGA_CLK = iCLK25;
assign oPSAVE_N = 1'b1;

assign reset = 1'b0;

Hcounter HCM1(iCLK25, reset, d, de, deb, debc, rover, coln);
Vcounter VCM1(rover, reset, r, rs, rsp, rspq, rown);

rsff HSYNC(iCLK25, reset, de, deb, oVGA_H_SYNC);			//D
rsff HDATO(iCLK25, reset, d, debc, hon);						//O
rsff VSYNC(iCLK25, reset, rs, rsp, oVGA_V_SYNC);			//N
rsff VDATO(iCLK25, reset, r, rspq, von);						//E
	
rgboen RED(oVGA_R, hon, von, iVGA_R);
rgboen GREEN(oVGA_G, hon, von, iVGA_G);
rgboen BLUE(oVGA_B, hon, von, iVGA_B);

always@(posedge iCLK25)
begin
		if((rown>32)&&(rown<=512)&&(coln>=48)&&(coln<688))
				oRequest = 1;
		else
				oRequest = 0;
end
/*always@(rown)
begin
	if(rown < 120)
		begin
			red <= 8'hab;
			green <= 8'hcd;
			blue <= 8'hef;
		end
	else if(rown >= 120 && rown < 240)
		begin
			red <= 8'hef;
			green <= 8'hcd;
			blue <= 8'hab;
		end
	else if(rown >= 240 && rown <360)
		begin
			red <= 8'h00;
			green <= 8'h00;
			blue <= 8'hff;
		end
	else
		begin
			red <= 8'hff;
			green <= 8'h00;
			blue <= 8'h00;
		end
end*/
endmodule
