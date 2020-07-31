//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/24 16:48:43
// Design Name: 
// Module Name: id
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

module id(

	input rst,
	input[`InstAddrBus] pc_i,
	input[`InstAddrBus] npc_i,
	input               branch_flag_i,
	input[`InstBus]     inst1_i,
	input[`InstBus]     inst2_i,
	input               is_in_delayslot1_i,
	input               is_in_delayslot2_i,
	input               stallreq_from_icache,

	input[`RegBus]           reg1_data_i,
	input[`RegBus]           reg2_data_i,
	input[`RegBus]           reg3_data_i,
	input[`RegBus]           reg4_data_i,

    // 解决数据相关
    input[`RegAddrBus]    ex_waddr1_i,
	input[`RegAddrBus]    ex_waddr2_i,
	input                 ex_we1_i,
	input                 ex_we2_i,
	input[`RegBus]        ex_wdata1_i,
	input[`RegBus]        ex_wdata2_i,
	input[`RegAddrBus]    mem_waddr1_i,
	input[`RegAddrBus]    mem_waddr2_i,
	input                 mem_we1_i,
	input                 mem_we2_i,
	input[`RegBus]        mem_wdata1_i,
	input[`RegBus]        mem_wdata2_i,
	
	// 解决访存相关
	input[`AluOpBus]      ex_aluop1_i,
	
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

	// 送到寄存器堆的信息
	output                    reg1_read_o,
	output                    reg2_read_o,
	output                    reg3_read_o,
	output                    reg4_read_o,
	output[`RegAddrBus]       reg1_raddr_o,
	output[`RegAddrBus]       reg2_raddr_o,
	output[`RegAddrBus]       reg3_raddr_o,
	output[`RegAddrBus]       reg4_raddr_o,    
	
	// 送到执行阶段Ⅰ的信息
	output[`AluOpBus]         aluop1_o,
	output[`AluSelBus]        alusel1_o,
	output[`AluOpBus]         aluop2_o,
	output[`AluSelBus]        alusel2_o,
	output[`RegBus]           reg1_o,
	output[`RegBus]           reg2_o,
	output[`RegBus]           reg3_o,
	output[`RegBus]           reg4_o,
	output[`RegAddrBus]       waddr1_o,
	output[`RegAddrBus]       waddr2_o,
	output                    we1_o,
	output                    we2_o,
	
	// 送给乘法器的信号
	output reg               mul_s,
	
	// HI, LO寄存器最新值
	output reg[`RegBus]           hi_o,
	output reg[`RegBus]           lo_o,
	
	// 同时发射的指令是否存在“写后读”数据相关
	output reg reg3_raw_dependency,
	output reg reg4_raw_dependency,
	
	output[`InstAddrBus]       pc_o,
	output[`InstAddrBus]       npc_o,
	output                     branch_flag_o,
	output                     is_in_delayslot1_o,
	output                     is_in_delayslot2_o,
	
	// 生成的最终立即数，为跳转/分支指令而准备（第一个部件）
	output[`RegBus]            imm_o,
	
	output                     issue_o,
	
	output[`RegAddrBus]        cp0_addr_o,
	
	output[31:0]               exception_type1,
	output[31:0]               exception_type2,
	
	output                     stallreq,
	output                     stallreq_ex_mem
	
);
    
    wire id_sub_2_reg3_read_o;
    wire id_sub_2_reg4_read_o;
    wire[`RegAddrBus] id_sub_2_reg3_raddr_o;
    wire[`RegAddrBus] id_sub_2_reg4_raddr_o;
    wire[`AluOpBus] id_sub_2_aluop_o;
    wire[`AluSelBus] id_sub_2_alusel_o;
    wire[`RegBus] id_sub_2_reg3_o;
    wire[`RegBus] id_sub_2_reg4_o;
    wire[`RegAddrBus] id_sub_2_waddr_o;
    wire id_sub_2_we_o;
    wire[31:0] id_sub_2_exception_type_o;
    reg id_reg3_read_o;
    reg id_reg4_read_o;
    reg[`RegAddrBus] id_reg3_raddr_o;
    reg[`RegAddrBus] id_reg4_raddr_o;
    reg[`AluOpBus] id_aluop2_o;
    reg[`AluSelBus] id_alusel2_o;
    reg[`RegBus] id_reg3_o;
    reg[`RegBus] id_reg4_o;
    reg[`RegAddrBus] id_waddr2_o;
    reg id_we2_o;
    reg[31:0] id_exception_type2_o;
    reg is_j1;
    wire is_load;
    wire reg12_load_dependency;
    wire reg34_load_dependency;
    wire next_inst_in_delayslot;
    wire id2_inst_in_delayslot;
    
    assign pc_o = pc_i;
    assign npc_o = npc_i;
    assign branch_flag_o = branch_flag_i;
    assign is_load = ex_aluop1_i == `EXE_LB_OP || ex_aluop1_i == `EXE_LBU_OP || ex_aluop1_i == `EXE_LH_OP || ex_aluop1_i == `EXE_LHU_OP ||
                     ex_aluop1_i == `EXE_LW_OP || ex_aluop1_i == `EXE_LWR_OP || ex_aluop1_i == `EXE_LWL_OP || ex_aluop1_i == `EXE_LL_OP ||
                     ex_aluop1_i == `EXE_SC_OP;
    assign stallreq = reg12_load_dependency == `LoadDependent || reg34_load_dependency == `LoadDependent ? `Stop : `NoStop;
    assign stallreq_ex_mem = stallreq_from_icache && is_j1 ? `Stop : `NoStop;

    assign is_in_delayslot1_o = is_in_delayslot1_i;
    assign is_in_delayslot2_o = is_in_delayslot2_i;
    
    always @ (*) begin
        if (inst1_i[31:26] == `EXE_SPECIAL_INST && (inst1_i[5:0] == `EXE_JR || inst1_i[5:0] == `EXE_JALR)) is_j1 = 1'b1;
        else if (inst1_i[31:26] == `EXE_REGIMM_INST && (inst1_i[20:16] == `EXE_BLTZ || inst1_i[20:16] == `EXE_BLTZAL || inst1_i[20:16] == `EXE_BGEZ || inst1_i[20:16] == `EXE_BGEZAL)) is_j1 = 1'b1;
        else if (inst1_i[31:26] == `EXE_J || inst1_i[31:26] == `EXE_JAL || inst1_i[31:26] == `EXE_BEQ || inst1_i[31:26] == `EXE_BGTZ || inst1_i[31:26] == `EXE_BLEZ || inst1_i[31:26] == `EXE_BNE) is_j1 = 1'b1;
        else is_j1 = 1'b0;
    end
    
    id_sub u_id_sub_1(
    
        .rst(rst),
        .pc_i(pc_i),
        .inst_i(inst1_i),
        .reg1_data_i(reg1_data_i),
        .reg2_data_i(reg2_data_i),
        
        .ex_waddr1_i(ex_waddr1_i),
	    .ex_waddr2_i(ex_waddr2_i),
	    .ex_we1_i(ex_we1_i),
        .ex_we2_i(ex_we2_i),
        .ex_wdata1_i(ex_wdata1_i),
        .ex_wdata2_i(ex_wdata2_i),
        .mem_waddr1_i(mem_waddr1_i),
        .mem_waddr2_i(mem_waddr2_i),
        .mem_we1_i(mem_we1_i),
        .mem_we2_i(mem_we2_i),
        .mem_wdata1_i(mem_wdata1_i),
        .mem_wdata2_i(mem_wdata2_i),
        
        .is_load(is_load),
        
        .reg1_read_o(reg1_read_o),
        .reg2_read_o(reg2_read_o),
        .reg1_raddr_o(reg1_raddr_o),
        .reg2_raddr_o(reg2_raddr_o),
        
        .aluop_o(aluop1_o),
        .alusel_o(alusel1_o),
        .reg1_o(reg1_o),
        .reg2_o(reg2_o),
        .waddr_o(waddr1_o),
        .we_o(we1_o),
        .cp0_addr_o(cp0_addr_o),
        
        .exception_type(exception_type1),
        
        .imm_o(imm_o),
        
        .load_dependency(reg12_load_dependency)
        
        );
    
    id_sub u_id_sub_2(
    
        .rst(rst),
        .pc_i(pc_i),
        .inst_i(inst2_i),
        .reg1_data_i(reg3_data_i),
        .reg2_data_i(reg4_data_i),
        
        .ex_waddr1_i(ex_waddr1_i),
	    .ex_waddr2_i(ex_waddr2_i),
	    .ex_we1_i(ex_we1_i),
        .ex_we2_i(ex_we2_i),
        .ex_wdata1_i(ex_wdata1_i),
        .ex_wdata2_i(ex_wdata2_i),
        .mem_waddr1_i(mem_waddr1_i),
        .mem_waddr2_i(mem_waddr2_i),
        .mem_we1_i(mem_we1_i),
        .mem_we2_i(mem_we2_i),
        .mem_wdata1_i(mem_wdata1_i),
        .mem_wdata2_i(mem_wdata2_i),
        
        .is_load(is_load),
        
        .reg1_read_o(id_sub_2_reg3_read_o),
        .reg2_read_o(id_sub_2_reg4_read_o),
        .reg1_raddr_o(id_sub_2_reg3_raddr_o),
        .reg2_raddr_o(id_sub_2_reg4_raddr_o),
        
        .aluop_o(id_sub_2_aluop_o),
        .alusel_o(id_sub_2_alusel_o),
        .reg1_o(id_sub_2_reg3_o),
        .reg2_o(id_sub_2_reg4_o),
        .waddr_o(id_sub_2_waddr_o),
        .we_o(id_sub_2_we_o),
        .cp0_addr_o(),
        
        .exception_type(id_sub_2_exception_type_o),
        
        .imm_o(),
        
        .load_dependency(reg34_load_dependency)
        
        );
    
    always @ (*) begin
        if (issue_i == `SingleIssue) begin
            id_reg3_read_o = `ReadDisable;
            id_reg4_read_o = `ReadDisable;
            id_reg3_raddr_o = `NOPRegAddr;
            id_reg4_raddr_o = `NOPRegAddr;
            id_aluop2_o = `EXE_NOP_OP;
            id_alusel2_o = `EXE_RES_NOP;
            id_reg3_o = `ZeroWord;
            id_reg4_o = `ZeroWord;
            id_waddr2_o = `NOPRegAddr;
            id_we2_o = `WriteDisable;
            id_exception_type2_o = 32'b0;
        end else begin
            id_reg3_read_o = id_sub_2_reg3_read_o;
            id_reg4_read_o = id_sub_2_reg4_read_o;
            id_reg3_raddr_o = id_sub_2_reg3_raddr_o;
            id_reg4_raddr_o = id_sub_2_reg4_raddr_o;
            id_aluop2_o = id_sub_2_aluop_o;
            id_alusel2_o = id_sub_2_alusel_o;
            id_reg3_o = id_sub_2_reg3_o;
            id_reg4_o = id_sub_2_reg4_o;
            id_waddr2_o = id_sub_2_waddr_o;
            id_we2_o = id_sub_2_we_o;
            id_exception_type2_o = id_sub_2_exception_type_o;
        end
    end
    
    assign issue_o = issue_i;
    
    assign reg3_read_o = id_reg3_read_o;
    assign reg4_read_o = id_reg4_read_o;
    assign reg3_raddr_o = id_reg3_raddr_o;
    assign reg4_raddr_o = id_reg4_raddr_o;
    assign aluop2_o = id_aluop2_o;
    assign alusel2_o = id_alusel2_o;
    assign reg3_o = id_reg3_o;
    assign reg4_o = id_reg4_o;
    assign waddr2_o = id_waddr2_o;
    assign we2_o = id_we2_o;
    assign exception_type2 = id_exception_type2_o;
    
    always @ (*) begin
        if (rst == `RstEnable || issue_i == `SingleIssue) reg3_raw_dependency = `RAWIndependent;
        else if (reg3_read_o == `ReadEnable && we1_o == `WriteEnable && waddr1_o == reg3_raddr_o) reg3_raw_dependency = `RAWDependent;
        else reg3_raw_dependency = `RAWIndependent;
    end
    
    always @ (*) begin
        if (rst == `RstEnable || issue_i == `SingleIssue) reg4_raw_dependency = `RAWIndependent;
        else if (reg4_read_o == `ReadEnable && we1_o == `WriteEnable && waddr1_o == reg4_raddr_o) reg4_raw_dependency = `RAWDependent;
        else reg4_raw_dependency = `RAWIndependent;
    end
    
    always @ (*) begin
        if (rst == `RstEnable) mul_s = 1'b0;
        else if (inst1_i[31:26] == `EXE_SPECIAL_INST) begin
            case (inst1_i[5:0])
            `EXE_MULT: mul_s = 1'b1;
            `EXE_MULTU: mul_s = 1'b0;
            default: mul_s = 1'b0;
            endcase
        end else if (inst1_i[31:26] == `EXE_SPECIAL2_INST) begin
            case (inst1_i[5:0])
            `EXE_MUL: mul_s = 1'b1;
            `EXE_MADD: mul_s = 1'b1;
            `EXE_MADDU: mul_s = 1'b0;
            `EXE_MSUB: mul_s = 1'b1;
            `EXE_MSUBU: mul_s = 1'b0;
            default:  mul_s = 1'b0;
            endcase
        end else mul_s = 1'b0;
    end
    
    always @ (*) begin
		if (rst == `RstEnable) begin
			{hi_o, lo_o} = {`ZeroWord, `ZeroWord};
		end else if (ex_whilo_i == `WriteEnable) begin
			{hi_o, lo_o} = {ex_hi_i, ex_lo_i};
		end else if (mem_whilo_i == `WriteEnable) begin
			{hi_o, lo_o} = {mem_hi_i, mem_lo_i};
		end else if (commit_whilo_i == `WriteEnable) begin
			{hi_o, lo_o} = {commit_hi_i, commit_lo_i};
		end else begin
			{hi_o, lo_o} = {hi_i, lo_i};
		end
	end

endmodule