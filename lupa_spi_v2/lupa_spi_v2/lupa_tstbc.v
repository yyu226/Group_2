`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:05:16 01/15/2016
// Design Name:   spi_upload
// Module Name:   C:/Users/yingyu/Desktop/LUPA_ISE/lupa_spi/lupa_spi/lupa_tstbc.v
// Project Name:  lupa_spi
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: spi_upload
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module lupa_tstbc;

	// Inputs
	reg clock_40;
	reg start;
	reg [3:0] nrg;

	// Outputs
	wire spi_clk;
	wire spi_en;
	wire spi_dat;

	// Instantiate the Unit Under Test (UUT)
	lupa_spi_v2 uut (
		.clock_40(clock_40), 
		.start(start), 
		.nrg(nrg), 
		.spi_clk(spi_clk), 
		.spi_en(spi_en), 
		.spi_dat(spi_dat),
		.cfg_DONE(cfg_DONE)
	);

	initial begin
		// Initialize Inputs
		clock_40 = 0;
		start = 0;
		nrg = 4'b1000;

		// Wait 100 ns for global reset to finish
		#200;
        
		// Add stimulus here
		start = 1;
	end
    
	always
		#20 clock_40 = ~clock_40;
endmodule

