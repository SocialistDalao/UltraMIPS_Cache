`timescale 1ns / 1ps

///////////////////////////////////////////////////////////////////////
//Notice:
///////1.DCache recieves only one port for addr, but cpu gives two,
/////////so we actually combine them here.
///////////////////////////////////////////////////////////////////////


`include"defines.v"
`include"defines_cache.v"
module Cache(
    input wire clk,
    input wire rst,
    
	//Inst
	input wire inst_req_i,//高电平表示cpu发起取指令
	input wire [`RegBus]inst_vaddr_i,
	output wire inst_hit_o,//可选，表示ICache命中
	output wire inst_valid_o,//高电平表示当前输出inst有效
	output wire [`InstBus] inst1_o,
	output wire [`InstBus] inst2_o,
	output wire inst_stall_o,//高电平表示正在处理取指命令
	output wire single_issue_i,//高电平表示ICache只能够支持单发
    
	//Data stall
	output wire data_stall_o,//高电平表示正在处理访存命令
	//Data : Read Channel
    input wire data_rreq_i,//高电平表示cpu发起取数据
    input wire[`DataAddrBus]data_raddr_i,
    output wire data_rvalid_o,//高电平表示当前输出data有效
    output wire [`RegBus]data_rdata_o,
	//Data: Write Channel
    input wire data_wreq_i,//高电平表示cpu发起写数据
    input wire[`RegBus]data_wdata_i,
    input wire [`DataAddrBus]data_waddr_i,
    input wire [3:0] data_wsel_i,//选择需要写入的位数使能
    output wire data_bvalid_o,//可选，高电平表示已经写入成功
	
	//AXI Communicate
	output wire             axi_ce_o,
	//AXI read
	input wire[`RegBus]    axi_rdata_i,        //返回到cache的读取数据
	input wire             axi_rvalid_i,  //返回数据可获取
	output wire             axi_ren_o,
	output wire             axi_rready_o,   //cache端准备好读
	output wire[`RegBus]    axi_raddr_o,
	output wire [3:0]       axi_rlen_o,		//read burst length
	//AXI write
	input wire             axi_bvalid_i,   //写响应,每个beat发一次，成功则可以传下一数据
    output wire [3:0]      axi_sel_o,//选择需要写入的位数使能
	output wire             axi_wen_o,
	output wire[`RegBus]    axi_waddr_o,
	output wire[`RegBus]    axi_wdata_o,    //cache最好保证在每个时钟沿更新要写的内容
	output wire             axi_wvalid_o,   //cache端准备好写的数据，最好是持续
	output wire             axi_wlast_o,    //cache写最后一个数据
	output wire [3:0]       axi_wlen_o		//write burst length
    );

	
	
	ICache(

		clk,
		rst,
		
		//read inst request
		inst_req_i,
		inst_araddr_i,
		
		//read inst result
		inst_hit_o,
		inst_valid_o,
		inst1_o,
		inst2_o,
		inst_stall_o,
		single_shot,
		
		//from_mem read result
		mem_rvalid_i,
		mem_rdata_i,//一个块的大小
		//to_mem ready to recieve request 
		mem_ren_o,
		mem_araddr_o
		
		);	
	assign axi_sel_o = data_wsel;
	
	wire [`DataAddrBus] virtual_addr_i = (data_rreq_i)? data_raddr_i:
										(data_wreq_i)? data_waddr_i:
										`ZeroWord;
	wire DCacehhit_o;
	DCache(

    input wire clk,
    input wire rst,
    
    //cpu data request
    input wire data_rreq_i,
    input wire data_wreq_i,
    input wire [`DataAddrBus]virtual_addr_i,
    input wire [`DataBus]data_wdata_i,
    input wire [3:0] data_wsel_i,//write byte sel
    output wire hit_o,
    output wire cpu_data_valid_o,
    output wire [`DataBus] cpu_data_o,
	
	//cache state
	output reg cpu_stall_o,
    
    //mem read
    input wire mem_rvalid_i,
    input wire [`WayBus]mem_rdata_i,
    output wire mem_ren_o,
    output wire[`DataAddrBus]mem_araddr_o,
	//mem write
    input wire mem_bvalid_i,
    output wire mem_wen_o,
    output wire[`WayBus] mem_wdata_o,//一个块的大小
    output wire [`DataAddrBus]mem_awaddr_o,
    
    //test
    output [`DirtyBus] dirty
    );
    
	CacheAXI_Interface(
		clk,
		rst,
		//ICahce: Read Channel
		mem_ren_o,
		mem_araddr_o,
		mem_rvalid_i,
		mem_rdata_i,//DCache: Read Channel
		
		//Data : Read Channel
		data_ren_i,
		data_araddr_i,
		data_rvalid_o,
		data_rdata_o,
		data_stall_o,
		
		//Data: Write Channel
		data_wen_i,
		data_wdata_i,
		data_awaddr_i,
		data_bvalid_o,
		
		//AXI Communicate
		axi_ce_o,
//		axi_sel_o,
		//AXI read
		axi_rdata_i,        //返回到cache的读取数据
		axi_rvalid_i,  //返回数据可获取
		axi_ren_o,
		axi_rready_o,   //cache端准备好读
		axi_raddr_o,
		axi_rlen_o,		//read burst length
		//AXI write
		axi_bvalid_i,   //写响应,每个beat发一次，成功则可以传下一数据
		axi_wen_o,
		axi_waddr_o,
		axi_wdata_o,    //cache最好保证在每个时钟沿更新要写的内容
		axi_wvalid_o,   //cache端准备好写的数据，最好是持续
		axi_wlast_o,    //cache写最后一个数据
		axi_wlen_o		//read burst length
	);

endmodule
