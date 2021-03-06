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
// Module:  ctrl
// File:    ctrl.v
// Author:
// E-mail:
// Description: ????????????????????????????????????
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module ctrl(
	input resetn,
	input stallreq_from_ex,
	input stallreq_from_id,
	input stallreq_from_dcache,
	input pred_flag,
	input exception_flag,
	input[4:0] exception_type,
	input[`InstAddrBus] cp0_epc_i,
	input[`InstAddrBus] ebase_i,
	
	output reg[3:0]          stall,
	output reg               flush,
	output reg               flush_cause,
	output reg[`InstAddrBus] epc_o,
	
	output flush_to_ibuffer

);
    
    assign flush_to_ibuffer = resetn == `RstEnable || flush == `Flush ? `Flush : `NoFlush;
    
    always @ (*) begin
        if (resetn == `RstEnable) begin
            stall = 4'b0000;
            flush = `NoFlush;
            flush_cause = `Exception;
            epc_o = `ZeroWord;
        end else if (exception_flag == `ExceptionInduced) begin
            stall = 4'b0000;
	        flush = `Flush;
	        flush_cause = `Exception;
	        case (exception_type)
	        `EXCEPTION_INT, `EXCEPTION_ADEL, `EXCEPTION_ADES, `EXCEPTION_SYS,
	        `EXCEPTION_BP, `EXCEPTION_RI, `EXCEPTION_OV, `EXCEPTION_TR: epc_o = ebase_i;
	        `EXCEPTION_ERET: epc_o = cp0_epc_i;
	        default: epc_o = `ZeroWord;
	        endcase
        end else if (stallreq_from_dcache == `Stop) begin
            stall = 4'b0111;
            flush = `NoFlush;
            flush_cause = `Exception;
            epc_o = `ZeroWord;
        end else if (pred_flag == `InvalidPrediction) begin
            stall = 4'b0000;
            flush = `Flush;
            flush_cause = `FailedBranchPrediction;
            epc_o = `ZeroWord;
        end else if (stallreq_from_ex == `Stop) begin
            stall = 4'b0011;
            flush = `NoFlush;
            flush_cause = `Exception;
            epc_o = `ZeroWord;
        end else if (stallreq_from_id == `Stop) begin
            stall = 4'b0001;
            flush = `NoFlush;
            flush_cause = `Exception;
            epc_o = `ZeroWord;
        end else begin
            stall = 4'b0000;
            flush = `NoFlush;
            flush_cause = `Exception;
            epc_o = `ZeroWord;
        end
    end

endmodule