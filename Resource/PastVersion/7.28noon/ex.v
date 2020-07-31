//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/24 16:48:43
// Design Name: 
// Module Name: ex1
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

module ex(
	input rst,
	
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
	input                    reg3_raw_dependency,
	input                    reg4_raw_dependency,
	
	input[`DoubleRegBus]     mul_i,
	input[`DoubleRegBus]     div_result_i,
    input                    div_ready_i,
	
	input[`RegBus]           hi_i,
	input[`RegBus]           lo_i,
	
	// 用于跳转和分支
	input[`RegBus]           imm_i,
	input[`InstAddrBus]      pc_i,
	input[`InstAddrBus]      npc_i,
	input                    branch_flag_i,
	input                    issue_i,
	
	input                    is_in_delayslot1_i,
	input                    is_in_delayslot2_i,
	
	// CP0相关
	input[`RegAddrBus]       cp0_addr_i,
	input[`RegBus]           cp0_data_i,
	input                    mem_cp0_we_i,
	input[`RegAddrBus]       mem_cp0_waddr_i,
	input[`RegBus]           mem_cp0_wdata_i,
	input                    commit_cp0_we_i,
	input[`RegAddrBus]       commit_cp0_waddr_i,
	input[`RegBus]           commit_cp0_wdata_i,
	
	input[31:0]              exception_type1_i,
	input[31:0]              exception_type2_i,
	
	output[`RegAddrBus] waddr1_o,
	output[`RegAddrBus] waddr2_o,
    output              we1_o,
    output              we2_o,
    output[`RegBus]     wdata1_o,
    output[`RegBus]     wdata2_o,
    output reg[`RegBus]           hi_o,
	output reg[`RegBus]           lo_o,
	output reg                    whilo_o,
	
	output[`AluOpBus]   aluop1_o,
	output[`RegBus]     mem_addr_o,
	output[`RegBus]     reg2_o,
	output              is_load_o,
	
	output[`InstAddrBus]npc_actual,
	output              branch_flag_actual,
	output              pred_flag,
	output[`SIZE_OF_BRANCH_INFO] branch_info,
	output              issue_mode,
	output              is_in_delayslot1_o,
	output              is_in_delayslot2_o,
	
	output[`RegBus]     div_opdata1_o,
    output[`RegBus]     div_opdata2_o,
    output              div_start_o,
    output              signed_div_o,
    
    output[`RegAddrBus] cp0_raddr_o,
    output              cp0_we_o,
	output[`RegAddrBus] cp0_waddr_o,
	output[`RegBus]     cp0_wdata_o,
	
	output[`InstAddrBus]pc_o,
	output[31:0]        exception_type1_o,
	output[31:0]        exception_type2_o,
    
    output              stallreq

);

    // 解决同时发射的两条指令的数据相关问题
    wire[`RegBus] reg3_fnl;
    wire[`RegBus] reg4_fnl;
    wire[`RegBus] ex_sub_1_hi_o;
    wire[`RegBus] ex_sub_1_lo_o;
    wire ex_sub_1_whilo_o;
    wire[`RegBus] ex_sub_2_hi_o;
    wire[`RegBus] ex_sub_2_lo_o;
    wire ex_sub_2_whilo_o;
	reg[`RegBus] ex_sub_2_hi_i;
	reg[`RegBus] ex_sub_2_lo_i;
	
    assign reg3_fnl = reg3_raw_dependency ? wdata1_o : reg3_i;
    assign reg4_fnl = reg4_raw_dependency ? wdata1_o : reg4_i;
    assign issue_mode = issue_i;
    assign is_in_delayslot1_o = is_in_delayslot1_i;
    assign is_in_delayslot2_o = is_in_delayslot2_i;
    assign pc_o = pc_i;

    ex_sub u_ex_sub_1(
            .rst(rst),
            .aluop_i(aluop1_i),
            .alusel_i(alusel1_i),
            .reg1_i(reg1_i),
            .reg2_i(reg2_i),
            .waddr_i(waddr1_i),
            .we_i(we1_i),
            .hi_i(hi_i),
            .lo_i(lo_i),
            .mul_i(mul_i),
            .div_result_i(div_result_i),
            .div_ready_i(div_ready_i),
            .imm_i(imm_i),
            .pc_i(pc_i),
            .npc_i(npc_i),
            .branch_flag_i(branch_flag_i),
            .cp0_addr_i(cp0_addr_i),
            .cp0_data_i(cp0_data_i),
            .mem_cp0_we_i(mem_cp0_we_i),
            .mem_cp0_waddr_i(mem_cp0_waddr_i),
            .mem_cp0_wdata_i(mem_cp0_wdata_i),
            .commit_cp0_we_i(commit_cp0_we_i),
            .commit_cp0_waddr_i(commit_cp0_waddr_i),
            .commit_cp0_wdata_i(commit_cp0_wdata_i),
            .exception_type_i(exception_type1_i),
            .waddr_o(waddr1_o),
            .we_o(we1_o),
            .wdata_o(wdata1_o),
            .hi_o(ex_sub_1_hi_o),
            .lo_o(ex_sub_1_lo_o),
            .whilo_o(ex_sub_1_whilo_o),
            .div_opdata1_o(div_opdata1_o),
            .div_opdata2_o(div_opdata2_o),
            .div_start_o(div_start_o),
            .signed_div_o(signed_div_o),
            .npc_actual(npc_actual),
            .branch_flag_actual(branch_flag_actual),
            .pred_flag(pred_flag),
            .branch_info(branch_info),
            .cp0_raddr_o(cp0_raddr_o),
            .cp0_we_o(cp0_we_o),
            .cp0_waddr_o(cp0_waddr_o),
            .cp0_wdata_o(cp0_wdata_o),
            .exception_type_o(exception_type1_o),
            .stallreq(stallreq)
        );
    
    // 检测两个执行子部件之间HI, LO寄存器的数据相关
    always @ (*) begin
        if (ex_sub_1_whilo_o == `WriteEnable) begin
            ex_sub_2_hi_i = ex_sub_1_hi_o;
            ex_sub_2_lo_i = ex_sub_1_lo_o;
        end else begin
            ex_sub_2_hi_i = hi_i;
            ex_sub_2_lo_i = lo_i;
        end
    end
        
    ex_sub_2 u_ex_sub_2(
            .rst(rst),
            .aluop_i(aluop2_i),
            .alusel_i(alusel2_i),
            .reg1_i(reg3_fnl),
            .reg2_i(reg4_fnl),
            .waddr_i(waddr2_i),
            .we_i(we2_i),
            .hi_i(ex_sub_2_hi_i),
            .lo_i(ex_sub_2_lo_i),
            .exception_type_i(exception_type2_i),
            .waddr_o(waddr2_o),
            .we_o(we2_o),
            .wdata_o(wdata2_o),
            .hi_o(ex_sub_2_hi_o),
            .lo_o(ex_sub_2_lo_o),
            .whilo_o(ex_sub_2_whilo_o),
            .exception_type_o(exception_type2_o)
        );
        
    always @ (*) begin
        if (rst == `RstEnable) begin
            whilo_o = `WriteDisable;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
        end else if (ex_sub_2_whilo_o == `WriteEnable) begin
            whilo_o = `WriteEnable;
            hi_o = ex_sub_2_hi_o;
            lo_o = ex_sub_2_lo_o;
        end else if (ex_sub_1_whilo_o == `WriteEnable) begin
            whilo_o = `WriteEnable;
            hi_o = ex_sub_1_hi_o;
            lo_o = ex_sub_1_lo_o;
        end else begin
            whilo_o = `WriteDisable;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
        end
    end
    
    // 访存相关信息
    assign aluop1_o = aluop1_i;
    assign mem_addr_o = reg1_i + imm_i;
    assign reg2_o = reg2_i;

endmodule