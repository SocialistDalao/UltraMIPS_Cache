//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/26 14:37:01
// Design Name: 
// Module Name: id_of
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


module id_of(
    input clk,
    input resetn,
	input flush,
	input flush_cause,
	input[4:0] stall,
	
	input[`InstAddrBus]      inst1_addr_i,
	input[`InstAddrBus]      inst2_addr_i,
	input                    is_in_delayslot1_i,
	input                    is_in_delayslot2_i,
	input                    reg1_read_i,
	input                    reg2_read_i,
	input                    reg3_read_i,
	input                    reg4_read_i,
	input[`RegAddrBus]       reg1_raddr_i,
	input[`RegAddrBus]       reg2_raddr_i,
	input[`RegAddrBus]       reg3_raddr_i,
	input[`RegAddrBus]       reg4_raddr_i,
	input[`RegBus]           imm_fnl1_i,
	input[`RegBus]           imm_fnl2_i,
	input[`AluOpBus]         aluop1_i,
	input[`AluSelBus]        alusel1_i,
	input[`AluOpBus]         aluop2_i,
	input[`AluSelBus]        alusel2_i,
	input[`RegAddrBus]       waddr1_i,
	input[`RegAddrBus]       waddr2_i,
	input                    we1_i,
	input                    we2_i,
	input[`RegAddrBus]       cp0_addr_i,
	input[2:0]               cp0_sel_i,
	input                    next_inst_in_delayslot_i,
	input                    issue_i,
	input[31:0]              exception_type1_i,
	input[31:0]              exception_type2_i,
	
	output reg[`InstAddrBus]      inst1_addr_o,
	output reg[`InstAddrBus]      inst2_addr_o,
	output reg                    is_in_delayslot1_o,
	output reg                    is_in_delayslot2_o,
	output reg                    reg1_read_o,
	output reg                    reg2_read_o,
	output reg                    reg3_read_o,
	output reg                    reg4_read_o,
	output reg[`RegAddrBus]       reg1_raddr_o,
	output reg[`RegAddrBus]       reg2_raddr_o,
	output reg[`RegAddrBus]       reg3_raddr_o,
	output reg[`RegAddrBus]       reg4_raddr_o,
	output reg[`RegBus]           imm_fnl1_o,
	output reg[`RegBus]           imm_fnl2_o,
	output reg[`AluOpBus]         aluop1_o,
	output reg[`AluSelBus]        alusel1_o,
	output reg[`AluOpBus]         aluop2_o,
	output reg[`AluSelBus]        alusel2_o,
	output reg[`RegAddrBus]       waddr1_o,
	output reg[`RegAddrBus]       waddr2_o,
	output reg                    we1_o,
	output reg                    we2_o,
	output reg[`RegAddrBus]       cp0_addr_o,
	output reg[2:0]               cp0_sel_o,
	output reg                    next_inst_in_delayslot_o,
	output reg                    issue_o,
	output reg[31:0]              exception_type1_o,
	output reg[31:0]              exception_type2_o
    );
    always @ (posedge clk) begin
        if (resetn == `RstEnable) begin
            inst1_addr_o <= `ZeroWord;
            inst2_addr_o <= `ZeroWord;
            is_in_delayslot1_o <= `NotInDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            reg1_read_o <= `ReadDisable;
            reg2_read_o <= `ReadDisable;
            reg3_read_o <= `ReadDisable;
            reg4_read_o <= `ReadDisable;
            reg1_raddr_o <= `NOPRegAddr;
            reg2_raddr_o <= `NOPRegAddr;
            reg3_raddr_o <= `NOPRegAddr;
            reg4_raddr_o <= `NOPRegAddr;
            imm_fnl1_o <= `ZeroWord;
            imm_fnl2_o <= `ZeroWord;
            aluop1_o <= `EXE_NOP_OP;
            alusel1_o <= `EXE_RES_NOP;
            aluop2_o <= `EXE_NOP_OP;
            alusel2_o <= `EXE_RES_NOP;
            waddr1_o <= `NOPRegAddr;
            waddr2_o <= `NOPRegAddr;
            we1_o <= `WriteDisable;
            we2_o <= `WriteDisable;
            next_inst_in_delayslot_o <= `NotInDelaySlot;
            issue_o <= `DualIssue;
            cp0_addr_o <= `NOPRegAddr;
            cp0_sel_o = 3'b000;
            exception_type1_o <= `ZeroWord;
            exception_type2_o <= `ZeroWord;
        end else if (flush == `Flush) begin
            inst1_addr_o <= `ZeroWord;
            inst2_addr_o <= `ZeroWord;
            is_in_delayslot1_o <= `NotInDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            reg1_read_o <= `ReadDisable;
            reg2_read_o <= `ReadDisable;
            reg3_read_o <= `ReadDisable;
            reg4_read_o <= `ReadDisable;
            reg1_raddr_o <= `NOPRegAddr;
            reg2_raddr_o <= `NOPRegAddr;
            reg3_raddr_o <= `NOPRegAddr;
            reg4_raddr_o <= `NOPRegAddr;
            imm_fnl1_o <= `ZeroWord;
            imm_fnl2_o <= `ZeroWord;
            aluop1_o <= `EXE_NOP_OP;
            alusel1_o <= `EXE_RES_NOP;
            aluop2_o <= `EXE_NOP_OP;
            alusel2_o <= `EXE_RES_NOP;
            waddr1_o <= `NOPRegAddr;
            waddr2_o <= `NOPRegAddr;
            we1_o <= `WriteDisable;
            we2_o <= `WriteDisable;
            next_inst_in_delayslot_o <= `NotInDelaySlot;
            issue_o <= `DualIssue;
            cp0_addr_o <= `NOPRegAddr;
            cp0_sel_o = 3'b000;
            exception_type1_o <= `ZeroWord;
            exception_type2_o <= `ZeroWord;
        end else if (stall[0] == `Stop && stall[1] == `NoStop) begin
            inst1_addr_o <= `ZeroWord;
            inst2_addr_o <= `ZeroWord;
            is_in_delayslot1_o <= `NotInDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            reg1_read_o <= `ReadDisable;
            reg2_read_o <= `ReadDisable;
            reg3_read_o <= `ReadDisable;
            reg4_read_o <= `ReadDisable;
            reg1_raddr_o <= `NOPRegAddr;
            reg2_raddr_o <= `NOPRegAddr;
            reg3_raddr_o <= `NOPRegAddr;
            reg4_raddr_o <= `NOPRegAddr;
            imm_fnl1_o <= `ZeroWord;
            imm_fnl2_o <= `ZeroWord;
            aluop1_o <= `EXE_NOP_OP;
            alusel1_o <= `EXE_RES_NOP;
            aluop2_o <= `EXE_NOP_OP;
            alusel2_o <= `EXE_RES_NOP;
            waddr1_o <= `NOPRegAddr;
            waddr2_o <= `NOPRegAddr;
            we1_o <= `WriteDisable;
            we2_o <= `WriteDisable;
            next_inst_in_delayslot_o <= next_inst_in_delayslot_o; // 保持，不能清空，因为是送给前一个阶段的
            issue_o <= `DualIssue;
            cp0_addr_o <= `NOPRegAddr;
            cp0_sel_o = 3'b000;
            exception_type1_o <= `ZeroWord;
            exception_type2_o <= `ZeroWord;
        end else if (stall[0] == `NoStop) begin
            inst1_addr_o <= inst1_addr_i;
            inst2_addr_o <= inst2_addr_i;
            is_in_delayslot1_o <= is_in_delayslot1_i;
            is_in_delayslot2_o <= is_in_delayslot2_i;
            reg1_read_o <= reg1_read_i;
            reg2_read_o <= reg2_read_i;
            reg3_read_o <= reg3_read_i;
            reg4_read_o <= reg4_read_i;
            reg1_raddr_o <= reg1_raddr_i;
            reg2_raddr_o <= reg2_raddr_i;
            reg3_raddr_o <= reg3_raddr_i;
            reg4_raddr_o <= reg4_raddr_i;
            imm_fnl1_o <= imm_fnl1_i;
            imm_fnl2_o <= imm_fnl2_i;
            aluop1_o <= aluop1_i;
            alusel1_o <= alusel1_i;
            aluop2_o <= aluop2_i;
            alusel2_o <= alusel2_i;
            waddr1_o <= waddr1_i;
            waddr2_o <= waddr2_i;
            we1_o <= we1_i;
            we2_o <= we2_i;
            next_inst_in_delayslot_o <= next_inst_in_delayslot_i;
            issue_o <= issue_i;
            cp0_addr_o <= cp0_addr_i;
            cp0_sel_o = cp0_sel_i;
            exception_type1_o <= exception_type1_i;
            exception_type2_o <= exception_type2_i;
        end
    end
endmodule
