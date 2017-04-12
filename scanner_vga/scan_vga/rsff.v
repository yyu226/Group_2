module rsff(fclk, fclr, r, s,
            q);
		input fclk, fclr, r, s;
		output reg q;
		
		always@(posedge fclk)
			begin
				if(fclr == 1'b1)
					q <= 1'b0;
				else
					begin
						if(r == 0 && s == 0)
							q <= q;
						else if(r == 1 && s == 0)
							q <= 1'b0;
						else if(r == 0 && s == 1)
							q <= 1'b1;
						else
							q <= 1'bx;
					end
			end
endmodule
