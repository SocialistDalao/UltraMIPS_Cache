//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  div
// File:    div.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: ????ģ??
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module div(

	input clk,
	input rst,
	
	input signed_div_i,
	input[`RegBus] opdata1_i,
	input[`RegBus] opdata2_i,
	input start_i,
	input annul_i,
	
	output reg[`DoubleRegBus] result_o,
	output reg ready_o
);

	wire[32:0] div_temp;
	reg[5:0] cnt;
	reg[64:0] dividend;
	reg[1:0] state;
	reg[31:0] divisor;
	
	assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			state <= `DivFree;
			ready_o <= `DivResultNotReady;
			result_o <= {`ZeroWord,`ZeroWord};
		end else begin
		    case (state)
		  	`DivFree:			begin               //DivFree״̬
		  		if(start_i == `DivStart && annul_i == 1'b0) begin
		  			if(opdata2_i == `ZeroWord) begin
		  				state <= `DivByZero;
		  			end else begin
		  				state <= `DivOn;
		  				cnt <= 6'b000000;
		  				dividend <= {`ZeroWord,`ZeroWord};
		  				if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1 ) begin
		  					dividend[32:1] <= ~opdata1_i + 1;
		  				end else begin
		  					dividend[32:1] <= opdata1_i;
		  				end
		  				if(signed_div_i == 1'b1 && opdata2_i[31] == 1'b1 ) begin
		  					divisor <= ~opdata2_i + 1;
		  				end else begin
		  					divisor <= opdata2_i;
		  				end
                     end
                 end else begin
				     ready_o <= `DivResultNotReady;
					 result_o <= {`ZeroWord,`ZeroWord};
				 end          	
		  	 end
		  	`DivByZero:		begin               //DivByZero״̬
         	dividend <= {`ZeroWord,`ZeroWord};
            state <= `DivEnd;		 		
		  	end
		  	`DivOn:				begin               //DivOn״̬
		  		if(annul_i == 1'b0) begin
		  			if(cnt != 6'b100000) begin
                        if(div_temp[32] == 1'b1) begin
                            dividend <= {dividend[63:0] , 1'b0};
                        end else begin
                            dividend <= {div_temp[31:0] , dividend[31:0] , 1'b1};
                        end
                    cnt <= cnt + 1;
                    end else begin
                        if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ opdata2_i[31]) == 1'b1)) begin
                            dividend[31:0] <= (~dividend[31:0] + 1);
                        end
                        if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ dividend[64]) == 1'b1)) begin              
                            dividend[64:33] <= (~dividend[64:33] + 1);
                        end
                    state <= `DivEnd;
                    cnt <= 6'b000000;            	
                end
		    end else begin
		  		state <= `DivFree;
		  	end	
		  	end
		  	`DivEnd:			begin               //DivEnd״̬
        	result_o <= {dividend[64:33], dividend[31:0]};  
          ready_o <= `DivResultReady;
          if(start_i == `DivStop) begin
          	state <= `DivFree;
						ready_o <= `DivResultNotReady;
						result_o <= {`ZeroWord,`ZeroWord};       	
          end		  	
		  	end
		  endcase
		end
	end

endmodule