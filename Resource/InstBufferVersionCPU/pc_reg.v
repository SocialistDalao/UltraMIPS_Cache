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
// Module:  pc_reg
// File:    pc_reg.v
// Author:
// E-mail:
// Description: 程序计数器PC
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module pc_reg(

	input clk,
	input resetn,
    input[4:0] stall,
    input flush,
    input flush_cause,
    
    input               stallreq_from_icache,
    input               branch_flag, // 静态分支预测时暂不需要这个信号，但为了接上分支预测后方便，保留
    input[`InstAddrBus] npc_actual,
    // input               ex_issue_mode,
	input[`InstAddrBus] epc,
	input               ibuffer_full,
	
	output reg[`InstAddrBus] pc,
	output reg rreq_to_icache
	
);
    
    reg[`InstAddrBus] npc;
    
    always @ (*) begin
        if (resetn == `RstEnable) npc = `Entry;
        else if (flush == `Flush && flush_cause == `Exception) npc = epc;
        else if (flush == `Flush && flush_cause == `FailedBranchPrediction) npc = npc_actual; // 目前是静态预测，全部预测不跳转，所以预测失败肯定是要跳转的
        else if (stallreq_from_icache == `Stop) npc = pc;
        else if (ibuffer_full) npc = pc;
        else if (pc[4:2] == 3'b111) npc = pc + 4'h4; // ICache边界
        else npc = pc + 4'h8;
    end
    
    always @ (*) begin
        if (resetn == `RstEnable || flush == `Flush || ibuffer_full) rreq_to_icache = `ReadDisable;
        else rreq_to_icache = `ReadEnable;
    end
    
    always @ (posedge clk) pc <= npc;

endmodule