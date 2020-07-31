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
	input[`InstBus]     inst1_i,
	input[`InstBus]     inst2_i,
	input[`InstAddrBus] inst1_addr_i,
	input[`InstAddrBus] inst2_addr_i,
	input               issue_en_i,
	input               is_in_delayslot_i,
	
	output[`InstAddrBus]      inst1_addr_o,
	output[`InstAddrBus]      inst2_addr_o,
	output                    reg1_read_o,
	output                    reg2_read_o,
	output                    reg3_read_o,
	output                    reg4_read_o, 
	output[`RegAddrBus]       reg1_raddr_o,
	output[`RegAddrBus]       reg2_raddr_o,
	output[`RegAddrBus]       reg3_raddr_o,
	output[`RegAddrBus]       reg4_raddr_o,
	
	output[`AluOpBus]         aluop1_o,
	output[`AluSelBus]        alusel1_o,
	output[`AluOpBus]         aluop2_o,
	output[`AluSelBus]        alusel2_o,
	output[`RegAddrBus]       waddr1_o,
	output[`RegAddrBus]       waddr2_o,
	output                    we1_o,
	output                    we2_o,
	
	// 送给乘法器的信号
	output reg               mul_s,
	
	output                     is_in_delayslot1_o,
	output                     is_in_delayslot2_o,
	
	// 生成的最终立即数
	output[`RegBus]            imm_fnl1_o,
	output[`RegBus]            imm_fnl2_o,
	
	output                     ninst_in_delayslot,
	
	output[`RegAddrBus]        cp0_addr_o,
	output[2:0]                cp0_sel_o,
	output[31:0]               exception_type1,
	output[31:0]               exception_type2,
	
	// 发射控制
	output reg                     issue_o,
	output reg                     issued_o,
	output reg                     stallreq_from_id
	
	
	
);
    
    wire id_sub_2_reg3_read_o;
    wire id_sub_2_reg4_read_o;
    wire[`RegAddrBus] id_sub_2_reg3_raddr_o;
    wire[`RegAddrBus] id_sub_2_reg4_raddr_o;
    wire[`AluOpBus] id_sub_2_aluop_o;
    wire[`AluSelBus] id_sub_2_alusel_o;
    wire[`RegAddrBus] id_sub_2_waddr_o;
    wire id_sub_2_we_o;
    wire[`RegBus] id_sub_2_imm_fnl_o;
    wire[31:0] id_sub_2_exception_type;
    reg id_reg3_read_o;
    reg id_reg4_read_o;
    reg[`RegAddrBus] id_reg3_raddr_o;
    reg[`RegAddrBus] id_reg4_raddr_o;
    reg[`AluOpBus] id_aluop2_o;
    reg[`AluSelBus] id_alusel2_o;
    reg[`RegAddrBus] id_waddr2_o;
    reg id_we2_o;
    reg[`RegBus] id_imm_fnl2_o;
    reg[31:0] id_exception_type2_o;
    wire next_inst_in_delayslot;
    wire id2_inst_in_delayslot;
    reg reg3_raw_dependency;
    reg reg4_raw_dependency;
    reg hilo_raw_dependency;
    wire is_md1, is_md2, is_jb1, is_jb2, is_ls1, is_ls2, is_cp01, is_cp02;
    wire hilo_re1, hilo_re2, hilo_we1, hilo_we2;
    
    assign id2_inst_in_delayslot = issue_o == `DualIssue ? next_inst_in_delayslot : `NotInDelaySlot;
    assign ninst_in_delayslot = issue_o == `SingleIssue ? next_inst_in_delayslot : `NotInDelaySlot;
    assign is_in_delayslot1_o = is_in_delayslot_i;
    assign is_in_delayslot2_o = issue_o == `DualIssue ? id2_inst_in_delayslot : `NotInDelaySlot;
    
    id_sub u_id_sub_1(
    
        .rst(rst),
        .pc_i(inst1_addr_i),
        .inst_i(inst1_i),
        
        .is_md(is_md1),
        .is_jb(is_jb1),
        .is_ls(is_ls1),
        .is_cp0(is_cp01),
        
        .reg1_read_o(reg1_read_o),
        .reg2_read_o(reg2_read_o),
        .reg1_raddr_o(reg1_raddr_o),
        .reg2_raddr_o(reg2_raddr_o),
        
        .aluop_o(aluop1_o),
        .alusel_o(alusel1_o),
        .waddr_o(waddr1_o),
        .we_o(we1_o),
        .cp0_addr_o(cp0_addr_o),
        .cp0_sel_o(cp0_sel_o),
        .next_inst_in_delayslot(next_inst_in_delayslot),
        
        .hilo_re(hilo_re1),
        .hilo_we(hilo_we1),
        
        .exception_type(exception_type1),
        
        .imm_fnl_o(imm_fnl1_o)
        
        );
    
    id_sub u_id_sub_2(
    
        .rst(rst),
        .pc_i(inst2_addr_i),
        .inst_i(inst2_i),
        
        .is_md(is_md2),
        .is_jb(is_jb2),
        .is_ls(is_ls2),
        .is_cp0(is_cp02),
        
        .reg1_read_o(id_sub_2_reg3_read_o),
        .reg2_read_o(id_sub_2_reg4_read_o),
        .reg1_raddr_o(id_sub_2_reg3_raddr_o),
        .reg2_raddr_o(id_sub_2_reg4_raddr_o),
        
        .aluop_o(id_sub_2_aluop_o),
        .alusel_o(id_sub_2_alusel_o),
        .waddr_o(id_sub_2_waddr_o),
        .we_o(id_sub_2_we_o),
        .cp0_addr_o(),
        .cp0_sel_o(),
        .next_inst_in_delayslot(),
        
        .hilo_re(hilo_re2),
        .hilo_we(hilo_we2),
        
        .exception_type(id_sub_2_exception_type),
        
        .imm_fnl_o(id_sub_2_imm_fnl_o)
        
        );
    
    always @ (*) begin
        if (issue_o == `SingleIssue) begin
            id_reg3_read_o = `ReadDisable;
            id_reg4_read_o = `ReadDisable;
            id_reg3_raddr_o = `NOPRegAddr;
            id_reg4_raddr_o = `NOPRegAddr;
            id_aluop2_o = `EXE_NOP_OP;
            id_alusel2_o = `EXE_RES_NOP;
            id_waddr2_o = `NOPRegAddr;
            id_we2_o = `WriteDisable;
            id_exception_type2_o = `ZeroWord;
            id_imm_fnl2_o = `ZeroWord;
        end else begin
            id_reg3_read_o = id_sub_2_reg3_read_o;
            id_reg4_read_o = id_sub_2_reg4_read_o;
            id_reg3_raddr_o = id_sub_2_reg3_raddr_o;
            id_reg4_raddr_o = id_sub_2_reg4_raddr_o;
            id_aluop2_o = id_sub_2_aluop_o;
            id_alusel2_o = id_sub_2_alusel_o;
            id_waddr2_o = id_sub_2_waddr_o;
            id_we2_o = id_sub_2_we_o;
            id_exception_type2_o = id_sub_2_exception_type;
            id_imm_fnl2_o = id_sub_2_imm_fnl_o;
        end
    end
    
    assign reg3_read_o = id_reg3_read_o;
    assign reg4_read_o = id_reg4_read_o;
    assign reg3_raddr_o = id_reg3_raddr_o;
    assign reg4_raddr_o = id_reg4_raddr_o;
    assign aluop2_o = id_aluop2_o;
    assign alusel2_o = id_alusel2_o;
    assign waddr2_o = id_waddr2_o;
    assign we2_o = id_we2_o;
    assign exception_type2 = id_exception_type2_o;
    assign imm_fnl2_o = id_imm_fnl2_o;
    assign inst1_addr_o = inst1_addr_i;
    assign inst2_addr_o = issue_o == `SingleIssue ? `ZeroWord : inst2_addr_i;
    
    // 给乘法器的信号
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
            default: mul_s = 1'b0;
            endcase
        end else mul_s = 1'b0;
    end
    
    always @ (*) begin
        if (rst == `RstEnable) reg3_raw_dependency = `RAWIndependent;
        else if (id_sub_2_reg3_read_o == `ReadEnable && we1_o == `WriteEnable && waddr1_o == id_sub_2_reg3_raddr_o) reg3_raw_dependency = `RAWDependent;
        else reg3_raw_dependency = `RAWIndependent;
    end
    
    always @ (*) begin
        if (rst == `RstEnable) reg4_raw_dependency = `RAWIndependent;
        else if (id_sub_2_reg4_read_o == `ReadEnable && we1_o == `WriteEnable && waddr1_o == id_sub_2_reg4_raddr_o) reg4_raw_dependency = `RAWDependent;
        else reg4_raw_dependency = `RAWIndependent;
    end
    
    always @ (*) begin
        if (rst == `RstEnable) hilo_raw_dependency = `RAWIndependent;
        else if (hilo_we1 == `WriteEnable && hilo_re2 == `ReadEnable) hilo_raw_dependency = `RAWDependent;
        else hilo_raw_dependency = `RAWIndependent;
    end
    
    // 单发情况：存在乘除指令、存在访存指令、存在CP0指令、第二条指令为跳转指令、第一条指令为延迟槽指令、两条指令存在数据相关、只取出了一条指令
    always @ (*) begin
        if (rst == `RstEnable) issue_o = `DualIssue;
        else if (is_md1 | is_md2 | is_in_delayslot_i | is_jb2 | is_ls1 | is_ls2 | is_cp01 | is_cp02) issue_o = `SingleIssue;
        else if (reg3_raw_dependency == `RAWDependent || reg4_raw_dependency == `RAWDependent || hilo_raw_dependency == `RAWDependent) issue_o = `SingleIssue;
        else issue_o = `DualIssue;
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            issued_o = 1'b0;
            stallreq_from_id = `NoStop;
        end else if (issue_en_i) begin
            issued_o = 1'b1;
            stallreq_from_id = `NoStop;
        end else begin
            issued_o = 1'b0;
            stallreq_from_id = `Stop;
        end
    end

endmodule