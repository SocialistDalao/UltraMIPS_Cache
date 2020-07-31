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
// Module:  regfile
// File:    regfile.v
// Author:
// E-mail:
// Description: 寄存器堆，可以同时读取四个寄存器并写入两个寄存器
// Revision: 1.1
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module regfile(

	input clk,
	input rst,
	
	//写端口1
	input                 we1,
	input[`RegAddrBus]    waddr1,
	input[`RegBus]        wdata1,
	
	//写端口2
	input                 we2,
	input[`RegAddrBus]    waddr2,
	input[`RegBus]        wdata2,
	
	//读端口1
	input                  re1,
	input[`RegAddrBus]     raddr1,
	output reg[`RegBus]    rdata1,
	
	//读端口2
	input                  re2,
	input[`RegAddrBus]     raddr2,
	output reg[`RegBus]    rdata2,
	
	//读端口3
	input wire                 re3,
	input wire[`RegAddrBus]    raddr3,
	output reg[`RegBus]        rdata3,
	
	//读端口4
	input wire                 re4,
	input wire[`RegAddrBus]    raddr4,
	output reg[`RegBus]        rdata4
	
);

    reg[`RegBus]  regs[0:`RegNum-1];

    always @ (posedge clk) begin
        if (rst == `RstDisable) begin
            case ({we2, we1})
			 {`WriteDisable, `WriteEnable}: if (waddr1 != `NOPRegAddr) regs[waddr1] <= wdata1;
			 {`WriteEnable, `WriteDisable}: if (waddr2 != `NOPRegAddr) regs[waddr2] <= wdata2;
			 {`WriteEnable, `WriteEnable}: begin
			     if (waddr2 != `NOPRegAddr) regs[waddr2] <= wdata2;
			     if (waddr1 != waddr2 && waddr1 != `NOPRegAddr) begin // 没有发生“写后写”（WAW）相关
			         regs[waddr1] <= wdata1;
			     end
			 end
			 default: ;
            endcase
        end
    end
	
    always @ (*) begin
        if (rst == `RstEnable) begin
            rdata1 = `ZeroWord;
        end else if (raddr1 == `RegNumLog2'h0) begin
            rdata1 = `ZeroWord;
        end else if (re1 == `ReadEnable) begin
            case ({we2, we1})
			 2'b01: rdata1 = (raddr1 == waddr1) ? wdata1 : regs[raddr1];
			 2'b10: rdata1 = (raddr1 == waddr2) ? wdata2 : regs[raddr1];
			 2'b11: begin
			     if (raddr1 == waddr2) rdata1 = wdata2;
			     else if (raddr1 == waddr1) rdata1 = wdata1;
			     else rdata1 = regs[raddr1];
			 end
			 default: rdata1 = regs[raddr1];
            endcase
        end else begin
            rdata1 = `ZeroWord;
        end
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            rdata2 = `ZeroWord;
        end else if (raddr2 == `RegNumLog2'h0) begin
            rdata2 = `ZeroWord;
        end else if (re2 == `ReadEnable) begin
            case ({we2, we1})
			 2'b01: rdata2 = (raddr2 == waddr1) ? wdata1 : regs[raddr2];
			 2'b10: rdata2 = (raddr2 == waddr2) ? wdata2 : regs[raddr2];
			 2'b11: begin
			     if (raddr2 == waddr2) rdata2 = wdata2;
			     else if (raddr2 == waddr1) rdata2 = wdata1;
			     else rdata2 = regs[raddr2];
			 end
			 default: rdata2 = regs[raddr2];
            endcase
        end else begin
            rdata2 = `ZeroWord;
        end
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            rdata3 = `ZeroWord;
        end else if (raddr3 == `RegNumLog2'h0) begin
            rdata3 = `ZeroWord;
        end else if (re3 == `ReadEnable) begin
            case ({we2, we1})
			 2'b01: rdata3 = (raddr3 == waddr1) ? wdata1 : regs[raddr3];
			 2'b10: rdata3 = (raddr3 == waddr2) ? wdata2 : regs[raddr3];
			 2'b11: begin
			     if (raddr3 == waddr2) rdata3 = wdata2;
			     else if (raddr3 == waddr1) rdata3 = wdata1;
			     else rdata3 = regs[raddr3];
			 end
			 default: rdata3 = regs[raddr3];
            endcase
        end else begin
            rdata3 = `ZeroWord;
        end
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            rdata4 = `ZeroWord;
        end else if (raddr4 == `RegNumLog2'h0) begin
            rdata4 = `ZeroWord;
        end else if (re4 == `ReadEnable) begin
            case ({we2, we1})
			 2'b01: rdata4 = (raddr4 == waddr1) ? wdata1 : regs[raddr4];
			 2'b10: rdata4 = (raddr4 == waddr2) ? wdata2 : regs[raddr4];
			 2'b11: begin
			     if (raddr4 == waddr2) rdata4 = wdata2;
			     else if (raddr4 == waddr1) rdata4 = wdata1;
			     else rdata4 = regs[raddr4];
			 end
			 default: rdata4 = regs[raddr4];
            endcase
        end else begin
            rdata4 = `ZeroWord;
        end
    end

endmodule