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
// Module:  cp0_reg
// File:    cp0_reg.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description:
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module cp0_reg(

	input clk,
	input resetn,
	
	
	input                  we_i,
	input[`RegAddrBus]     waddr_i,
	input[`RegAddrBus]     raddr_i,
	input[`RegBus]         data_i,
	
    input[4:0]             exception_type_i,
    input                  exception_flag_i,
    input                  exception_first_inst_i,
    input[`RegBus]         mem_addr_i,
    input[`InstAddrBus]    pc_i,
    input                  is_in_delayslot1_i,
	input                  is_in_delayslot2_i,
    input[5:0]             int_i,
	
    output reg[`RegBus]           data_o,
    output reg[`RegBus]           badvaddr_o,
    output reg[`RegBus]           count_o,
    output reg[`RegBus]           compare_o,
    output reg[`RegBus]           status_o,
    output reg[`RegBus]           cause_o,
    output reg[`RegBus]           epc_o,
    output reg[`RegBus]           config_o,
    output reg[`RegBus]           prid_o,	
    output reg                    timer_int_o    
	
);
    reg dclk_count;
    reg[`InstAddrBus] epc_i;
    reg bd; // 是否是延迟槽指令发生异常
    
    always @ (*) begin
        if (exception_first_inst_i == 1'b1 && is_in_delayslot1_i == `InDelaySlot) begin
            epc_i = pc_i - 4'h4;
            bd = 1'b1;
        end else if (exception_first_inst_i == 1'b1 && is_in_delayslot1_i == `NotInDelaySlot) begin
            epc_i = pc_i;
            bd = 1'b0;
        end else if (exception_first_inst_i == 1'b0 && is_in_delayslot2_i == `InDelaySlot) begin
            epc_i = pc_i;
            bd = 1'b1;
        end else begin
            epc_i = pc_i + 4'h4;
            bd = 1'b0;
        end
    end
    
    always @ (posedge clk) begin
        if (resetn == `RstEnable) begin
            badvaddr_o <= `ZeroWord;
            count_o <= `ZeroWord;
            compare_o <= `ZeroWord;
            status_o <= `CP0_REG_STATUS_VAL;
            cause_o <= `ZeroWord;
            epc_o <= `ZeroWord;
            config_o <= `CP0_REG_CONFIG_VAL;
            prid_o <= `CP0_REG_PRID_VAL;
            timer_int_o <= `InterruptNotAssert;
            dclk_count <= 1'b0;
		end else begin
		    dclk_count <= ~dclk_count;
		    if (dclk_count) count_o <= count_o + 1;
            cause_o[15:10] <= int_i;
            cause_o[30] <= timer_int_o;
            
            if (compare_o != `ZeroWord && count_o == compare_o) timer_int_o <= `InterruptAssert;
			
            if (we_i == `WriteEnable) begin
                case (waddr_i)
                `CP0_REG_COUNT: begin
                    dclk_count <= 1'b0;
                    count_o <= data_i;
                end
                `CP0_REG_COMPARE: begin
                    compare_o <= data_i;
                    //count_o <= `ZeroWord;
                    timer_int_o <= `InterruptNotAssert;
                end
                `CP0_REG_STATUS: begin
                    status_o[15:8] <= data_i[15:8];
                    status_o[1:0] <= data_i[1:0];
                end
                `CP0_REG_EPC: begin
                    epc_o <= data_i;
                end
                `CP0_REG_CAUSE:	begin
                    cause_o[9:8] <= data_i[9:8];
                end
                default: ;
                endcase
            end
			if (exception_flag_i == `ExceptionInduced) begin
                case (exception_type_i)
                `EXCEPTION_INT: begin
                    epc_o <= epc_i;
                    cause_o[31] <= bd;
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= exception_type_i;
                end
                `EXCEPTION_ADEL: begin
                    epc_o <= epc_i;
                    cause_o[31] <= bd;
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= exception_type_i;
                    if (pc_i[1:0] != 2'b00) badvaddr_o <= pc_i;
                    else badvaddr_o <= mem_addr_i;
                end
                `EXCEPTION_ADES: begin
                    epc_o <= epc_i;
                    cause_o[31] <= bd;
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= exception_type_i;
                    badvaddr_o <= mem_addr_i;
                end
                `EXCEPTION_SYS: begin
                    epc_o <= epc_i;
                    cause_o[31] <= bd;
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= exception_type_i;
                end
                `EXCEPTION_BP: begin
                    epc_o <= epc_i;
                    cause_o[31] <= bd;
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= exception_type_i;
                end
                `EXCEPTION_RI: begin
                    epc_o <= epc_i;
                    cause_o[31] <= bd;
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= exception_type_i;
                end
                `EXCEPTION_OV: begin
                    epc_o <= epc_i;
                    cause_o[31] <= bd;
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= exception_type_i;
                end
                `EXCEPTION_TR: begin
                    epc_o <= epc_i;
                    cause_o[31] <= bd;
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= exception_type_i;
                end
                `EXCEPTION_ERET: status_o[1] <= 1'b0;
                default: ;
                endcase
            end
        end
    end
			
    always @ (*) begin
        if (resetn == `RstEnable) begin
            data_o = `ZeroWord;
        end else begin
            case (raddr_i) 
            `CP0_REG_BADVADDR: data_o = badvaddr_o;
            `CP0_REG_COUNT: data_o = count_o;
            `CP0_REG_COMPARE: data_o = compare_o;
            `CP0_REG_STATUS:	data_o = status_o;
            `CP0_REG_CAUSE:	data_o = cause_o;
            `CP0_REG_EPC: data_o = epc_o ;
            `CP0_REG_PrId: data_o = prid_o ;
            `CP0_REG_CONFIG: data_o = config_o ;
			default: data_o = `ZeroWord;		
            endcase			
        end
    end

endmodule