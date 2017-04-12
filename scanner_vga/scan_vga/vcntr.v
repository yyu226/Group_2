module Vcounter(clkv, clrv, vr, vrs, vrsp, 
               vrspq, cntrv);
					
		input clkv, clrv;
		output reg vr, vrs, vrsp, vrspq;
		output reg [9:0] cntrv;
		
		initial cntrv = 0;
		
		always@(posedge clkv)
			begin
				if(clrv == 1'b1)
					cntrv = 0;
				else
					begin
						if(cntrv == 524)
							cntrv = 0;
						else
							cntrv = cntrv + 1;
					end
			end
			
		always@(posedge clkv)//(cntrv)
			begin
				if(cntrv == 32)
					begin
						vrs <= 1'b0;		vrsp <= 1'b0;
						vr <= 1'b0;		vrspq <= 1'b1;
					end
				else if(cntrv == 512)		//480
					begin
						vr <= 1'b1;		vrspq <= 1'b0;
					end
				else if(cntrv == 522)		//490
					vrs <= 1'b1;
				else if(cntrv == 524)		//492
					begin
						vrs <= 1'b0;		vrsp <= 1'b1;
					end
				else
					begin
						vrs <= vrs;		vrsp <= vrsp;
						//vr <= vr;		vrspq <= vrspq;
					end
			end
		
endmodule
