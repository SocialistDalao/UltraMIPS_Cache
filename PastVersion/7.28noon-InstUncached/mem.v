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
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/24 16:48:43
// Design Name: 
// Module Name: mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module mem(
	
    input rst,
	
	input[`RegBus]         mem_data_i,
	
	//来自执行阶段的信息	
	input[`RegAddrBus]     waddr1_i,
	input[`RegAddrBus]     waddr2_i,
	input                  we1_i,
	input                  we2_i,
	input[`RegBus]         wdata1_i,
	input[`RegBus]         wdata2_i,
	input[`RegBus]         hi_i,
	input[`RegBus]         lo_i,
	input                  whilo_i,
	input[`AluOpBus]       aluop1_i,
	input[`RegBus]         mem_addr_i,
	input[`RegBus]         reg2_i,
	input                  LLbit_i,
	input                  commit_LLbit_i,
	input                  commit_LLbit_we_i,
	input                  cp0_we_i,
	input[`RegAddrBus]     cp0_waddr_i,
	input[`RegBus]         cp0_wdata_i,
	
	input                  is_in_delayslot1_i,
	input                  is_in_delayslot2_i,
	input[31:0]            exception_type1_i,
	input[31:0]            exception_type2_i,
	input[`InstAddrBus]    pc_i,
	input[`RegBus]         cp0_status_i,
	input[`RegBus]         cp0_cause_i,
	input[`RegBus]         cp0_epc_i,
	input                  commit_cp0_we_i,
	input[`RegAddrBus]     commit_cp0_waddr_i,
	input[`RegBus]         commit_cp0_wdata_i,
	
	output reg[`RegBus]        mem_raddr_o,
	output reg[`RegBus]        mem_waddr_o,
	output reg                 mem_we_o,
	output reg[3:0]            mem_sel_o,
	output reg[`RegBus]        mem_data_o,
	output reg                 mem_re_o,
	
	//送到回写阶段的信息
	output reg[`RegAddrBus]    waddr1_o,
	output reg[`RegAddrBus]    waddr2_o,
	output reg                 we1_o,
	output reg                 we2_o,
	output reg[`RegBus]        wdata1_o,
	output reg[`RegBus]        wdata2_o,
	output reg[`RegBus]        hi_o,
	output reg[`RegBus]        lo_o,
	output reg                 whilo_o,
	output reg                 LLbit_o,
	output reg                 LLbit_we_o,
	output reg                 cp0_we_o,
	output reg[`RegAddrBus]    cp0_waddr_o,
	output reg[`RegBus]        cp0_wdata_o,
	output reg[4:0]            exception_type_o,
	output reg                 exception_flag_o,
	output reg                 exception_first_inst_o, // 是否是第二条指令发生异常
	
	output[`RegBus]     mem_addr_o,
	output[`InstAddrBus]pc_o,
	output[`InstAddrBus]cp0_epc_o,
	output              is_in_delayslot1_o,
	output              is_in_delayslot2_o
	

);
    
    reg[`RegBus] cp0_status;
    reg[`RegBus] cp0_cause;
    reg[`RegBus] cp0_epc;
    reg[`RegBus] mem_we;
    wire[31:0] exception_bits1;
    wire[31:0] exception_bits2;
    reg[4:0] exception_type1;
    reg[4:0] exception_type2;
    reg exception_flag1;
    reg exception_flag2;
    reg adel_exception;
    reg ades_exception;
    
    reg LLbit;
    always @ (*) begin
        if (rst == `RstEnable) LLbit = 1'b0;
        else if (commit_LLbit_we_i == `WriteEnable) LLbit = commit_LLbit_i;
        else LLbit = LLbit_i;
    end
    
    assign exception_bits1 = {exception_type1_i[31:6], ades_exception, adel_exception | exception_type1_i[4], exception_type1_i[3:0]};
    assign exception_bits2 = exception_type2_i;
    
    always @ (*) begin
        if (rst == `RstEnable) cp0_status = `CP0_REG_STATUS_VAL;
		else if ((commit_cp0_we_i == `WriteEnable) && (commit_cp0_waddr_i == `CP0_REG_STATUS)) cp0_status = {cp0_status_i[31:16], commit_cp0_wdata_i[15:8], cp0_status_i[7:2], cp0_status_i[1:0]};
		else cp0_status = cp0_status_i;
	end
	
	always @ (*) begin
		if (rst == `RstEnable) cp0_epc = `ZeroWord;
		else if ((commit_cp0_we_i == `WriteEnable) && (commit_cp0_waddr_i == `CP0_REG_EPC )) cp0_epc = commit_cp0_wdata_i;
		else cp0_epc = cp0_epc_i;
	end
	
    always @ (*) begin
        if (rst == `RstEnable) cp0_cause = `ZeroWord;
        else if ((commit_cp0_we_i == `WriteEnable) && (commit_cp0_waddr_i == `CP0_REG_CAUSE)) cp0_cause = {cp0_cause_i[31:10], commit_cp0_wdata_i[9:8], cp0_cause_i[7:0]};
        else cp0_cause = cp0_cause_i;
    end
    
    assign cp0_epc_o = cp0_epc;
    assign is_in_delayslot1_o = is_in_delayslot1_i;
    assign is_in_delayslot2_o = is_in_delayslot2_i;
    assign pc_o = pc_i;
    assign mem_addr_o = mem_addr_i;
    
    always @ (*) mem_we_o = mem_we & ~|exception_type1;
    
    always @ (*) begin
		if (rst == `RstEnable) begin
			exception_type1 = 5'b0;
			exception_flag1 = `ExceptionNotInduced;
		end else begin
			exception_type1 = 5'b0;
			exception_flag1 = `ExceptionNotInduced;
			if (pc_i != `ZeroWord) begin // 流水线当前没有清除或阻塞
				if (((cp0_cause[15:8] & (cp0_status[15:8])) != 8'h00) && (cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1)) begin 
				    exception_type1 = `EXCEPTION_INT;
				    exception_flag1 = `ExceptionInduced;
				end else if (exception_bits1[4] == 1'b1) begin 
				    exception_type1 = `EXCEPTION_ADEL;
				    exception_flag1 = `ExceptionInduced;
				end else if (exception_bits1[5] == 1'b1) begin
				    exception_type1 = `EXCEPTION_ADES;
				    exception_flag1 = `ExceptionInduced;
				end else if (exception_bits1[8] == 1'b1) begin 
				    exception_type1 = `EXCEPTION_SYS;
				    exception_flag1 = `ExceptionInduced;
				end else if (exception_bits1[9] == 1'b1) begin
				    exception_type1 = `EXCEPTION_BP;
				    exception_flag1 = `ExceptionInduced;
				end else if (exception_bits1[10] == 1'b1) begin
				    exception_type1 = `EXCEPTION_RI;
				    exception_flag1 = `ExceptionInduced;
				end else if (exception_bits1[12] == 1'b1) begin
				    exception_type1 = `EXCEPTION_OV;
				    exception_flag1 = `ExceptionInduced;
				end else if (exception_bits1[13] == 1'b1) begin
				    exception_type1 = `EXCEPTION_TR;
				    exception_flag1 = `ExceptionInduced;
				end else if (exception_bits1[14] == 1'b1) begin
				    exception_type1 = `EXCEPTION_ERET;
				    exception_flag1 = `ExceptionInduced;
				end
			end
		end
	end
	
	always @ (*) begin
		if (rst == `RstEnable) begin
			exception_type2 = 5'b0;
			exception_flag2 = `ExceptionNotInduced;
		end else begin
			exception_type2 = 5'b0;
			exception_flag2 = `ExceptionNotInduced;
			if (pc_i != `ZeroWord) begin
				if (((cp0_cause[15:8] & (cp0_status[15:8])) != 8'h00) && (cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1)) begin 
				    exception_type2 = `EXCEPTION_INT;
				    exception_flag2 = `ExceptionInduced;
				end else if (exception_bits2[4] == 1'b1) begin 
				    exception_type2 = `EXCEPTION_ADEL;
				    exception_flag2 = `ExceptionInduced;
				end else if (exception_bits2[5] == 1'b1) begin
				    exception_type2 = `EXCEPTION_ADES;
				    exception_flag2 = `ExceptionInduced;
				end else if (exception_bits2[8] == 1'b1) begin 
				    exception_type2 = `EXCEPTION_SYS;
				    exception_flag2 = `ExceptionInduced;
				end else if (exception_bits2[9] == 1'b1) begin
				    exception_type2 = `EXCEPTION_BP;
				    exception_flag2 = `ExceptionInduced;
				end else if (exception_bits2[10] ==1'b1) begin
				    exception_type2 = `EXCEPTION_RI;
				    exception_flag2 = `ExceptionInduced;
				end else if (exception_bits2[12] == 1'b1) begin
				    exception_type2 = `EXCEPTION_OV;
				    exception_flag2 = `ExceptionInduced;
				end else if (exception_bits2[13] == 1'b1) begin
				    exception_type2 = `EXCEPTION_TR;
				    exception_flag2 = `ExceptionInduced;
				end else if (exception_bits2[14] == 1'b1) begin
				    exception_type2 = `EXCEPTION_ERET;
				    exception_flag2 = `ExceptionInduced;
				end
			end
		end
	end
	
	always @ (*) begin
	    if (exception_flag1 == `ExceptionInduced) begin
	        exception_flag_o = `ExceptionInduced;
	        exception_type_o = exception_type1;
	        exception_first_inst_o = 1'b1;
	    end else if (exception_flag2 == `ExceptionInduced) begin
	        exception_flag_o = `ExceptionInduced;
	        exception_type_o = exception_type2;
	        exception_first_inst_o = 1'b0;
	    end else begin
	        exception_flag_o = `ExceptionNotInduced;
	        exception_type_o = 5'b0;
	        exception_first_inst_o = 1'b0;
	    end
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            waddr1_o = `NOPRegAddr;
            waddr2_o = `NOPRegAddr;
            we1_o = `WriteDisable;
            we2_o = `WriteDisable;
            wdata1_o = `ZeroWord;
            wdata2_o = `ZeroWord;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
            whilo_o = `WriteDisable;
            mem_raddr_o = `ZeroWord;
            mem_waddr_o = `ZeroWord;
            mem_we = `WriteDisable;
            mem_sel_o = 4'b0000;
            mem_data_o = `ZeroWord;
            mem_re_o = `ReadDisable;
            LLbit_o = 1'b0;
            LLbit_we_o = `WriteDisable;
            cp0_we_o = `WriteDisable;
            cp0_waddr_o = 5'b00000;
            cp0_wdata_o = `ZeroWord;
            adel_exception = 1'b0;
            ades_exception = 1'b0;
        end else begin
            waddr1_o = waddr1_i;
            waddr2_o = waddr2_i;
            we1_o = we1_i;
            we2_o = we2_i;
            wdata1_o = wdata1_i;
            wdata2_o = wdata2_i;
            hi_o = hi_i;
            lo_o = lo_i;
            whilo_o = whilo_i;
            mem_raddr_o = `ZeroWord;
            mem_waddr_o = `ZeroWord;
            mem_we = `WriteDisable;
            mem_sel_o = 4'b0000;
            mem_data_o = `ZeroWord;
            mem_re_o = `ReadDisable;
            LLbit_o = 1'b0;
            LLbit_we_o = `WriteDisable;
            cp0_we_o =cp0_we_i;
            cp0_waddr_o = cp0_waddr_i;
            cp0_wdata_o = cp0_wdata_i;
            adel_exception = 1'b0;
            ades_exception = 1'b0;
            case (aluop1_i)
            `EXE_LB_OP: begin
                mem_raddr_o = mem_addr_i;
                mem_we = `WriteDisable;
                mem_re_o = `ReadEnable;
                case (mem_addr_i[1:0])
                    2'b00: wdata1_o = {{24{mem_data_i[7]}}, mem_data_i[7:0]};
                    2'b01: wdata1_o = {{24{mem_data_i[15]}}, mem_data_i[15:8]};
                    2'b10: wdata1_o = {{24{mem_data_i[23]}}, mem_data_i[23:16]};
                    2'b11: wdata1_o = {{24{mem_data_i[31]}}, mem_data_i[31:24]};
                    default: ;
                endcase
            end
            `EXE_LBU_OP: begin
                mem_raddr_o = mem_addr_i;
                mem_we = `WriteDisable;
                mem_re_o = `ReadEnable;
                case (mem_addr_i[1:0])
                    2'b00: wdata1_o = {24'b0, mem_data_i[7:0]};
                    2'b01: wdata1_o = {24'b0, mem_data_i[15:8]};
                    2'b10: wdata1_o = {24'b0, mem_data_i[23:16]};
                    2'b11: wdata1_o = {24'b0, mem_data_i[31:24]};
                    default: ;
                endcase
            end
            `EXE_LH_OP: begin
                mem_raddr_o = mem_addr_i;
                mem_we = `WriteDisable;
                mem_re_o = `ReadEnable;
                case (mem_addr_i[1:0])
                    2'b00: wdata1_o = {{24{mem_data_i[15]}}, mem_data_i[15:0]};
                    2'b10: wdata1_o = {{24{mem_data_i[31]}}, mem_data_i[31:16]};
                    default: begin
                        wdata1_o = `ZeroWord;
                        adel_exception = 1'b1;
                    end
                endcase
            end
            `EXE_LHU_OP: begin
                mem_raddr_o = mem_addr_i;
                mem_we = `WriteDisable;
                mem_re_o = `ReadEnable;
                case (mem_addr_i[1:0])
                    2'b00: wdata1_o = {24'b0, mem_data_i[15:0]};
                    2'b10: wdata1_o = {24'b0, mem_data_i[31:16]};
                    default: begin
                        wdata1_o = `ZeroWord;
                        adel_exception = 1'b1;
                    end
                endcase
            end
            `EXE_LW_OP: begin
                mem_raddr_o = mem_addr_i;
                mem_we = `WriteDisable;
                mem_re_o = `ReadEnable;
                wdata1_o = mem_data_i;
                adel_exception = mem_addr_i[1:0] != 2'b00;
            end
            `EXE_LWL_OP: begin
				mem_raddr_o = {mem_addr_i[31:2], 2'b00};
				mem_we = `WriteDisable;
				mem_re_o = `ReadEnable;
				case (mem_addr_i[1:0])
                    2'b00: wdata1_o = {mem_data_i[7:0], reg2_i[23:0]};
                    2'b01: wdata1_o = {mem_data_i[15:0],reg2_i[15:0]};
                    2'b10: wdata1_o = {mem_data_i[23:0],reg2_i[7:0]};
                    2'b11: wdata1_o = mem_data_i;
                    default: ;
                endcase				
            end
            `EXE_LWR_OP: begin
				mem_raddr_o = {mem_addr_i[31:2], 2'b00};
				mem_we = `WriteDisable;
				mem_re_o = `ReadEnable;
				case (mem_addr_i[1:0])
                    2'b00: wdata1_o = mem_data_i;
                    2'b01: wdata1_o = {reg2_i[31:24], mem_data_i[31:8]};
                    2'b10: wdata1_o = {reg2_i[31:16], mem_data_i[31:16]};
                    2'b11: wdata1_o = {reg2_i[31:8], mem_data_i[31:24]};
                    2'b11: wdata1_o = mem_data_i;
                endcase				
            end
            `EXE_SB_OP: begin
                mem_waddr_o = mem_addr_i;
                mem_we = `WriteEnable;
                mem_data_o = {reg2_i[7:0], reg2_i[7:0], reg2_i[7:0], reg2_i[7:0]};
                case (mem_addr_i[1:0])
                    2'b00: mem_sel_o = 4'b0001;
                    2'b01: mem_sel_o = 4'b0010;
                    2'b10: mem_sel_o = 4'b0100;
                    2'b11: mem_sel_o = 4'b1000;
                    default: ;
                endcase
            end
            `EXE_SH_OP: begin
                mem_waddr_o = mem_addr_i;
                mem_we = `WriteEnable;
                mem_data_o = {reg2_i[15:0], reg2_i[15:0]};
                case (mem_addr_i[1:0])
                    2'b00: mem_sel_o = 4'b0011;
                    2'b10: mem_sel_o = 4'b1100;
                    default: begin
                        mem_sel_o = 4'b0000;
                        ades_exception = 1'b1;
                    end
                endcase
            end
            `EXE_SW_OP: begin
                mem_waddr_o = mem_addr_i;
                mem_we = `WriteEnable;
                mem_data_o = reg2_i[31:0];
                mem_sel_o = 4'b1111;
                ades_exception = mem_addr_i[1:0] != 2'b00;
            end
            `EXE_SWL_OP: begin
				mem_waddr_o = {mem_addr_i[31:2], 2'b00};
				mem_we = `WriteEnable;
				case (mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o = 4'b0001;
                        mem_data_o = {24'b0, reg2_i[31:24]};
                    end
                    2'b01: begin
                        mem_sel_o = 4'b0011;
                        mem_data_o = {16'b0, reg2_i[31:16]};
                    end
                    2'b10: begin
                        mem_sel_o = 4'b0111;
                        mem_data_o = {8'b0, reg2_i[31:8]};
                    end
                    2'b11: begin
                        mem_sel_o = 4'b1111;
                        mem_data_o = reg2_i;
                    end
                    default: ;
                endcase				
            end
            `EXE_SWR_OP: begin
				mem_waddr_o = {mem_addr_i[31:2], 2'b00};
				mem_we = `WriteEnable;
				case (mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o = 4'b1111;
                        mem_data_o = reg2_i;
                    end
                    2'b01: begin
                        mem_sel_o = 4'b1110;
                        mem_data_o = {reg2_i[23:0], 8'b0};
                    end
                    2'b10: begin
                        mem_sel_o = 4'b1100;
                        mem_data_o = {reg2_i[15:0], 16'b0};
                    end
                    2'b11: begin
                        mem_sel_o = 4'b1000;
                        mem_data_o = {reg2_i[7:0], 24'b0};
                    end
                    default: ;
                endcase				
            end
            `EXE_LL_OP: begin
                mem_waddr_o = mem_addr_i;
                mem_we = `WriteDisable;
                mem_re_o = `ChipEnable;
                wdata1_o = mem_data_i;
                LLbit_o = 1'b1;
                LLbit_we_o = `WriteEnable;
            end
            `EXE_SC_OP: begin
                if (LLbit == 1'b1) begin
                    mem_waddr_o = mem_addr_i;
                    mem_we = `WriteEnable;
                    wdata1_o = 32'b1;
                    mem_sel_o = 4'b1111;
                    mem_data_o = reg2_i;
                    LLbit_o = 1'b0;
                    LLbit_we_o = `WriteEnable;
                end else wdata1_o = 32'b0;
            end
            default: ;
            endcase
        end
    end

endmodule