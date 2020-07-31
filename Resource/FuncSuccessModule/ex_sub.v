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
// Module:  ex_sub
// File:    ex_sub.v
// Author:
// E-mail:
// Description: 执行阶段
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module ex_sub(
    input rst,
    
    // 输入
	input[`AluOpBus]         aluop_i,
	input[`AluSelBus]        alusel_i,
	input[`RegBus]           reg1_i,
	input[`RegBus]           reg2_i,
	input[`RegAddrBus]       waddr_i,
    input                    we_i,
    
    input[`RegBus]           hi_i,
    input[`RegBus]           lo_i,
    
    input[`DoubleRegBus]     mul_i,
    input[`DoubleRegBus]     div_result_i,
    input                    div_ready_i,
    
    input[`RegBus]           imm_i,
    input[`InstAddrBus]      pc_i,
    input[`InstAddrBus]      npc_i,
    input                    branch_flag_i,
    
    input[`RegAddrBus]       cp0_addr_i,
    input[`RegBus]           cp0_data_i,
    input                    mem_cp0_we_i,
    input[`RegAddrBus]       mem_cp0_waddr_i,
    input[`RegBus]           mem_cp0_wdata_i,
    input                    commit_cp0_we_i,
    input[`RegAddrBus]       commit_cp0_waddr_i,
    input[`RegBus]           commit_cp0_wdata_i,
    
    input[31:0]              exception_type_i,
	
    output reg[`RegAddrBus] waddr_o,
    output reg              we_o,
    output reg[`RegBus]     wdata_o,
    output reg[`RegBus]     hi_o,
    output reg[`RegBus]     lo_o,
    output reg              whilo_o,
    
    output reg[`RegBus]     div_opdata1_o,
    output reg[`RegBus]     div_opdata2_o,
    output reg              div_start_o,
    output reg              signed_div_o,
    
    output reg[`InstAddrBus]         npc_actual,
    output reg                       branch_flag_actual,
	output reg                       pred_flag,
	output reg[`SIZE_OF_BRANCH_INFO] branch_info, // 送给分支预测器
	
	output reg[`RegAddrBus]          cp0_raddr_o,
    output reg                       cp0_we_o,
	output reg[`RegAddrBus]          cp0_waddr_o,
	output reg[`RegBus]              cp0_wdata_o,
	
	output[31:0] exception_type_o,
    
    output stallreq
    
    );
    
    reg[`RegBus] logicres;
    reg[`RegBus] shiftres;
    reg[`RegBus] moveres;
    reg[`RegBus] arithmeticres;
    reg[`RegBus] jbres;
    reg[`InstAddrBus] jbaddr;
    wire[`DoubleRegBus] mulres;
    wire ov_sum; // 加法溢出
    wire sub; // 是否要执行减法
    wire[31:0] sum; // 加法器和输出
    wire[31:0] carry; // 加法器进位输出
    wire[`InstAddrBus] pc_4;
    wire[`InstAddrBus] pc_8;
    reg stallreq_for_div;
    reg stallreq_for_mfc0;
    reg trapassert;
    reg ovassert;
    
    assign stallreq = stallreq_for_div | stallreq_for_mfc0;
    assign exception_type_o = {exception_type_i[31:14], trapassert, ovassert, exception_type_i[11:0]};
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            logicres = `ZeroWord;
        end else begin
            case (aluop_i)
            `EXE_OR_OP: logicres = reg1_i | reg2_i;
            `EXE_AND_OP: logicres = reg1_i & reg2_i;
            `EXE_XOR_OP: logicres = reg1_i ^ reg2_i;
            `EXE_NOR_OP: logicres = ~(reg1_i | reg2_i);
            default: logicres = `ZeroWord;
            endcase
        end
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            shiftres = `ZeroWord;
        end else begin
            case (aluop_i)
            `EXE_SLL_OP: shiftres = reg2_i << reg1_i[4:0];
            `EXE_SRL_OP: shiftres = reg2_i >> reg1_i[4:0];
            `EXE_SRA_OP: shiftres = $signed(reg2_i) >>> reg1_i[4:0];
            default: shiftres = `ZeroWord;
            endcase
        end
    end
    
    assign sub = (aluop_i == `EXE_SUB_OP) | (aluop_i == `EXE_SUBU_OP) | (aluop_i == `EXE_SLT_OP) |
                 (aluop_i == `EXE_TGE_OP) | (aluop_i == `EXE_TGEI_OP) | (aluop_i == `EXE_TLT_OP) | (aluop_i == `EXE_TLTI_OP);
    fa32 u_fa32(.a(reg1_i), .b(reg2_i), .cin(1'b0), .sub(sub), .s(sum), .cout(carry));
    assign ov_sum = carry[31] ^ carry[30];
    
    always @ (*) begin
        if (rst == `RstEnable) arithmeticres = `ZeroWord;
        else begin
            case (aluop_i)
            `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP, `EXE_SUB_OP, `EXE_SUBU_OP: arithmeticres = sum;
            `EXE_SLT_OP: begin
                if (reg1_i[31] & ~reg2_i[31]) arithmeticres = 1'b1;
                else if (~reg1_i[31] & reg2_i[31]) arithmeticres = 1'b0;
                else arithmeticres = sum[31];
            end
            `EXE_SLTU_OP: arithmeticres = reg1_i < reg2_i;
            `EXE_CLZ_OP: begin
                arithmeticres = reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 :
													 reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 :
													 reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 : 
													 reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 :
													 reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 : 
													 reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 : 
													 reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 :
													 reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 : 
													 reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 : 
													 reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 : 
													 reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ;
			end
			`EXE_CLO_OP: begin
			     arithmeticres = ~reg1_i[31] ? 0 : ~reg1_i[30] ? 1 : ~reg1_i[29] ? 2 :
													~reg1_i[28] ? 3 : ~reg1_i[27] ? 4 : ~reg1_i[26] ? 5 :
													~reg1_i[25] ? 6 : ~reg1_i[24] ? 7 : ~reg1_i[23] ? 8 : 
													~reg1_i[22] ? 9 : ~reg1_i[21] ? 10 : ~reg1_i[20] ? 11 :
													~reg1_i[19] ? 12 : ~reg1_i[18] ? 13 : ~reg1_i[17] ? 14 : 
													~reg1_i[16] ? 15 : ~reg1_i[15] ? 16 : ~reg1_i[14] ? 17 : 
													~reg1_i[13] ? 18 : ~reg1_i[12] ? 19 : ~reg1_i[11] ? 20 :
													~reg1_i[10] ? 21 : ~reg1_i[9] ? 22 : ~reg1_i[8] ? 23 : 
													~reg1_i[7] ? 24 : ~reg1_i[6] ? 25 : ~reg1_i[5] ? 26 : 
													~reg1_i[4] ? 27 : ~reg1_i[3] ? 28 : ~reg1_i[2] ? 29 : 
													~reg1_i[1] ? 30 : ~reg1_i[0] ? 31 : 32 ;
			end
            default: arithmeticres = `ZeroWord;
            endcase
        end
    end
    
    // 判断是否发生自陷异常
    always @ (*) begin
        if (rst == `RstEnable) trapassert = `TrapNotAssert;
        else begin
            trapassert = `TrapNotAssert;
            case (aluop_i)
                `EXE_TEQ_OP, `EXE_TEQI_OP: trapassert = reg1_i == reg2_i ? `TrapAssert : `TrapNotAssert;
                `EXE_TGE_OP, `EXE_TGEI_OP: begin
                    if (~reg1_i[31] & reg2_i[31]) trapassert = `TrapAssert;
                    else if (reg1_i[31] & ~reg2_i[31]) trapassert = `TrapNotAssert;
                    else trapassert = ~sum[31] ? `TrapAssert : `TrapNotAssert;
                end
                `EXE_TGEU_OP, `EXE_TGEIU_OP: trapassert = reg1_i >= reg2_i ? `TrapAssert : `TrapNotAssert;
                `EXE_TLT_OP, `EXE_TLTI_OP: begin
                    if (~reg1_i[31] & reg2_i[31]) trapassert = `TrapNotAssert;
                    else if (reg1_i[31] & ~reg2_i[31]) trapassert = `TrapAssert;
                    else trapassert = sum[31] ? `TrapAssert : `TrapNotAssert;
                end
                `EXE_TLTU_OP, `EXE_TLTIU_OP: trapassert = reg1_i < reg2_i ? `TrapAssert : `TrapNotAssert;
                `EXE_TNE_OP, `EXE_TNEI_OP: trapassert = reg1_i != reg2_i ? `TrapAssert : `TrapNotAssert;
                default: ;
            endcase
        end
    end
    
    assign mulres = mul_i;
    
    always @ (*) begin
		if (rst == `RstEnable) begin
			stallreq_for_div = `NoStop;
	        div_opdata1_o = `ZeroWord;
			div_opdata2_o = `ZeroWord;
			div_start_o = `DivStop;
			signed_div_o = 1'b0;
		end else begin
			stallreq_for_div = `NoStop;
	        div_opdata1_o = `ZeroWord;
			div_opdata2_o = `ZeroWord;
			div_start_o = `DivStop;
			signed_div_o = 1'b0;	
			case (aluop_i) 
			`EXE_DIV_OP: begin
				if (div_ready_i == `DivResultNotReady) begin
	    			div_opdata1_o = reg1_i;
					div_opdata2_o = reg2_i;
					div_start_o = `DivStart;
					signed_div_o = 1'b1;
					stallreq_for_div = `Stop;
				end else if(div_ready_i == `DivResultReady) begin
	    			div_opdata1_o = reg1_i;
					div_opdata2_o = reg2_i;
					div_start_o = `DivStop;
					signed_div_o = 1'b1;
					stallreq_for_div = `NoStop;
				end else begin						
	    			div_opdata1_o = `ZeroWord;
					div_opdata2_o = `ZeroWord;
					div_start_o = `DivStop;
					signed_div_o = 1'b0;
					stallreq_for_div = `NoStop;
				end					
			end
			`EXE_DIVU_OP: begin
				if(div_ready_i == `DivResultNotReady) begin
	    			div_opdata1_o = reg1_i;
					div_opdata2_o = reg2_i;
					div_start_o = `DivStart;
					signed_div_o = 1'b0;
					stallreq_for_div = `Stop;
				end else if (div_ready_i == `DivResultReady) begin
	    			div_opdata1_o = reg1_i;
					div_opdata2_o = reg2_i;
					div_start_o = `DivStop;
					signed_div_o = 1'b0;
					stallreq_for_div = `NoStop;
				end else begin						
	    			div_opdata1_o = `ZeroWord;
					div_opdata2_o = `ZeroWord;
					div_start_o = `DivStop;
					signed_div_o = 1'b0;
					stallreq_for_div = `NoStop;
				end					
			end
			default: begin
			end
			endcase
		end
	end	
    
    always @ (*) begin
        stallreq_for_mfc0 = `NoStop;
        cp0_raddr_o = 5'b00000;
        if (rst == `RstEnable) moveres = `ZeroWord;
        else begin
            case (aluop_i)
            `EXE_MFHI_OP: moveres = hi_i;
            `EXE_MFLO_OP: moveres = lo_i;
            `EXE_MOVZ_OP: moveres = reg1_i;
            `EXE_MOVN_OP: moveres = reg1_i;
            `EXE_MFC0_OP: begin
                cp0_raddr_o = cp0_addr_i;
                moveres = cp0_data_i;
                if (mem_cp0_we_i == `WriteEnable && mem_cp0_waddr_i == cp0_addr_i) stallreq_for_mfc0 = `Stop;
                else if (commit_cp0_we_i == `WriteEnable && commit_cp0_waddr_i == cp0_addr_i) stallreq_for_mfc0 = `Stop;
            end
            default: moveres = `ZeroWord;
            endcase
        end
    end
    
    assign pc_4 = pc_i + 4;
    assign pc_8 = pc_i + 8;
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            npc_actual = `ZeroWord;
            branch_flag_actual = `NotBranch;
            pred_flag = `ValidPrediction;
            branch_info = 35'b0;
        end
        else begin
            case (aluop_i)
                `EXE_J_OP: begin
                    branch_flag_actual = `Branch;
                    npc_actual = {pc_4[31:28], imm_i[27:0]};
                    if (branch_flag_i != branch_flag_actual) pred_flag = `InvalidPrediction;
                    else if (branch_flag_i == `NotBranch)  pred_flag = `ValidPrediction;
                    else if (npc_i == npc_actual) pred_flag = `ValidPrediction;
                    else pred_flag = `InvalidPrediction;
                    branch_info = {branch_flag_actual, npc_actual, `BTYPE_NUL};
                end
                `EXE_JAL_OP: begin
                    branch_flag_actual = `Branch;
                    npc_actual = {pc_4[31:28], imm_i[27:0]};
                    if (branch_flag_i != branch_flag_actual) pred_flag = `InvalidPrediction;
                    else if (branch_flag_i == `NotBranch)  pred_flag = `ValidPrediction;
                    else if (npc_i == npc_actual) pred_flag = `ValidPrediction;
                    else pred_flag = `InvalidPrediction;
                    branch_info = {branch_flag_actual, npc_actual, `BTYPE_CAL};
                end
                `EXE_JR_OP: begin
                    branch_flag_actual = `Branch;
                    npc_actual = reg1_i;
                    if (branch_flag_i != branch_flag_actual) pred_flag = `InvalidPrediction;
                    else if (branch_flag_i == `NotBranch)  pred_flag = `ValidPrediction;
                    else if (npc_i == npc_actual) pred_flag = `ValidPrediction;
                    else pred_flag = `InvalidPrediction;
                    branch_info = {branch_flag_actual, npc_actual, `BTYPE_RET};
                end
                `EXE_JALR_OP: begin
                    branch_flag_actual = `Branch;
                    npc_actual = reg1_i;
                    if (branch_flag_i != branch_flag_actual) pred_flag = `InvalidPrediction;
                    else if (branch_flag_i == `NotBranch)  pred_flag = `ValidPrediction;
                    else if (npc_i == npc_actual) pred_flag = `ValidPrediction;
                    else pred_flag = `InvalidPrediction;
                    branch_info = {branch_flag_actual, npc_actual, `BTYPE_CAL};
                end
                `EXE_BEQ_OP: begin
                    branch_flag_actual = reg1_i == reg2_i ? `Branch : `NotBranch;
                    npc_actual = branch_flag_actual == `Branch ? pc_4 + imm_i : `ZeroWord;
                    if (branch_flag_i != branch_flag_actual) pred_flag = `InvalidPrediction;
                    else if (branch_flag_i == `NotBranch)  pred_flag = `ValidPrediction;
                    else if (npc_i == npc_actual) pred_flag = `ValidPrediction;
                    else pred_flag = `InvalidPrediction;
                    branch_info = {branch_flag_actual, npc_actual, `BTYPE_NUL};
                end
                `EXE_BGTZ_OP: begin
                    branch_flag_actual = (reg1_i[31] == 1'b0) && (reg1_i != 32'b0) ? `Branch : `NotBranch;
                    npc_actual = branch_flag_actual == `Branch ? pc_4 + imm_i : `ZeroWord;
                    if (branch_flag_i != branch_flag_actual) pred_flag = `InvalidPrediction;
                    else if (branch_flag_i == `NotBranch)  pred_flag = `ValidPrediction;
                    else if (npc_i == npc_actual) pred_flag = `ValidPrediction;
                    else pred_flag = `InvalidPrediction;
                    branch_info = {branch_flag_actual, npc_actual, `BTYPE_NUL};
                end
                `EXE_BLEZ_OP: begin
                    branch_flag_actual = (reg1_i[31] == 1'b1) || (reg1_i == 32'b0) ? `Branch : `NotBranch;
                    npc_actual = branch_flag_actual == `Branch ? pc_4 + imm_i : `ZeroWord;
                    if (branch_flag_i != branch_flag_actual) pred_flag = `InvalidPrediction;
                    else if (branch_flag_i == `NotBranch)  pred_flag = `ValidPrediction;
                    else if (npc_i == npc_actual) pred_flag = `ValidPrediction;
                    else pred_flag = `InvalidPrediction;
                    branch_info = {branch_flag_actual, npc_actual, `BTYPE_NUL};
                end
                `EXE_BNE_OP: begin
                    branch_flag_actual = reg1_i != reg2_i ? `Branch : `NotBranch;
                    npc_actual = branch_flag_actual == `Branch ? pc_4 + imm_i : `ZeroWord;
                    if (branch_flag_i != branch_flag_actual) pred_flag = `InvalidPrediction;
                    else if (branch_flag_i == `NotBranch)  pred_flag = `ValidPrediction;
                    else if (npc_i == npc_actual) pred_flag = `ValidPrediction;
                    else pred_flag = `InvalidPrediction;
                    branch_info = {branch_flag_actual, npc_actual, `BTYPE_NUL};
                end
                `EXE_BGEZ_OP: begin
                    branch_flag_actual = reg1_i[31] == 1'b0 ? `Branch : `NotBranch;
                    npc_actual = branch_flag_actual == `Branch ? pc_4 + imm_i : `ZeroWord;
                    if (branch_flag_i != branch_flag_actual) pred_flag = `InvalidPrediction;
                    else if (branch_flag_i == `NotBranch)  pred_flag = `ValidPrediction;
                    else if (npc_i == npc_actual) pred_flag = `ValidPrediction;
                    else pred_flag = `InvalidPrediction;
                    branch_info = {branch_flag_actual, npc_actual, `BTYPE_NUL};
                end
                `EXE_BGEZAL_OP: begin
                    branch_flag_actual = reg1_i[31] == 1'b0 ? `Branch : `NotBranch;
                    npc_actual = branch_flag_actual == `Branch ? pc_4 + imm_i : `ZeroWord;
                    if (branch_flag_i != branch_flag_actual) pred_flag = `InvalidPrediction;
                    else if (branch_flag_i == `NotBranch)  pred_flag = `ValidPrediction;
                    else if (npc_i == npc_actual) pred_flag = `ValidPrediction;
                    else pred_flag = `InvalidPrediction;
                    branch_info = {branch_flag_actual, npc_actual, `BTYPE_CAL};
                end
                `EXE_BLTZ_OP: begin
                    branch_flag_actual = reg1_i[31] == 1'b1 ? `Branch : `NotBranch;
                    npc_actual = branch_flag_actual == `Branch ? pc_4 + imm_i : `ZeroWord;
                    if (branch_flag_i != branch_flag_actual) pred_flag = `InvalidPrediction;
                    else if (branch_flag_i == `NotBranch)  pred_flag = `ValidPrediction;
                    else if (npc_i == npc_actual) pred_flag = `ValidPrediction;
                    else pred_flag = `InvalidPrediction;
                    branch_info = {branch_flag_actual, npc_actual, `BTYPE_NUL};
                end
                `EXE_BLTZAL_OP: begin
                    branch_flag_actual = reg1_i[31] == 1'b1 ? `Branch : `NotBranch;
                    npc_actual = branch_flag_actual == `Branch ? pc_4 + imm_i : `ZeroWord;
                    if (branch_flag_i != branch_flag_actual) pred_flag = `InvalidPrediction;
                    else if (branch_flag_i == `NotBranch)  pred_flag = `ValidPrediction;
                    else if (npc_i == npc_actual) pred_flag = `ValidPrediction;
                    else pred_flag = `InvalidPrediction;
                    branch_info = {branch_flag_actual, npc_actual, `BTYPE_CAL};
                end
                default: begin
                    branch_flag_actual = `NotBranch;
                    npc_actual = `ZeroWord;
                    pred_flag = `ValidPrediction;
                    branch_info = 35'b0;
                end
            endcase
        end
    end
    
    always @ (*) begin
        if (rst == `RstEnable) jbres = `ZeroWord;
        else if (aluop_i == `EXE_JAL_OP || aluop_i == `EXE_JALR_OP || aluop_i == `EXE_BGEZAL_OP || aluop_i == `EXE_BLTZAL_OP) jbres = pc_8;
        else jbres = `ZeroWord;
    end
    
    always @ (*) begin
        waddr_o = waddr_i;
        we_o = we_i;
        ovassert = `OverflowNotAssert;
        case (alusel_i)
        `EXE_RES_LOGIC: wdata_o = logicres;
        `EXE_RES_SHIFT: wdata_o = shiftres;
        `EXE_RES_ARITHMETIC: begin
            wdata_o = arithmeticres;
            if (((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
                we_o = `WriteDisable;
                ovassert = `OverflowAssert; // 加减法溢出
            end else ovassert = `OverflowNotAssert;
        end
        `EXE_RES_MUL: wdata_o = mulres[31:0];
        `EXE_RES_MOVE: begin
            wdata_o = moveres;
            case (aluop_i)
            `EXE_MOVZ_OP: if (reg2_i != 0) we_o = `WriteDisable;
            `EXE_MOVN_OP: if (reg2_i == 0) we_o = `WriteDisable;
            default: ;
            endcase
        end
        `EXE_RES_JUMP_BRANCH: wdata_o = jbres;
        default: wdata_o = `ZeroWord;
        endcase
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            whilo_o = `WriteDisable;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
        end else if (aluop_i == `EXE_MTHI_OP) begin
            whilo_o = `WriteEnable;
            hi_o = reg1_i;
            lo_o = lo_i;
        end else if (aluop_i == `EXE_MTLO_OP) begin
            whilo_o = `WriteEnable;
            hi_o = hi_i;
            lo_o = reg1_i;
        end else if (aluop_i == `EXE_MULT_OP || aluop_i == `EXE_MULTU_OP || aluop_i == `EXE_MADD_OP || aluop_i == `EXE_MADDU_OP || aluop_i == `EXE_MSUB_OP || aluop_i == `EXE_MSUBU_OP) begin
            whilo_o = `WriteEnable;
            hi_o = mulres[63:32];
            lo_o = mulres[31:0];
        end else if (aluop_i == `EXE_DIV_OP || aluop_i == `EXE_DIVU_OP) begin
            whilo_o = `WriteEnable;
            hi_o = div_result_i[63:32];
            lo_o = div_result_i[31:0];
        end else begin
            whilo_o = `WriteDisable;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
        end
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            cp0_we_o = `WriteDisable;
            cp0_waddr_o = 5'b00000;
            cp0_wdata_o = `ZeroWord;
        end else if (aluop_i == `EXE_MTC0_OP) begin
            cp0_we_o = `WriteEnable;
            cp0_waddr_o = cp0_addr_i;
            cp0_wdata_o = reg1_i;
        end else begin
            cp0_we_o = `WriteDisable;
            cp0_waddr_o = 5'b00000;
            cp0_wdata_o = `ZeroWord;
        end
    end
    
endmodule
