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
	input wire 					inst_req_i,//高电平表示cpu发起取指令
	input wire [`RegBus]		inst_vaddr_i,
	output wire 				inst_hit_o,//可选，表示ICache命中
	output wire 				inst_valid_o,//高电平表示当前输出inst有效
	output reg [`InstBus] 		inst1_o,
	output wire [`InstBus] 		inst2_o,
	output reg 				    inst_stall_o,//高电平表示正在处理取指命令
	output reg 				    single_issue_o,//高电平表示ICache只能够支持单发
	input wire 					flush,
    
	//Data stall
	output wire 				data_stall_o,//高电平表示正在处理访存命令
	//Data : Read Channel
    input wire 					data_rreq_i,//高电平表示cpu发起取数据
    input wire[`DataAddrBus]	data_raddr_i,
    output wire 				data_rvalid_o,//高电平表示当前输出data有效
    output reg [`RegBus]		data_rdata_o,
	//Data: Write Channel
    input wire 					data_wreq_i,//高电平表示cpu发起写数据
    input wire[`RegBus]			data_wdata_i,
    input wire [`DataAddrBus]	data_waddr_i,
    input wire [3:0] 			data_wsel_i,//选择需要写入的位数使能
//    output wire data_bvalid_o,
	
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
	reg [127:0]total_icache_hit;
	reg [127:0]total_icache_req;
	always@(posedge clk)begin
		if(rst)
			total_icache_req <= 0;
		else if(inst_valid_o)
			total_icache_req <= total_icache_req + 1;
		if(rst)
			total_icache_req <= 0;
		else if(ICache_hit)
			total_icache_req <= total_icache_req + 1;
	end
	
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////Mapping Operation/////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
	
	//inst read
	wire 				mem_inst_rvalid_i;
	wire [`WayBus]		mem_inst_rdata_i;//一个块的大小
	wire 				mem_inst_ren_o;
	wire [`InstAddrBus]	mem_inst_araddr_o;
    //data read
    wire 				mem_data_rvalid_i;
    wire [`WayBus]		mem_data_rdata_i;
    wire 				mem_data_ren_o;
    wire [`DataAddrBus]	mem_data_araddr_o;
	//data write
    wire 				mem_data_bvalid_i;
    wire 				mem_data_wen_o;
    wire [`WayBus] 		mem_data_wdata_o;//一个块的大小
    wire [`DataAddrBus]	mem_data_awaddr_o;
	
	//TLB
	wire inst_uncached;
	wire [`InstAddrBus]inst_paddr_i;
	TLB tlb_inst(
    .virtual_addr_i(inst_vaddr_i),
    .physical_addr_o(inst_paddr_i),
    .uncache(inst_uncached)
    );
	wire data_uncached;
	wire [`InstAddrBus]data_paddr_i;
	TLB tlb_data(
    .virtual_addr_i(virtual_addr_i),
    .physical_addr_o(data_paddr_i),
    .uncache(data_uncached)
    );
	
	//**Inst Uncached Operation**
	//ICache enable
	reg ICache_req;
	//*CacheAXI interface channel*
	reg 				interface_inst_req;
	reg [`InstAddrBus]	interface_inst_araddr;
	wire 				interface_inst_rvalid_i;
	wire [`DataBus]		interface_inst_rdata_i;
	//*Cpu output operation*
	reg 				ICache_stall;
	reg [`InstBus]		ICache_inst1;
	reg 				ICache_single_issue;
	always@(*)begin
		if(rst|flush)begin
			ICache_req 				<= `Invalid;
			interface_inst_req 		<= `Invalid;
			interface_inst_araddr 	<= `ZeroWord;
			inst_stall_o 			<= `Valid;
			inst1_o 				<= `ZeroWord;
			single_issue_o			<= `Invalid;
		end
		else if(inst_uncached)begin
			ICache_req 				<= 	`Invalid;
			interface_inst_req 		<= 	inst_req_i;
			interface_inst_araddr 	<= 	inst_paddr_i;
			inst_stall_o 			<= ~interface_inst_rvalid_i;
			inst1_o 				<= 	interface_inst_rdata_i;
			single_issue_o			<= `Valid;
		end
		else begin
			ICache_req 				<= 	inst_req_i;
			interface_inst_req 		<= 	mem_inst_ren_o;
			interface_inst_araddr 	<= 	mem_inst_araddr_o;
			inst_stall_o 			<= 	ICache_stall;
			inst1_o 				<= 	ICache_inst1;
			single_issue_o			<= ICache_single_issue;
		end
	end
	
	
	
	//**Data Read Uncached Operation**
	reg 				DCache_rreq;
	//*CacheAXI interface channel*
	reg 				interface_data_rreq;
	reg [`InstAddrBus]	interface_data_araddr;
	wire 				interface_data_rvalid_i;
	wire [`DataBus]		interface_data_rdata_i;
	//*Cpu output operation*
	wire 				dcache_stall;
	reg 				data_uncached_rstall;
	wire 				DCache_rdata_o;
	
	//**Data Write Uncached Operation**
	reg 				DCache_wreq;
	//*CacheAXI interface channel*
	reg 				interface_data_wreq;
	reg [`DataAddrBus]	interface_data_awaddr;
	reg [`DataBus]		interface_data_wdata;
	reg 				interface_data_bvalid_i;
	//*Cpu output operation*
	reg 				data_uncached_wstall;
	always@(*)begin
		if(rst)begin
			//read
			DCache_rreq 			<= `Invalid;
			interface_data_rreq 	<= `Invalid;
			interface_data_araddr 	<= `ZeroWord;
			data_uncached_rstall	<= `Invalid;
			data_rdata_o			<= `ZeroWord;
			//write
			DCache_wreq				<= `Invalid;
			interface_data_wreq		<= `Invalid;
			interface_data_awaddr   <= `ZeroWord;
			interface_data_wdata    <= `ZeroWord;
			data_uncached_wstall    <= `ZeroWord;
		end
		else if(data_uncached)begin
			//read
			DCache_rreq 			<= `Invalid;
			interface_data_rreq 	<= 	data_rreq_i;
			interface_data_araddr 	<= 	data_paddr_i;
			data_rdata_o			<= 	interface_data_rdata_i;
			data_uncached_rstall	<= ~interface_data_rvalid_i;
			//write
			DCache_wreq				<= `Invalid;
			interface_data_wreq		<=  data_wreq_i;
			interface_data_awaddr   <=  data_paddr_i;
			interface_data_wdata    <=  data_wdata_i;
			data_uncached_wstall    <= ~interface_data_bvalid_i;
		end
		else begin
			//read
			DCache_rreq 			<=  data_rreq_i;
			interface_data_rreq 	<= `Invalid;
			interface_data_araddr 	<=  data_paddr_i;
			data_uncached_rstall	<= `Invalid;
			data_rdata_o			<=  DCache_rdata_o;
			//write
			DCache_wreq				<=  data_wreq_i;
			interface_data_wreq		<=  mem_inst_ren_o;
			interface_data_awaddr   <=  data_waddr_i;
			interface_data_wdata    <=  data_wdata_i;
			data_uncached_wstall    <= `Invalid;
		end
	end
	assign data_stall_o = data_uncached_rstall | data_uncached_wstall | dcache_stall;
	
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////Body Of Cache ////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
	
	ICache ICache0(

		clk,
		rst|flush,
		
		//read inst request
		ICache_req,
		inst_paddr_i,
		
		//read inst result
		ICache_hit,
		inst_valid_o,
		ICache_inst1,
		inst2_o,
		ICache_stall,
		ICache_single_issue,
		
		mem_inst_rvalid_i,
		mem_inst_rdata_i,
		mem_inst_ren_o,
		mem_inst_araddr_o
		
		);	
	DCache DCache0(

		clk,
		rst,
		
		DCache_rreq,
		DCache_wreq,
		data_paddr_i,
		data_wdata_i,
		data_wsel_i,
		DCache_hit,
		data_rvalid_o,
		DCache_rdata_o,
		
		dcache_stall,
		
		mem_data_rvalid_i,
		mem_data_rdata_i,
		mem_data_ren_o,
		mem_data_araddr_o,
		
		mem_data_bvalid_i,
		mem_data_wen_o,
		mem_data_wdata_o,
		mem_data_awaddr_o
    
    );
    assign mem_inst_rvalid_i = interface_inst_rvalid_i;
    assign mem_inst_rdata_i = interface_inst_rdata_i;
	CacheAXI_Interface CacheAXI_Interface0(
		clk,
		rst,
		//ICahce: Read Channel
		interface_inst_req,
		interface_inst_araddr,
		inst_uncached,
		interface_inst_rvalid_i,
		interface_inst_rdata_i,
		
		//Data: Read Channel
		mem_data_ren_o,
		mem_data_araddr_o,
		data_uncached,
		mem_data_rvalid_i,
		mem_data_rdata_i,
		
		//Data: Write Channel
		mem_data_wen_o,
		mem_data_wdata_o,
		mem_data_awaddr_o,
		mem_data_bvalid_i,
		
		//Data Uncached: Read Channel
		interface_data_rreq,
		interface_data_araddr,
		interface_data_rvalid_i,
		interface_data_rdata_i,
		
		//Data Uncached: Write Channel
		interface_data_wreq,
		interface_data_wdata,
		interface_data_awaddr,
		interface_data_bvalid_i,
		
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
