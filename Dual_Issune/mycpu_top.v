`include "defines.v"

module mycpu_top(

	input wire      aclk,
	input wire      aresetn,
	
    input wire[5:0] ext_int,
    
    //axi
    //ar
    output [3 :0] arid         ,
    output [31:0] araddr       ,
    output [7 :0] arlen        ,
    output [2 :0] arsize       ,
    output [1 :0] arburst      ,
    output [1 :0] arlock       ,
    output [3 :0] arcache      ,
    output [2 :0] arprot       ,
    output        arvalid      ,
    input         arready      ,
    //r           
    input  [3 :0] rid          ,
    input  [31:0] rdata        ,
    input  [1 :0] rresp        ,
    input         rlast        ,
    input         rvalid       ,
    output        rready       ,
    //aw          
    output [3 :0] awid         ,
    output [31:0] awaddr       ,
    output [7 :0] awlen        ,
    output [2 :0] awsize       ,
    output [1 :0] awburst      ,
    output [1 :0] awlock       ,
    output [3 :0] awcache      ,
    output [2 :0] awprot       ,
    output        awvalid      ,
    input         awready      ,
    //w          
    output [3 :0] wid          ,
    output [31:0] wdata        ,
    output [3 :0] wstrb        ,
    output        wlast        ,
    output        wvalid       ,
    input         wready       ,
    //b           
    input  [3 :0] bid          ,
    input  [1 :0] bresp        ,
    input         bvalid       ,
    output        bready       ,
    /*
    //指令类sram接口
	input wire[`RegBus]            isram_data_i,
	input wire                     isram_data_ok_i,
    input wire                     isram_addr_ok_i,
	output wire[`RegBus]           isram_addr_o,
	output wire[`RegBus]           isram_data_o,
	output wire                    isram_we_o,
	output wire                    isram_req_o,
	output wire[1:0]               isram_size_o,
	//output wire[3:0]               isram_sel_o,
	//output wire                    isram_stb_o,
	//output wire                    isram_cyc_o, 
	
    //数据类sram接口
	input wire[`RegBus]            dsram_data_i,
	input wire                     dsram_data_ok_i,
	input wire                     dsram_addr_ok_i,
	output wire[`RegBus]           dsram_addr_o,
	output wire[`RegBus]           dsram_data_o,
	output wire                    dsram_we_o,
	output wire                    dsram_req_o,
	output wire[1:0]               dsram_size_o,
	//output wire[3:0]               dsram_sel_o,
	//output wire                    dsram_stb_o,
	//output wire                    dsram_cyc_o,*/
	
	output wire                    timer_int_o,
	
	//func_test
	/*
	output wire                    inst_sram_en,
	output wire[3:0]               inst_sram_wen,
	output wire[`RegBus]           inst_sram_addr,
	output wire[`RegBus]           inst_sram_wdata,
	input wire[`RegBus]            inst_sram_rdata,
	
	output wire                    data_sram_en,
	output wire[3:0]               data_sram_wen,
	output wire[`RegBus]           data_sram_addr,
	output wire[`RegBus]           data_sram_wdata,
	input wire[`RegBus]            data_sram_rdata,*/
	
	//debug
	output wire[`InstAddrBus]           debug_wb_pc,
	output wire[3:0]                    debug_wb_rf_wen,
	output wire[4:0]                    debug_wb_rf_wnum,
	output wire[`RegBus]                debug_wb_rf_wdata
);   
	
	wire[`InstAddrBus] pc;
	wire[`InstBus] inst_i;	
	wire[`InstAddrBus] id_pc_i;
	wire[`InstBus] id_inst_i;
	
	//连接译码阶段ID模块的输出与ID/EX模块的输入
	wire[`AluOpBus] id_aluop_o;
	wire[`AluSelBus] id_alusel_o;
	wire[`RegBus] id_reg1_o;
	wire[`RegBus] id_reg2_o;
	wire id_wreg_o;
	wire[`RegAddrBus] id_wd_o;
	wire id_is_in_delayslot_o;
    wire[`RegBus] id_link_address_o;	
    wire[`RegBus] id_inst_o;
    wire[31:0] id_excepttype_o;
    wire[`RegBus] id_current_inst_address_o;
	
	//连接ID/EX模块的输出与执行阶段EX模块的输入
	wire[`AluOpBus] ex_aluop_i;
	wire[`AluSelBus] ex_alusel_i;
	wire[`RegBus] ex_reg1_i;
	wire[`RegBus] ex_reg2_i;
	wire ex_wreg_i;
	wire[`RegAddrBus] ex_wd_i;
	wire ex_is_in_delayslot_i;	
    wire[`RegBus] ex_link_address_i;	
    wire[`RegBus] ex_inst_i;
    wire[31:0] ex_excepttype_i;	
    wire[`RegBus] ex_current_inst_address_i;	
	
	//连接执行阶段EX模块的输出与EX/MEM模块的输入
	wire ex_wreg_o;
	wire[`RegAddrBus] ex_wd_o;
	wire[`RegBus] ex_wdata_o;
	wire[`RegBus] ex_hi_o;
	wire[`RegBus] ex_lo_o;
	wire ex_whilo_o;
	wire[`AluOpBus] ex_aluop_o;
	wire[`RegBus] ex_mem_addr_o;
	wire[`RegBus] ex_reg2_o;
	wire ex_cp0_reg_we_o;
	wire[4:0] ex_cp0_reg_write_addr_o;
	wire[`RegBus] ex_cp0_reg_data_o; 	
	wire[31:0] ex_excepttype_o;
	wire[`RegBus] ex_current_inst_address_o;
	wire ex_is_in_delayslot_o;

	//连接EX/MEM模块的输出与访存阶段MEM模块的输入
	wire mem_wreg_i;
	wire[`RegAddrBus] mem_wd_i;
	wire[`RegBus] mem_wdata_i;
	wire[`RegBus] mem_hi_i;
	wire[`RegBus] mem_lo_i;
	wire mem_whilo_i;		
	wire[`AluOpBus] mem_aluop_i;
	wire[`RegBus] mem_mem_addr_i;
	wire[`RegBus] mem_reg2_i;		
	wire mem_cp0_reg_we_i;
	wire[4:0] mem_cp0_reg_write_addr_i;
	wire[`RegBus] mem_cp0_reg_data_i;	
	wire[31:0] mem_excepttype_i;	
	wire mem_is_in_delayslot_i;
	wire[`RegBus] mem_current_inst_address_i;	

	//连接访存阶段MEM模块的输出与MEM/WB模块的输入
	wire mem_wreg_o;
	wire[`RegAddrBus] mem_wd_o;
	wire[`RegBus] mem_wdata_o;
	wire[`RegBus] mem_hi_o;
	wire[`RegBus] mem_lo_o;
	wire mem_whilo_o;	
	wire mem_LLbit_value_o;
	wire mem_LLbit_we_o;
	wire mem_cp0_reg_we_o;
	wire[4:0] mem_cp0_reg_write_addr_o;
	wire[`RegBus] mem_cp0_reg_data_o;	
	wire[31:0] mem_excepttype_o;
	wire mem_is_in_delayslot_o;
	wire[`RegBus] mem_current_inst_address_o;			
	
	//连接MEM/WB模块的输出与回写阶段的输入	
	wire wb_wreg_i;
	wire[`RegAddrBus] wb_wd_i;
	wire[`RegBus] wb_wdata_i;
	wire[`RegBus] wb_hi_i;
	wire[`RegBus] wb_lo_i;
	wire wb_whilo_i;	
	wire wb_LLbit_value_i;
	wire wb_LLbit_we_i;	
	wire wb_cp0_reg_we_i;
	wire[4:0] wb_cp0_reg_write_addr_i;
	wire[`RegBus] wb_cp0_reg_data_i;		
	wire[31:0] wb_excepttype_i;
	wire wb_is_in_delayslot_i;
	wire[`RegBus] wb_current_inst_address_i;
	
	//连接译码阶段ID模块与通用寄存器Regfile模块
    wire reg1_read;
    wire reg2_read;
    wire[`RegBus] reg1_data;
    wire[`RegBus] reg2_data;
    wire[`RegAddrBus] reg1_addr;
    wire[`RegAddrBus] reg2_addr;

	//连接执行阶段与hilo模块的输出，读取HI、LO寄存器
	wire[`RegBus]  hi;
	wire[`RegBus]  lo;

  //连接执行阶段与ex_reg模块，用于多周期的MADD、MADDU、MSUB、MSUBU指令
	wire[`DoubleRegBus] hilo_temp_o;
	wire[1:0] cnt_o;
	
	wire[`DoubleRegBus] hilo_temp_i;
	wire[1:0] cnt_i;

	wire[`DoubleRegBus] div_result;
	wire div_ready;
	wire[`RegBus] div_opdata1;
	wire[`RegBus] div_opdata2;
	wire div_start;
	wire div_annul;
	wire signed_div;

	wire is_in_delayslot_i;
	wire is_in_delayslot_o;
	wire next_inst_in_delayslot_o;
	wire id_branch_flag_o;
	wire[`RegBus] branch_target_address;

	wire[5:0] stall;
	wire stallreq_from_ex;
	wire stallreq_from_id;
    wire stallreq_from_if;
	wire stallreq_from_mem;

	wire LLbit_o;

    wire[`RegBus] cp0_data_o;
    wire[4:0] cp0_raddr_i;
 
    wire flush;
    wire[`RegBus] new_pc;

	wire[`RegBus] cp0_count;
	wire[`RegBus]	cp0_compare;
	wire[`RegBus]	cp0_status;
	wire[`RegBus]	cp0_cause;
	wire[`RegBus]	cp0_epc;
	wire[`RegBus]	cp0_config;
	wire[`RegBus]	cp0_prid; 

    wire[`RegBus] latest_epc;

	wire rom_ce;

	wire[31:0] ram_addr_o;
	wire ram_we_o;
    wire[3:0] ram_sel_o;
	wire[`RegBus] ram_data_o;
	wire ram_ce_o;
    wire[`RegBus] ram_data_i;
    
    //指令类sram接口
	wire[`RegBus]           isram_data_i;
	wire                    isram_data_ok_i;
    wire                    isram_addr_ok_i;
	wire[`RegBus]           isram_addr_o;
	wire[`RegBus]           isram_data_o;
	wire                    isram_we_o;
	wire                    isram_req_o;
	wire[1:0]               isram_size_o;
	
    //数据类sram接口
	wire[`RegBus]           dsram_data_i;
	wire                    dsram_data_ok_i;
	wire                    dsram_addr_ok_i;
	wire[`RegBus]           dsram_addr_o;
	wire[`RegBus]           dsram_data_o;
	wire                    dsram_we_o;
	wire                    dsram_req_o;
	wire[1:0]               dsram_size_o;  
    
    //类SRAMCPU侧信号
    wire                    inst_sram_en;
	wire[3:0]               inst_sram_wen;
	wire[`RegBus]           inst_sram_addr;
	wire[`RegBus]           inst_sram_wdata;
	wire[`RegBus]           inst_sram_rdata;
	
	wire                    data_sram_en;
	wire[3:0]               data_sram_wen;
	wire[`RegBus]           data_sram_addr;
	wire[`RegBus]           data_sram_wdata;
	wire[`RegBus]           data_sram_rdata;
   
    //inst_sram
    assign inst_sram_en = rom_ce;
    assign inst_sram_wen = `WEN_DISABLE;
    //虚拟地址映射
    assign inst_sram_addr = 
            (pc[31:28]==4'h8)||(pc[31:28]==4'h9)||(pc[31:28]==4'ha)||(pc[31:28]==4'hb)? pc & {3'b0,29'h1fffffff}: pc ;
    assign inst_sram_wdata = `ZeroWord;
    
     //data_sram
    assign data_sram_en = ram_ce_o;
    assign data_sram_wen = ram_sel_o & {4{ram_we_o}};
    //虚拟地址映射
    assign data_sram_addr = 
            (ram_addr_o[31:28]==4'h8)||(ram_addr_o[31:28]==4'h9)||(ram_addr_o[31:28]==4'ha)||(ram_addr_o[31:28]==4'hb)? ram_addr_o & {3'b0,29'h1fffffff}: ram_addr_o;
    assign data_sram_wdata = ram_data_o;
   
     
    //debug////////////////////////////////////////////
    assign debug_wb_rf_wen = {4{wb_wreg_i}};
    assign debug_wb_rf_wnum = wb_wd_i;
    assign debug_wb_rf_wdata = wb_wdata_i;
  
    //pc_reg例化
	pc_reg pc_reg0(
		.clk(aclk),
		.rst(aresetn),
		.stall(stall),
		.flush(flush),
	    .new_pc(new_pc),
		.branch_flag_i(id_branch_flag_o),
		.branch_target_address_i(branch_target_address),		
		.pc(pc),
		.ce(rom_ce)					
			
	);
	
  //IF/ID模块例化
	if_id if_id0(
		.clk(aclk),
		.rst(aresetn),
		.stall(stall),
		.flush(flush),
		.if_pc(pc),
		.if_inst(inst_i),
		.id_pc(id_pc_i),
		.id_inst(id_inst_i)      	
	);
	
	//译码阶段ID模块
	id id0(
		.rst(aresetn),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),

  	.ex_aluop_i(ex_aluop_o),

		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),

	  //处于执行阶段的指令要写入的目的寄存器信息
		.ex_wreg_i(ex_wreg_o),
		.ex_wdata_i(ex_wdata_o),
		.ex_wd_i(ex_wd_o),

	  //处于访存阶段的指令要写入的目的寄存器信息
		.mem_wreg_i(mem_wreg_o),
		.mem_wdata_i(mem_wdata_o),
		.mem_wd_i(mem_wd_o),

	  .is_in_delayslot_i(is_in_delayslot_i),

		//送到regfile的信息
		.reg1_read_o(reg1_read),
		.reg2_read_o(reg2_read), 	  

		.reg1_addr_o(reg1_addr),
		.reg2_addr_o(reg2_addr), 
	  
		//送到ID/EX模块的信息
		.aluop_o(id_aluop_o),
		.alusel_o(id_alusel_o),
		.reg1_o(id_reg1_o),
		.reg2_o(id_reg2_o),
		.wd_o(id_wd_o),
		.wreg_o(id_wreg_o),
		.excepttype_o(id_excepttype_o),
		.inst_o(id_inst_o),

	 	.next_inst_in_delayslot_o(next_inst_in_delayslot_o),	
		.branch_flag_o(id_branch_flag_o),
		.branch_target_address_o(branch_target_address),       
		.link_addr_o(id_link_address_o),
		
		.is_in_delayslot_o(id_is_in_delayslot_o),
		.current_inst_address_o(id_current_inst_address_o),
		
		.stallreq(stallreq_from_id)		
	);

  //通用寄存器Regfile例化
	regfile regfile1(
		.clk (aclk),
		.rst (aresetn),
		.we	(wb_wreg_i),
		.waddr (wb_wd_i),
		.wdata (wb_wdata_i),
		.re1 (reg1_read),
		.raddr1 (reg1_addr),
		.rdata1 (reg1_data),
		.re2 (reg2_read),
		.raddr2 (reg2_addr),
		.rdata2 (reg2_data)
	);

	//ID/EX模块
	id_ex id_ex0(
		.clk(aclk),
		.rst(aresetn),
		
		.stall(stall),
		.flush(flush),
		
		//从译码阶段ID模块传递的信息
		.id_aluop(id_aluop_o),
		.id_alusel(id_alusel_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),
		.id_link_address(id_link_address_o),
		.id_is_in_delayslot(id_is_in_delayslot_o),
		.next_inst_in_delayslot_i(next_inst_in_delayslot_o),		
		.id_inst(id_inst_o),		
		.id_excepttype(id_excepttype_o),
		.id_current_inst_address(id_current_inst_address_o),
	
		//传递到执行阶段EX模块的信息
		.ex_aluop(ex_aluop_i),
		.ex_alusel(ex_alusel_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),
		.ex_link_address(ex_link_address_i),
  	.ex_is_in_delayslot(ex_is_in_delayslot_i),
		.is_in_delayslot_o(is_in_delayslot_i),
		.ex_inst(ex_inst_i),
		.ex_excepttype(ex_excepttype_i),
		.ex_current_inst_address(ex_current_inst_address_i)		
	);		
	
	//EX模块
	ex ex0(
		.rst(aresetn),
	
		//送到执行阶段EX模块的信息
		.aluop_i(ex_aluop_i),
		.alusel_i(ex_alusel_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),
		.hi_i(hi),
		.lo_i(lo),
		.inst_i(ex_inst_i),

	  .wb_hi_i(wb_hi_i),
	  .wb_lo_i(wb_lo_i),
	  .wb_whilo_i(wb_whilo_i),
	  .mem_hi_i(mem_hi_o),
	  .mem_lo_i(mem_lo_o),
	  .mem_whilo_i(mem_whilo_o),

	  .hilo_temp_i(hilo_temp_i),
	  .cnt_i(cnt_i),

		.div_result_i(div_result),
		.div_ready_i(div_ready), 

	  .link_address_i(ex_link_address_i),
		.is_in_delayslot_i(ex_is_in_delayslot_i),	  
		
		.excepttype_i(ex_excepttype_i),
		.current_inst_address_i(ex_current_inst_address_i),

		//访存阶段的指令是否要写CP0，用来检测数据相关
  	.mem_cp0_reg_we(mem_cp0_reg_we_o),
		.mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
		.mem_cp0_reg_data(mem_cp0_reg_data_o),
	
		//回写阶段的指令是否要写CP0，用来检测数据相关
  	.wb_cp0_reg_we(wb_cp0_reg_we_i),
		.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
		.wb_cp0_reg_data(wb_cp0_reg_data_i),

		.cp0_reg_data_i(cp0_data_o),
		.cp0_reg_read_addr_o(cp0_raddr_i),
		
		//向下一流水级传递，用于写CP0中的寄存器
		.cp0_reg_we_o(ex_cp0_reg_we_o),
		.cp0_reg_write_addr_o(ex_cp0_reg_write_addr_o),
		.cp0_reg_data_o(ex_cp0_reg_data_o),	  
			  
	  //EX模块的输出到EX/MEM模块信息
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),

		.hi_o(ex_hi_o),
		.lo_o(ex_lo_o),
		.whilo_o(ex_whilo_o),

		.hilo_temp_o(hilo_temp_o),
		.cnt_o(cnt_o),

		.div_opdata1_o(div_opdata1),
		.div_opdata2_o(div_opdata2),
		.div_start_o(div_start),
		.signed_div_o(signed_div),	

		.aluop_o(ex_aluop_o),
		.mem_addr_o(ex_mem_addr_o),
		.reg2_o(ex_reg2_o),
		
		.excepttype_o(ex_excepttype_o),
		.is_in_delayslot_o(ex_is_in_delayslot_o),
		.current_inst_address_o(ex_current_inst_address_o),	
		
		.stallreq(stallreq_from_ex)     				
		
	);

  //EX/MEM模块
  ex_mem ex_mem0(
		.clk(aclk),
		.rst(aresetn),
	  
	  .stall(stall),
	  .flush(flush),
	  
		//来自执行阶段EX模块的信息	
		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),
		.ex_hi(ex_hi_o),
		.ex_lo(ex_lo_o),
		.ex_whilo(ex_whilo_o),		

  	.ex_aluop(ex_aluop_o),
		.ex_mem_addr(ex_mem_addr_o),
		.ex_reg2(ex_reg2_o),			
	
		.ex_cp0_reg_we(ex_cp0_reg_we_o),
		.ex_cp0_reg_write_addr(ex_cp0_reg_write_addr_o),
		.ex_cp0_reg_data(ex_cp0_reg_data_o),	

    .ex_excepttype(ex_excepttype_o),
		.ex_is_in_delayslot(ex_is_in_delayslot_o),
		.ex_current_inst_address(ex_current_inst_address_o),	

		.hilo_i(hilo_temp_o),
		.cnt_i(cnt_o),	

		//送到访存阶段MEM模块的信息
		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i),
		.mem_hi(mem_hi_i),
		.mem_lo(mem_lo_i),
		.mem_whilo(mem_whilo_i),
	
		.mem_cp0_reg_we(mem_cp0_reg_we_i),
		.mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_i),
		.mem_cp0_reg_data(mem_cp0_reg_data_i),

  	.mem_aluop(mem_aluop_i),
		.mem_mem_addr(mem_mem_addr_i),
		.mem_reg2(mem_reg2_i),
		
		.mem_excepttype(mem_excepttype_i),
  	.mem_is_in_delayslot(mem_is_in_delayslot_i),
		.mem_current_inst_address(mem_current_inst_address_i),
				
		.hilo_o(hilo_temp_i),
		.cnt_o(cnt_i)
						       	
	);
	
  //MEM模块例化
	mem mem0(
		.rst(aresetn),
	
		//来自EX/MEM模块的信息	
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),
		.wdata_i(mem_wdata_i),
		.hi_i(mem_hi_i),
		.lo_i(mem_lo_i),
		.whilo_i(mem_whilo_i),		

  	    .aluop_i(mem_aluop_i),
		.mem_addr_i(mem_mem_addr_i),
		.reg2_i(mem_reg2_i),
	
		//来自memory的信息
		.mem_data_i(ram_data_i),

		//LLbit_i是LLbit寄存器的值
		.LLbit_i(LLbit_o),
		//但不一定是最新值，回写阶段可能要写LLbit，所以还要进一步判断
		.wb_LLbit_we_i(wb_LLbit_we_i),
		.wb_LLbit_value_i(wb_LLbit_value_i),

		.cp0_reg_we_i(mem_cp0_reg_we_i),
		.cp0_reg_write_addr_i(mem_cp0_reg_write_addr_i),
		.cp0_reg_data_i(mem_cp0_reg_data_i),

    .excepttype_i(mem_excepttype_i),
		.is_in_delayslot_i(mem_is_in_delayslot_i),
		.current_inst_address_i(mem_current_inst_address_i),	
		
		.cp0_status_i(cp0_status),
		.cp0_cause_i(cp0_cause),
		.cp0_epc_i(cp0_epc),
		
		//回写阶段的指令是否要写CP0，用来检测数据相关
  	.wb_cp0_reg_we(wb_cp0_reg_we_i),
		.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
		.wb_cp0_reg_data(wb_cp0_reg_data_i),	  

		.LLbit_we_o(mem_LLbit_we_o),
		.LLbit_value_o(mem_LLbit_value_o),

		.cp0_reg_we_o(mem_cp0_reg_we_o),
		.cp0_reg_write_addr_o(mem_cp0_reg_write_addr_o),
		.cp0_reg_data_o(mem_cp0_reg_data_o),			
	  
		//送到MEM/WB模块的信息
		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o),
		.hi_o(mem_hi_o),
		.lo_o(mem_lo_o),
		.whilo_o(mem_whilo_o),
		
		//送到memory的信息
		.mem_addr_o(ram_addr_o),
		.mem_we_o(ram_we_o),
		.mem_sel_o(ram_sel_o),
		.mem_data_o(ram_data_o),
		.mem_ce_o(ram_ce_o),
		
		.excepttype_o(mem_excepttype_o),
		.cp0_epc_o(latest_epc),
		.is_in_delayslot_o(mem_is_in_delayslot_o),
		.current_inst_address_o(mem_current_inst_address_o)		
	);

  //MEM/WB模块
	mem_wb mem_wb0(
		.clk(aclk),
		.rst(aresetn),

    .stall(stall),
    .flush(flush),

		//来自访存阶段MEM模块的信息	
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
		.mem_hi(mem_hi_o),
		.mem_lo(mem_lo_o),
		.mem_whilo(mem_whilo_o),		
		.mem_current_inst_address(mem_current_inst_address_o),/////

		.mem_LLbit_we(mem_LLbit_we_o),
		.mem_LLbit_value(mem_LLbit_value_o),	
	
		.mem_cp0_reg_we(mem_cp0_reg_we_o),
		.mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
		.mem_cp0_reg_data(mem_cp0_reg_data_o),					
	
		//送到回写阶段的信息
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i),
		.wb_hi(wb_hi_i),
		.wb_lo(wb_lo_i),
		.wb_whilo(wb_whilo_i),
        .wb_current_inst_address(debug_wb_pc),///////////
        
		.wb_LLbit_we(wb_LLbit_we_i),
		.wb_LLbit_value(wb_LLbit_value_i),
		
		.wb_cp0_reg_we(wb_cp0_reg_we_i),
		.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
		.wb_cp0_reg_data(wb_cp0_reg_data_i)						
									       	
	);

	hilo_reg hilo_reg0(
		.clk(aclk),
		.rst(aresetn),
	
		//写端口
		.we(wb_whilo_i),
		.hi_i(wb_hi_i),
		.lo_i(wb_lo_i),
	
		//读端口1
		.hi_o(hi),
		.lo_o(lo)	
	);
	
	ctrl ctrl0(
		.rst(aresetn),
	
	    .excepttype_i(mem_excepttype_o),
	    .cp0_epc_i(latest_epc),
 
        .stallreq_from_if(stallreq_from_if),	  
		.stallreq_from_id(stallreq_from_id),
	
  	//来自执行阶段的暂停请求
		.stallreq_from_ex(stallreq_from_ex),
		.stallreq_from_mem(stallreq_from_mem),
	    .new_pc(new_pc),
	    .flush(flush),
		.stall(stall)       	
	);

	div div0(
		.clk(aclk),
		.rst(aresetn),
	
		.signed_div_i(signed_div),
		.opdata1_i(div_opdata1),
		.opdata2_i(div_opdata2),
		.start_i(div_start),
		.annul_i(flush),
	
		.result_o(div_result),
		.ready_o(div_ready)
	);

	LLbit_reg LLbit_reg0(
		.clk(aclk),
		.rst(aresetn),
	  .flush(flush),
	  
		//写端口
		.LLbit_i(wb_LLbit_value_i),
		.we(wb_LLbit_we_i),
	
		//读端口1
		.LLbit_o(LLbit_o)
	
	);

	cp0_reg cp0_reg0(
		.clk(aclk),
		.rst(aresetn),
		
		.we_i(wb_cp0_reg_we_i),
		.waddr_i(wb_cp0_reg_write_addr_i),
		.raddr_i(cp0_raddr_i),
		.data_i(wb_cp0_reg_data_i),
		
		.excepttype_i(mem_excepttype_o),
		.int_i(ext_int),
		.current_inst_addr_i(mem_current_inst_address_o),
		.is_in_delayslot_i(mem_is_in_delayslot_o),
		.mem_addr_i(ram_addr_o),
		
		.data_o(cp0_data_o),
		.count_o(cp0_count),
		.compare_o(cp0_compare),
		.status_o(cp0_status),
		.cause_o(cp0_cause),
		.epc_o(cp0_epc),
		.config_o(cp0_config),
		.prid_o(cp0_prid),
		
		
		.timer_int_o(timer_int_o)  			
	);
   
   
	sram_expanded_bus dsram_bus_if(
		.clk(aclk),
		.rst(aresetn),
	
		//来自控制模块ctrl
		.stall_i(stall),
		.flush_i(flush),

	
		//CPU侧读写操作信息
		.cpu_ce_i(ram_ce_o),
		.cpu_wdata_i(ram_data_o),
		.cpu_addr_i(data_sram_addr),
		.cpu_wr_i(ram_we_o),
		.cpu_sel_i(ram_sel_o),
		.cpu_rdata_o(ram_data_i),
	
		//SRAM侧接口
		.sram_rdata_i(dsram_data_i),
		.sram_data_ok_i(dsram_data_ok_i),
		.sram_addr_ok_i(dsram_addr_ok_i),///////////////
		.sram_addr_o(dsram_addr_o),
		.sram_wdata_o(dsram_data_o),
		.sram_wr_o(dsram_we_o),
		.req(dsram_req_o),///////
		.size(dsram_size_o),//////
		//.sram_sel_o(dsram_sel_o),
		//.sram_stb_o(dsram_stb_o),
		//.sram_cyc_o(dsram_cyc_o),

		.stallreq(stallreq_from_mem)	       
	
    );

	sram_expanded_bus isram_bus_if(
		.clk(aclk),
		.rst(aresetn),
	
		//来自控制模块ctrl
		.stall_i(stall),
		.flush_i(flush),
	
		//CPU侧读写操作信息
		.cpu_ce_i(rom_ce),
		.cpu_wdata_i(32'h00000000),
		.cpu_addr_i(inst_sram_addr),
		.cpu_wr_i(1'b0),
		.cpu_sel_i(4'b1111),
		.cpu_rdata_o(inst_i),
	
		//类sram侧接口
		.sram_rdata_i(isram_data_i),
		.sram_data_ok_i(isram_data_ok_i),
		.sram_addr_ok_i(isram_addr_ok_i),////////////
		.sram_addr_o(isram_addr_o),
		.sram_wdata_o(isram_data_o),
		.sram_wr_o(isram_we_o),
		.req(isram_req_o),///////
		.size(isram_size_o),//////
		//.sram_sel_o(isram_sel_o),
		//.sram_stb_o(isram_stb_o),
		//.sram_cyc_o(isram_cyc_o),

		.stallreq(stallreq_from_if)	       
	
    );
    
    
    //类SRAM-AXI转换桥
    cpu_axi_interface axi_interface0(
        .clk(aclk),
        .resetn(aresetn & (!flush)), 

    //inst sram-like 
        .inst_req(isram_req_o)      ,
        .inst_wr(isram_we_o)        ,
        .inst_size(isram_size_o)    ,
        .inst_addr(isram_addr_o)    ,
        .inst_wdata(isram_data_o)   ,
        .inst_rdata(isram_data_i)   ,
        .inst_addr_ok(isram_addr_ok_i) ,
        .inst_data_ok(isram_data_ok_i) ,
    
    //data sram-like 
        .data_req(dsram_req_o)     ,
        .data_wr(dsram_we_o)       ,
        .data_size(dsram_size_o)    ,
        .data_addr(dsram_addr_o)    ,
        .data_wdata(dsram_data_o)   ,
        .data_rdata(dsram_data_i)   ,
        .data_addr_ok(dsram_addr_ok_i) ,
        .data_data_ok(dsram_data_ok_i) ,

    //axi
    //ar
        .arid(arid)         ,
        .araddr(araddr)     ,
        .arlen(arlen)       ,
        .arsize(arsize)     ,
        .arburst(arburst)   ,
        .arlock(arclock)    ,
        .arcache(arcache)   ,
        .arprot(arprot)     ,
        .arvalid(arvalid)   ,
        .arready(arready)   ,
    //r           
        .rid(rid)           ,
        .rdata(rdata)       ,
        .rresp(rresp)       ,
        .rlast(rlast)       ,
        .rvalid(rvalid)     ,
        .rready(rready)     ,
    //aw          
        .awid(awid)         ,
        .awaddr(awaddr)     ,
        .awlen(awlen)       ,
        .awsize(awsize)     ,
        .awburst(awburst)   ,
        .awlock(awclock)    ,
        .awcache(awcache)   ,
        .awprot(awprot)     ,
        .awvalid(awvalid)   ,
        .awready(awready)   ,
    //w          
        .wid(wid)           ,
        .wdata(wdata)       ,
        .wstrb(wstrb)       ,
        .wlast(wlast)       ,
        .wvalid(wvalid)     ,
        .wready(wready)     ,
    //b           
        .bid(bid)           ,
        .bresp(bresp)       ,
        .bvalid(bvalid)     ,
        .bready(bready)       
);
    
    
	
endmodule