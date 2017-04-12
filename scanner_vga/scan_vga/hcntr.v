module Hcounter(clkh, clrh, hd, hde, hdeb, hdebc,
                roll, cntrh);

		input clkh, clrh;
		output reg hd, hde, hdeb, hdebc;
		output roll;
		output reg [9:0] cntrh;
		
		initial cntrh = 0;
		
		always@(posedge clkh)
			begin
				if(clrh == 1'b1)
					cntrh <= 0;
				else
					begin
						if(cntrh == 799)
							cntrh <= 0;
					else
						cntrh <= cntrh + 1;
					end
			end
			
		always@(posedge clkh)//(cntrh)
			begin
				if(cntrh == 45)		//0
					begin
						hde <= 1'b0;		hdeb <= 1'b0;
						hd <= 1'b0; 		hdebc <= 1'b1;
					end
				else if(cntrh == 685)		//640
					begin
						hd <= 1'b1;			hdebc <= 1'b0;
					end
				else if(cntrh == 701)		//656
					hde <= 1'b1;
				else if(cntrh == 796)		//752
					begin
						hde <= 1'b0;		hdeb <= 1'b1;
					end
				else
					begin
						hde <= hde;			hdeb <= hdeb;
						hd <= hd;			hdebc <= hdebc;
					end
			end
			
		assign roll = hdebc;
		
endmodule
