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
// Module:  ex_mem
// File:    ex_mem.v
// Author:
// E-mail:
// Description: EX/MEM阶段的寄存器
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module ex_mem(

	input clk,
	input rst,
	input flush,
	input flush_cause,
	input[5:0] stall,
	
	//来自执行阶段的信息	
	input[`RegAddrBus] waddr1_i,
	input[`RegAddrBus] waddr2_i,
    input              we1_i,
    input              we2_i,
    input[`RegBus]     wdata1_i,
    input[`RegBus]     wdata2_i,
    input[`RegBus]     hi_i,
	input[`RegBus]     lo_i,
	input              whilo_i,
	input[`AluOpBus]   aluop1_i,
	input[`RegBus]     mem_addr_i,
	input[`RegBus]     reg2_i,
	input              cp0_we_i,
	input[`RegAddrBus] cp0_waddr_i,
	input[`RegBus]     cp0_wdata_i,
	input              is_in_delayslot1_i,
	input              is_in_delayslot2_i,
	input[31:0]        exception_type1_i,
	input[31:0]        exception_type2_i,
	input[`InstAddrBus]pc_i,
	
	//送到访存阶段的信息
	output reg[`RegAddrBus] waddr1_o,
	output reg[`RegAddrBus] waddr2_o,
    output reg              we1_o,
    output reg              we2_o,
    output reg[`RegBus]     wdata1_o,
    output reg[`RegBus]     wdata2_o,
    output reg[`RegBus]     hi_o,
	output reg[`RegBus]     lo_o,
	output reg              whilo_o,
	output reg[`AluOpBus]   aluop1_o,
	output reg[`RegBus]     mem_addr_o,
	output reg[`RegBus]     reg2_o,
	output reg              cp0_we_o,
	output reg[`RegAddrBus] cp0_waddr_o,
	output reg[`RegBus]     cp0_wdata_o,
	output reg              is_in_delayslot1_o,
	output reg              is_in_delayslot2_o,
	output reg[31:0]        exception_type1_o,
	output reg[31:0]        exception_type2_o,
	output reg[`InstAddrBus]pc_o
	
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            waddr1_o <= `NOPRegAddr;
            waddr2_o <= `NOPRegAddr;
            we1_o <= `WriteDisable;
            we2_o <= `WriteDisable;
            wdata1_o <= `ZeroWord;
            wdata2_o <= `ZeroWord;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            whilo_o <= `WriteDisable;
            aluop1_o <= `EXE_NOP_OP;
            mem_addr_o <= `ZeroWord;
            reg2_o <= `ZeroWord;
            cp0_we_o <= `WriteDisable;
            cp0_waddr_o <= 5'b00000;
            cp0_wdata_o <= `ZeroWord;
            is_in_delayslot1_o <= `NotInDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            exception_type1_o <= `ZeroWord;
            exception_type2_o <= `ZeroWord;
            pc_o <= `ZeroWord;
        end else if (flush == `Flush && flush_cause == `Exception) begin
            waddr1_o <= `NOPRegAddr;
            waddr2_o <= `NOPRegAddr;
            we1_o <= `WriteDisable;
            we2_o <= `WriteDisable;
            wdata1_o <= `ZeroWord;
            wdata2_o <= `ZeroWord;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            whilo_o <= `WriteDisable;
            aluop1_o <= `EXE_NOP_OP;
            mem_addr_o <= `ZeroWord;
            reg2_o <= `ZeroWord;
            cp0_we_o <= `WriteDisable;
            cp0_waddr_o <= 5'b00000;
            cp0_wdata_o <= `ZeroWord;
            is_in_delayslot1_o <= `NotInDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            exception_type1_o <= `ZeroWord;
            exception_type2_o <= `ZeroWord;
            pc_o <= `ZeroWord;
        end else if (stall[3] == `Stop && stall[4] == `NoStop) begin
            waddr1_o <= `NOPRegAddr;
            waddr2_o <= `NOPRegAddr;
            we1_o <= `WriteDisable;
            we2_o <= `WriteDisable;
            wdata1_o <= `ZeroWord;
            wdata2_o <= `ZeroWord;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            whilo_o <= `WriteDisable;
            aluop1_o <= `EXE_NOP_OP;
            mem_addr_o <= `ZeroWord;
            reg2_o <= `ZeroWord;
            cp0_we_o <= `WriteDisable;
            cp0_waddr_o <= 5'b00000;
            cp0_wdata_o <= `ZeroWord;
            is_in_delayslot1_o <= `NotInDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            exception_type1_o <= `ZeroWord;
            exception_type2_o <= `ZeroWord;
            pc_o <= `ZeroWord;
        end else if (stall[3] == `NoStop) begin
            waddr1_o <= waddr1_i;
            waddr2_o <= waddr2_i;
            we1_o <= we1_i;
            we2_o <= we2_i;
            wdata1_o <= wdata1_i;
            wdata2_o <= wdata2_i;
            hi_o <= hi_i;
            lo_o <= lo_i;
            whilo_o <= whilo_i;
            aluop1_o <= aluop1_i;
            mem_addr_o <= mem_addr_i;
            reg2_o <= reg2_i;
            cp0_we_o <= cp0_we_i;
            cp0_waddr_o <= cp0_waddr_i;
            cp0_wdata_o <= cp0_wdata_i;
            is_in_delayslot1_o <= is_in_delayslot1_i;
            is_in_delayslot2_o <= is_in_delayslot2_i;
            exception_type1_o <= exception_type1_i;
            exception_type2_o <= exception_type2_i;
            pc_o <= pc_i;
        end
    end

endmodule