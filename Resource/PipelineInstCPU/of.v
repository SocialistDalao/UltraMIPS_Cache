//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/26 14:37:01
// Design Name: 
// Module Name: of
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

module of(
    input rst,
    
    input[`InstAddrBus] inst1_addr_i,
    input[`InstAddrBus] inst2_addr_i,
	
	input               is_in_delayslot1_i,
	input               is_in_delayslot2_i,
	
	// 寄存器堆送来的数据
	input[`RegBus]           reg1_data_i,
	input[`RegBus]           reg2_data_i,
	input[`RegBus]           reg3_data_i,
	input[`RegBus]           reg4_data_i,
	
	// 译码阶段送来的信息
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

    // 解决数据相关
    input[`RegAddrBus]       ex_waddr1_i,
	input[`RegAddrBus]       ex_waddr2_i,
	input                    ex_we1_i,
	input                    ex_we2_i,
	input[`RegBus]           ex_wdata1_i,
	input[`RegBus]           ex_wdata2_i,
	input[`RegAddrBus]       mem_waddr1_i,
	input[`RegAddrBus]       mem_waddr2_i,
	input                    mem_we1_i,
	input                    mem_we2_i,
	input[`RegBus]           mem_wdata1_i,
	input[`RegBus]           mem_wdata2_i,
	
	input                    mul_s_i,
	
	// 解决访存相关
	input[`AluOpBus]         ex_aluop1_i,
	
	// HI、LO寄存器的值
	input[`RegBus]           hi_i,
	input[`RegBus]           lo_i,
	
	// 执行阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
	input[`RegBus]           ex_hi_i,
	input[`RegBus]           ex_lo_i,
	input                    ex_whilo_i,

	// 回写阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
	input[`RegBus]           mem_hi_i,
	input[`RegBus]           mem_lo_i,
	input                    mem_whilo_i,
	
	// 提交阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
	input[`RegBus]           commit_hi_i,
	input[`RegBus]           commit_lo_i,
	input                    commit_whilo_i,
	
    // 是否双发射
	input issue_i,
	
	// 异常信息
	input[31:0]              exception_type1_i,
	input[31:0]              exception_type2_i,

    output[`InstAddrBus]     inst1_addr_o,
    output[`InstAddrBus]     inst2_addr_o,
    
	// 送到寄存器堆的信息
	output                   reg1_read_o,
	output                   reg2_read_o,
	output                   reg3_read_o,
	output                   reg4_read_o,
	output[`RegAddrBus]      reg1_raddr_o,
	output[`RegAddrBus]      reg2_raddr_o,
	output[`RegAddrBus]      reg3_raddr_o,
	output[`RegAddrBus]      reg4_raddr_o,    
	
	// 送到执行阶段的信息
	output[`AluOpBus]        aluop1_o,
	output[`AluSelBus]       alusel1_o,
	output[`AluOpBus]        aluop2_o,
	output[`AluSelBus]       alusel2_o,
	output[`RegAddrBus]      waddr1_o,
	output[`RegAddrBus]      waddr2_o,
	output                   we1_o,
	output                   we2_o,
	
	// 送给乘法器的信号
	output                   mul_s_o,
	
	output reg[`RegBus]           reg1_o,
	output reg[`RegBus]           reg2_o,
	output reg[`RegBus]           reg3_o,
	output reg[`RegBus]           reg4_o,
	
	// HI, LO寄存器最新值
	output reg[`RegBus]           hi_o,
	output reg[`RegBus]           lo_o,
	
	output                    is_in_delayslot1_o,
	output                    is_in_delayslot2_o,
	
	output[`RegBus]           imm_fnl1_o,
	
	output                    issue_o,
	
	output[`RegAddrBus]       cp0_addr_o,
	output[2:0]               cp0_sel_o,
	
	output[31:0]              exception_type1_o,
	output[31:0]              exception_type2_o,
	
	output                    stallreq
    );
    
    wire is_load;
    reg reg1_load_dependency;
    reg reg2_load_dependency;
    reg reg3_load_dependency;
    reg reg4_load_dependency;
    
    assign is_load = ex_aluop1_i == `EXE_LB_OP || ex_aluop1_i == `EXE_LBU_OP || ex_aluop1_i == `EXE_LH_OP || ex_aluop1_i == `EXE_LHU_OP ||
                     ex_aluop1_i == `EXE_LW_OP || ex_aluop1_i == `EXE_LWR_OP || ex_aluop1_i == `EXE_LWL_OP || ex_aluop1_i == `EXE_LL_OP ||
                     ex_aluop1_i == `EXE_SC_OP;
                     
    assign stallreq = reg1_load_dependency == `LoadDependent || reg2_load_dependency == `LoadDependent ||
                      reg3_load_dependency == `LoadDependent || reg4_load_dependency == `LoadDependent ? `Stop : `NoStop;
    
    assign inst1_addr_o = inst1_addr_i;
    assign inst2_addr_o = inst2_addr_i;
    assign reg1_read_o = reg1_read_i;
    assign reg2_read_o = reg2_read_i;
    assign reg3_read_o = reg3_read_i;
    assign reg4_read_o = reg4_read_i;
    assign reg1_raddr_o = reg1_raddr_i;
    assign reg2_raddr_o = reg2_raddr_i;
    assign reg3_raddr_o = reg3_raddr_i;
    assign reg4_raddr_o = reg4_raddr_i;
    assign aluop1_o = aluop1_i;
    assign alusel1_o = alusel1_i;
    assign aluop2_o = aluop2_i;
    assign alusel2_o = alusel2_i;
    assign waddr1_o = waddr1_i;
    assign we1_o = we1_i;
    assign waddr2_o = waddr2_i;
    assign we2_o = we2_i;
    assign mul_s_o = mul_s_i;
    assign is_in_delayslot1_o = is_in_delayslot1_i;
    assign is_in_delayslot2_o = is_in_delayslot2_i;
    assign imm_fnl1_o = imm_fnl1_i;
    assign issue_o = issue_i;
    assign cp0_addr_o = cp0_addr_i;
    assign cp0_sel_o = cp0_sel_i;
    assign exception_type1_o = exception_type1_i;
    assign exception_type2_o = exception_type2_i;
    
    // 解决数据相关
    
    always @ (*) begin
	    reg1_o = `ZeroWord;
	    reg1_load_dependency = `LoadIndependent;
        if (rst == `RstEnable) reg1_o = `ZeroWord;
        else if (reg1_read_i == `ReadEnable)
            if (is_load && ex_waddr1_i == reg1_raddr_o) reg1_load_dependency = `LoadDependent;
            else if (ex_we2_i == `WriteEnable && ex_waddr2_i == reg1_raddr_i) reg1_o = ex_wdata2_i;
            else if (ex_we1_i == `WriteEnable && ex_waddr1_i == reg1_raddr_i) reg1_o = ex_wdata1_i;
            else if (mem_we2_i == `WriteEnable && mem_waddr2_i == reg1_raddr_i) reg1_o = mem_wdata2_i;
            else if (mem_we1_i == `WriteEnable && mem_waddr1_i == reg1_raddr_i) reg1_o = mem_wdata1_i;
            else reg1_o = reg1_data_i;
        else if (reg1_read_i == `ReadDisable) reg1_o = imm_fnl1_i;
        else reg1_o = `ZeroWord;
    end
    
    always @ (*) begin
	    reg2_o = `ZeroWord;
	    reg2_load_dependency = `LoadIndependent;
        if (rst == `RstEnable) reg2_o = `ZeroWord;
        else if (reg2_read_i == `ReadEnable)
            if (is_load && ex_waddr1_i == reg2_raddr_o) reg2_load_dependency = `LoadDependent;
            else if (ex_we2_i == `WriteEnable && ex_waddr2_i == reg2_raddr_i) reg2_o = ex_wdata2_i;
            else if (ex_we1_i == `WriteEnable && ex_waddr1_i == reg2_raddr_i) reg2_o = ex_wdata1_i;
            else if (mem_we2_i == `WriteEnable && mem_waddr2_i == reg2_raddr_i) reg2_o = mem_wdata2_i;
            else if (mem_we1_i == `WriteEnable && mem_waddr1_i == reg2_raddr_i) reg2_o = mem_wdata1_i;
            else reg2_o = reg2_data_i;
        else if (reg2_read_i == `ReadDisable) reg2_o = imm_fnl1_i;
        else reg2_o = `ZeroWord;
    end
    
    always @ (*) begin
	    reg3_o = `ZeroWord;
	    reg3_load_dependency = `LoadIndependent;
        if (rst == `RstEnable) reg3_o = `ZeroWord;
        else if (reg3_read_i == `ReadEnable)
            if (is_load && ex_waddr1_i == reg3_raddr_o) reg3_load_dependency = `LoadDependent;
            else if (ex_we2_i == `WriteEnable && ex_waddr2_i == reg3_raddr_i) reg3_o = ex_wdata2_i;
            else if (ex_we1_i == `WriteEnable && ex_waddr1_i == reg3_raddr_i) reg3_o = ex_wdata1_i;
            else if (mem_we2_i == `WriteEnable && mem_waddr2_i == reg3_raddr_i) reg3_o = mem_wdata2_i;
            else if (mem_we1_i == `WriteEnable && mem_waddr1_i == reg3_raddr_i) reg3_o = mem_wdata1_i;
            else reg3_o = reg3_data_i;
        else if (reg3_read_i == `ReadDisable) reg3_o = imm_fnl2_i;
        else reg3_o = `ZeroWord;
    end
    
    always @ (*) begin
	    reg4_o = `ZeroWord;
	    reg4_load_dependency = `LoadIndependent;
        if (rst == `RstEnable) reg4_o = `ZeroWord;
        else if (reg4_read_i == `ReadEnable)
            if (is_load && ex_waddr1_i == reg4_raddr_o) reg4_load_dependency = `LoadDependent;
            else if (ex_we2_i == `WriteEnable && ex_waddr2_i == reg4_raddr_i) reg4_o = ex_wdata2_i;
            else if (ex_we1_i == `WriteEnable && ex_waddr1_i == reg4_raddr_i) reg4_o = ex_wdata1_i;
            else if (mem_we2_i == `WriteEnable && mem_waddr2_i == reg4_raddr_i) reg4_o = mem_wdata2_i;
            else if (mem_we1_i == `WriteEnable && mem_waddr1_i == reg4_raddr_i) reg4_o = mem_wdata1_i;
            else reg4_o = reg4_data_i;
        else if (reg4_read_i == `ReadDisable) reg4_o = imm_fnl2_i;
        else reg4_o = `ZeroWord;
    end
    
    always @ (*) begin
		if (rst == `RstEnable) {hi_o, lo_o} = {`ZeroWord, `ZeroWord};
		else if (ex_whilo_i == `WriteEnable) {hi_o, lo_o} = {ex_hi_i, ex_lo_i};
		else if (mem_whilo_i == `WriteEnable) {hi_o, lo_o} = {mem_hi_i, mem_lo_i};
		else if (commit_whilo_i == `WriteEnable) {hi_o, lo_o} = {commit_hi_i, commit_lo_i};
		else {hi_o, lo_o} = {hi_i, lo_i};
	end
	
endmodule
