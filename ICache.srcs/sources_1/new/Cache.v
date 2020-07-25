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
    //output wire data_bvalid_o,
	
	//AXI Communicate
	output wire             axi_ce_o,
	output wire             axi_sel_o,
	//AXI read
	input wire[`RegBus]    	axi_rdata_i,        //返回到cache的读取数据
	input wire             	axi_rvalid_i,  //返回数据可获取
	output wire             axi_ren_o,
	output wire             axi_rready_o,   //cache端准备好读
	output wire[`RegBus]    axi_raddr_o,
	output wire [3:0]       axi_rlen_o,		//read burst length
	//AXI write
	input wire             	axi_bvalid_i,   //写响应,每个beat发一次，成功则可以传下一数据
	output wire             axi_wen_o,
	output wire[`RegBus]    axi_waddr_o,
	output wire[`RegBus]    axi_wdata_o,    //cache最好保证在每个时钟沿更新要写的内容
	output wire             axi_wvalid_o,   //cache端准备好写的数据，最好是持续
	output wire             axi_wlast_o,    //cache写最后一个数据
	output wire [3:0]       axi_wlen_o		//write burst length
    );

	
//Notice:
///////1.DCache recieves only one port for addr, but cpu gives two,
///////  so we actually combine them here.
	wire [`DataAddrBus] virtual_addr_i = (data_rreq_i)? data_raddr_i:
										(data_wreq_i)? data_waddr_i:
										`ZeroWord;
	//Cache hit count
	wire DCache_hit;
	wire ICache_hit;
	reg [127:0]total_dcache_hit;
	reg [127:0]total_dcache_req;
	reg [127:0]total_icache_hit;
	reg [127:0]total_icache_req;
	always@(posedge clk)begin
		if(rst)
			total_dcache_req <= 0;
		else if(inst_valid_o)
			total_icache_req <= total_icache_req + 1;
		if(rst)
			total_dcache_req <= 0;
		else if(ICache_hit)
			total_icache_req <= total_icache_req + 1;
	end
	always@(posedge clk)begin
		if(rst)
			total_dcache_req <= 0;
		else if(data_rvalid_o)
			total_dcache_req <= total_dcache_req + 1;
		if(rst)
			total_dcache_req <= 0;
		else if(DCache_hit)
			total_dcache_req <= total_dcache_req + 1;
	end
	
	
	wire 				mem_inst_rvalid_i;
	wire [`WayBus]		mem_inst_rdata_i;//一个块的大小
	wire 				mem_inst_ren_o;
	wire [`InstAddrBus]	mem_inst_araddr_o;
	
    //mem read
    wire 				mem_data_rvalid_i;
    wire [`WayBus]		mem_data_rdata_i;
    wire 				mem_data_ren_o;
    wire [`DataAddrBus]	mem_data_araddr_o;
	//mem write
    wire 				mem_data_bvalid_i;
    wire 				mem_data_wen_o;
    wire [`WayBus] 		mem_data_wdata_o;//一个块的大小
    wire [`DataAddrBus]	mem_data_awaddr_o;
	ICache(

		clk,
		rst,
		
		//read inst request
		inst_req_i,
		inst_araddr_i,
		
		//read inst result
		ICache_hit,
		inst_valid_o,
		inst1_o,
		inst2_o,
		inst_stall_o,
		single_issue_i,
		
		mem_inst_rvalid_i,
		mem_inst_rdata_i,
		mem_inst_ren_o,
		mem_inst_araddr_o
		
		);	
	DCache DCache0(

		clk,
		rst,
		
		data_rreq_i,
		data_wreq_i,
		virtual_addr_i,
		data_wdata_i,
		data_wsel_i,
		DCache_hit,
		data_rvalid_o,
		data_rdata_o,
		
		data_stall_o,
		
		mem_data_rvalid_i,
		mem_data_rdata_i,
		mem_data_ren_o,
		mem_data_araddr_o,
		
		mem_data_bvalid_i,
		mem_data_wen_o,
		mem_data_wdata_o,
		mem_data_awaddr_o
    
    );
    
	CacheAXI_Interface(
		clk,
		rst,
		//ICahce: Read Channel
		mem_inst_ren_o,
		mem_inst_araddr_o,
		mem_inst_rvalid_i,
		mem_inst_rdata_i,
		
		//Data : Read Channel
		mem_data_ren_o,
		mem_data_araddr_o,
		mem_data_rvalid_i,
		mem_data_rdata_i,
		
		//Data: Write Channel
		mem_data_wen_o,
		mem_data_wdata_o,
		mem_data_awaddr_o,
		mem_data_bvalid_i,
		
		//AXI Communicate
		axi_ce_o,
		axi_sel_o,
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
