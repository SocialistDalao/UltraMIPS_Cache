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
// Description: ³ÌÐò¼ÆÊýÆ÷PC
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
    input               branch_flag,
    input[`InstAddrBus] npc_actual,
    input[`InstAddrBus] ex_pc,
    input[`InstAddrBus] npc_from_cache,
	input[`InstAddrBus] epc,
	input               ibuffer_full,
	
	output reg[`InstAddrBus] pc,
	output reg rreq_to_icache
	
);
    
    reg[`InstAddrBus] npc;
    
    always @ (*) begin
        if (resetn == `RstEnable) npc = `Entry;
        else if (flush == `Flush && flush_cause == `Exception) npc = epc;
        else if (flush == `Flush && flush_cause == `FailedBranchPrediction && branch_flag == `Branch) npc = npc_actual;
        else if (flush == `Flush && flush_cause == `FailedBranchPrediction && branch_flag == `NotBranch) npc = ex_pc + 32'h8;
        else if (ibuffer_full) npc = pc;
        else npc = npc_from_cache;
    end
    
    always @ (*) begin
        if (resetn == `RstEnable || flush == `Flush || ibuffer_full) rreq_to_icache = `ReadDisable;
        else rreq_to_icache = `ReadEnable;
    end
    
    always @ (posedge clk) pc <= npc;
    
    
    //////////////////////////
    reg [31:0] branch_count;
    reg [31:0] hit_count;
    
    always@(posedge clk)begin
        if(resetn == `RstEnable)begin
            branch_count <= 0;
            hit_count<= 0;
        end else begin
            if(branch_flag)begin
                branch_count <= branch_count + 1;
            end 
            if(branch_flag && !(branch_flag & flush & flush_cause))begin
                hit_count <= hit_count + 1;
            end
        end
    end
    /////////////////////////
    
endmodule