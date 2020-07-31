//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/24 16:48:43
// Design Name: 
// Module Name: id_ex
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
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module id_ex(
    input clk,
    input resetn,
    input flush,
    input flush_cause,
    input[5:0]               stall,
    
    // 来自译码阶段的输入    
	input[`AluOpBus]         aluop1_i,
	input[`AluSelBus]        alusel1_i,
	input[`AluOpBus]         aluop2_i,
	input[`AluSelBus]        alusel2_i,
	input[`RegBus]           reg1_i,
	input[`RegBus]           reg2_i,
	input[`RegBus]           reg3_i,
	input[`RegBus]           reg4_i,
	input[`RegAddrBus]       waddr1_i,
	input[`RegAddrBus]       waddr2_i,
	input                    we1_i,
	input                    we2_i,
	input                    reg3_raw_dependency_i,
	input                    reg4_raw_dependency_i,
	input[`RegBus]           hi_i,
	input[`RegBus]           lo_i,
	input[`InstAddrBus]      pc_i,
	input[`InstAddrBus]      npc_i,
	input                    branch_flag_i,
	input[`RegBus]           imm_i,
	input                    issue_i,
	input                    ex_issue_mode_i,
	input[`RegAddrBus]       cp0_addr_i,
	input                    is_in_delayslot1_i,
	input                    is_in_delayslot2_i,
	input[31:0]              exception_type1_i,
	input[31:0]              exception_type2_i,
	
	// 输出至发射阶段   
	output reg[`AluOpBus]         aluop1_o,
	output reg[`AluSelBus]        alusel1_o,
	output reg[`AluOpBus]         aluop2_o,
	output reg[`AluSelBus]        alusel2_o,
	output reg[`RegBus]           reg1_o,
	output reg[`RegBus]           reg2_o,
	output reg[`RegBus]           reg3_o,
	output reg[`RegBus]           reg4_o,
	output reg[`RegAddrBus]       waddr1_o,
	output reg[`RegAddrBus]       waddr2_o,
	output reg                    we1_o,
	output reg                    we2_o,
	output reg                    reg3_raw_dependency_o,
	output reg                    reg4_raw_dependency_o,
	output reg[`RegBus]           hi_o,
	output reg[`RegBus]           lo_o,
	output reg[`InstAddrBus]      pc_o,
	output reg[`InstAddrBus]      npc_o,
	output reg                    branch_flag_o,
	output reg[`RegBus]           imm_o,
	output reg                    issue_o,
	output reg[`RegAddrBus]       cp0_addr_o,
	output reg                    is_in_delayslot1_o,
	output reg                    is_in_delayslot2_o,
	output reg[31:0]              exception_type1_o,
	output reg[31:0]              exception_type2_o
	
    );
    
    always @ (posedge clk) begin
        if (resetn == `RstEnable) begin
            aluop1_o <= `EXE_NOP_OP;
            alusel1_o <= `EXE_RES_NOP;
            aluop2_o <= `EXE_NOP_OP;
            alusel2_o <= `EXE_RES_NOP;
            reg1_o <= `ZeroWord;
            reg2_o <= `ZeroWord;
            reg3_o <= `ZeroWord;
            reg4_o <= `ZeroWord;
            waddr1_o <= `NOPRegAddr;
            waddr2_o <= `NOPRegAddr;
            we1_o <= `WriteDisable;
            we2_o <= `WriteDisable;
            reg3_raw_dependency_o <= `RAWIndependent;
            reg4_raw_dependency_o <= `RAWIndependent;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            pc_o <= `ZeroWord;
            npc_o <= `ZeroWord;
            branch_flag_o <= `NotBranch;
            imm_o <= `ZeroWord;
            issue_o <= `DualIssue;
            cp0_addr_o <= 5'b00000;
            is_in_delayslot1_o <= `NotInDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            exception_type1_o <= `ZeroWord;
            exception_type2_o <= `ZeroWord;
        end else if (flush == `Flush && flush_cause == `FailedBranchPrediction && ex_issue_mode_i == `DualIssue) begin
            aluop1_o <= `EXE_NOP_OP;
            alusel1_o <= `EXE_RES_NOP;
            aluop2_o <= `EXE_NOP_OP;
            alusel2_o <= `EXE_RES_NOP;
            reg1_o <= `ZeroWord;
            reg2_o <= `ZeroWord;
            reg3_o <= `ZeroWord;
            reg4_o <= `ZeroWord;
            waddr1_o <= `NOPRegAddr;
            waddr2_o <= `NOPRegAddr;
            we1_o <= `WriteDisable;
            we2_o <= `WriteDisable;
            reg3_raw_dependency_o <= `RAWIndependent;
            reg4_raw_dependency_o <= `RAWIndependent;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            pc_o <= `ZeroWord;
            npc_o <= `ZeroWord;
            branch_flag_o <= `NotBranch;
            imm_o <= `ZeroWord;
            issue_o <= `DualIssue;
            cp0_addr_o <= 5'b00000;
            is_in_delayslot1_o <= `NotInDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            exception_type1_o <= `ZeroWord;
            exception_type2_o <= `ZeroWord;
        end else if (flush == `Flush && flush_cause == `FailedBranchPrediction && ex_issue_mode_i == `SingleIssue) begin // 此时第一条是延迟槽指令，第二条是错取的指令
            aluop1_o <= aluop1_i;
            alusel1_o <= alusel1_i;
            aluop2_o <= `EXE_NOP_OP;
            alusel2_o <= `EXE_RES_NOP;
            reg1_o <= reg1_i;
            reg2_o <= reg2_i;
            reg3_o <= `ZeroWord;
            reg4_o <= `ZeroWord;
            waddr1_o <= waddr1_i;
            waddr2_o <= `NOPRegAddr;
            we1_o <= we1_i;
            we2_o <= `WriteDisable;
            reg3_raw_dependency_o <= `RAWIndependent;
            reg4_raw_dependency_o <= `RAWIndependent;
            hi_o <= hi_i;
            lo_o <= lo_i;
            pc_o <= pc_i;
            npc_o <= npc_i;
            branch_flag_o <= branch_flag_i;
            imm_o <= imm_i;
            issue_o <= issue_i;
            cp0_addr_o <= cp0_addr_i;
            is_in_delayslot1_o <= is_in_delayslot1_i;
            is_in_delayslot2_o <= is_in_delayslot2_i;
            exception_type1_o <= exception_type1_i;
            exception_type2_o <= `ZeroWord;
        end else if (flush == `Flush && flush_cause == `Exception) begin
            aluop1_o <= `EXE_NOP_OP;
            alusel1_o <= `EXE_RES_NOP;
            aluop2_o <= `EXE_NOP_OP;
            alusel2_o <= `EXE_RES_NOP;
            reg1_o <= `ZeroWord;
            reg2_o <= `ZeroWord;
            reg3_o <= `ZeroWord;
            reg4_o <= `ZeroWord;
            waddr1_o <= `NOPRegAddr;
            waddr2_o <= `NOPRegAddr;
            we1_o <= `WriteDisable;
            we2_o <= `WriteDisable;
            reg3_raw_dependency_o <= `RAWIndependent;
            reg4_raw_dependency_o <= `RAWIndependent;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            pc_o <= `ZeroWord;
            npc_o <= `ZeroWord;
            branch_flag_o <= `NotBranch;
            imm_o <= `ZeroWord;
            issue_o <= `DualIssue;
            cp0_addr_o <= 5'b00000;
            is_in_delayslot1_o <= `NotInDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            exception_type1_o <= `ZeroWord;
            exception_type2_o <= `ZeroWord;
        end else if (stall[2] == `Stop && stall[3] == `NoStop) begin
            aluop1_o <= `EXE_NOP_OP;
            alusel1_o <= `EXE_RES_NOP;
            aluop2_o <= `EXE_NOP_OP;
            alusel2_o <= `EXE_RES_NOP;
            reg1_o <= `ZeroWord;
            reg2_o <= `ZeroWord;
            reg3_o <= `ZeroWord;
            reg4_o <= `ZeroWord;
            waddr1_o <= `NOPRegAddr;
            waddr2_o <= `NOPRegAddr;
            we1_o <= `WriteDisable;
            we2_o <= `WriteDisable;
            reg3_raw_dependency_o <= `RAWIndependent;
            reg4_raw_dependency_o <= `RAWIndependent;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            pc_o <= `ZeroWord;
            npc_o <= `ZeroWord;
            branch_flag_o <= `NotBranch;
            imm_o <= `ZeroWord;
            issue_o <= `DualIssue;
            cp0_addr_o <= 5'b00000;
            is_in_delayslot1_o <= `NotInDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            exception_type1_o <= `ZeroWord;
            exception_type2_o <= `ZeroWord;
        end else if (stall[2] == `NoStop) begin
            aluop1_o <= aluop1_i;
            alusel1_o <= alusel1_i;
            aluop2_o <= aluop2_i;
            alusel2_o <= alusel2_i;
            reg1_o <= reg1_i;
            reg2_o <= reg2_i;
            reg3_o <= reg3_i;
            reg4_o <= reg4_i;
            waddr1_o <= waddr1_i;
            waddr2_o <= waddr2_i;
            we1_o <= we1_i;
            we2_o <= we2_i;
            reg3_raw_dependency_o <= reg3_raw_dependency_i;
            reg4_raw_dependency_o <= reg4_raw_dependency_i;
            hi_o <= hi_i;
            lo_o <= lo_i;
            pc_o <= pc_i;
            npc_o <= npc_i;
            branch_flag_o <= branch_flag_i;
            imm_o <= imm_i;
            issue_o <= issue_i;
            cp0_addr_o <= cp0_addr_i;
            is_in_delayslot1_o <= is_in_delayslot1_i;
            is_in_delayslot2_o <= is_in_delayslot2_i;
            exception_type1_o <= exception_type1_i;
            exception_type2_o <= exception_type2_i;
        end
    end
    
endmodule