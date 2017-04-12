module rgboen(dout, hden, vden,
					din);
		
		input [7:0] din;
		input hden, vden;
		output reg [7:0] dout;
		
		always@(*)
			begin
				if(hden == 1'b1 && vden == 1'b1)
					dout = din;
				else
					dout = 8'b00000000;
			end
		
endmodule
