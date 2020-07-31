module mycpu_top(
input wire      aclk,
	input wire     aresetn,
	
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
	output wire                    timer_int_o,
	
	//debug
	output wire[`InstAddrBus]           debug_wb_pc0,
	output wire[3:0]                    debug_wb_rf_wen0,
	output wire[4:0]                    debug_wb_rf_wnum0,
	output wire[`RegBus]                debug_wb_rf_wdata0,
	
	output wire[`InstAddrBus]           debug_wb_pc1,
	output wire[3:0]                    debug_wb_rf_wen1,
	output wire[4:0]                    debug_wb_rf_wnum1,
	output wire[`RegBus]                debug_wb_rf_wdata1,
	
	output wire[`InstAddrBus]           debug_wb_pc,
	output wire[3:0]                    debug_wb_rf_wen,
	output wire[4:0]                    debug_wb_rf_wnum,
	output wire[`RegBus]                debug_wb_rf_wdata
	);
	
	////////////////////////////////////////////////////////////
	//ATTENTION: TIMER_INT_O AND DEBUG SIGNALS ARE EMPTY////////
	////////////////////////////////////////////////////////////
	
	//signal "int" is not connetcted
	
	//Inst
	wire 				inst_req_i;//高电平表示cpu发起取指�?
	wire[`RegBus]		inst_vaddr_i;
	wire 				inst_hit_o;//可�?�，表示ICache命中
	wire 				inst_valid_o;//高电平表示当前输出inst有效
	wire[`InstBus] 		inst1_o;
	wire[`InstBus] 		inst2_o;
	wire 				inst_stall_o;//高电平表示正在处理取指命�?
	wire 				single_shot;//高电平表示ICache只能够支持单�?
	wire               flush;//CPU is running flush, which requires ICache to stop
    
	wire 				data_stall_o;//高电平表示正在处理访存命�?
    wire 				data_ren_i;//高电平表示cpu发起取数�?
    wire[`DataAddrBus]	data_vaddr_i;
    wire 				data_rvalid_o;//高电平表示当前输出data有效
    wire[`RegBus]		data_rdata_o;
    wire 				data_wen_i;//高电平表示cpu发起写数�?
    wire[`RegBus]		data_wdata_i;
    wire[`DataAddrBus]	data_awaddr_i;
    wire[3:0] 			data_wsel;//选择�?要写入的位数使能
//    wire 				data_bvalid_o;//可�?�，高电平表示已经写入成�?
	
	//AXI Communicate
	wire             axi_ce_o;
	//AXI read
	wire[`RegBus]    axi_rdata_i;        //返回到cache的读取数�?
	wire             axi_rvalid_i;  //返回数据可获�?
	wire             axi_ren_o;
	wire             axi_rready_o;   //cache端准备好�?
	wire[`RegBus]    axi_raddr_o;
	wire [3:0]       axi_rlen_o;		//read burst length
	//AXI write
	wire             axi_bvalid_i;   //写响�?;每个beat发一次，成功则可以传下一数据
    wire [3:0]       axi_sel_o;//选择�?要写入的位数使能
	wire             axi_wen_o;
	wire[`RegBus]    axi_waddr_o;
	wire[`RegBus]    axi_wdata_o;    //cache�?好保证在每个时钟沿更新要写的内容
	wire             axi_wvalid_o;   //cache端准备好写的数据，最好是持续
	wire             axi_wlast_o;    //cache写最后一个数�?
	wire [3:0]       axi_wlen_o;		//write burst length
	
	mycpu mycpu0(
		aclk,
		aresetn,
		{timer_int_o,ext_int[4:0]},//ext_int,
		timer_int_o,
		
		// 与I-cache交流
		inst1_o,
		inst2_o,
		inst_stall_o,
		single_shot,
		inst_req_i,
		inst_vaddr_i,
		flush,//CPU is running flush, which requires ICache to stop
		
		// 与D-cache交流
		data_rdata_o,
		data_stall_o,
		data_ren_i,
		data_vaddr_i,
		data_wen_i,
		data_awaddr_i,
		data_wdata_i,
		data_wsel,

        debug_wb_pc0,
    	debug_wb_rf_wen0,
        debug_wb_rf_wnum0,
        debug_wb_rf_wdata0,
	
	    debug_wb_pc1,
	    debug_wb_rf_wen1,
	    debug_wb_rf_wnum1,
	    debug_wb_rf_wdata1
		
    );
	
	CacheBeta1 cache0(

    aclk,
    ~aresetn,
    
	//Inst
	inst_req_i,//高电平表示cpu发起取指�?
	inst_vaddr_i,
	inst_hit_o,//可�?�，表示ICache命中
	inst_valid_o,//高电平表示当前输出inst有效
	inst1_o,
	inst2_o,
	inst_stall_o,//高电平表示正在处理取指命�?
	single_shot,//高电平表示ICache只能够支持单�?
	flush,//CPU is running flush, which requires ICache to stop
    
	data_stall_o,//高电平表示正在处理访存命�?
    data_ren_i,//高电平表示cpu发起取数�?
    data_vaddr_i,
    data_rvalid_o,//高电平表示当前输出data有效
    data_rdata_o,
    data_wen_i,//高电平表示cpu发起写数�?
    data_wdata_i,
    data_awaddr_i,
    data_wsel,//选择�?要写入的位数使能
//    data_bvalid_o,//可�?�，高电平表示已经写入成�?
	
	//AXI Communicate
	axi_ce_o,
    axi_sel_o,//选择�?要写入的位数使能
	//AXI read
	axi_rdata_i,        //返回到cache的读取数�?
	axi_rvalid_i,  //返回数据可获�?
	axi_ren_o,
	axi_rready_o,   //cache端准备好�?
	axi_raddr_o,
	axi_rlen_o,		//read burst length
	
	axi_bvalid_i,   //写响�?,每个beat发一次，成功则可以传下一数据
	axi_wen_o,
	axi_waddr_o,
	axi_wdata_o,    //cache�?好保证在每个时钟沿更新要写的内容
	axi_wvalid_o,   //cache端准备好写的数据，最好是持续
	axi_wlast_o,    //cache写最后一个数�?
	axi_wlen_o		//write burst length
    );
	
	wire       stallreq;
	wire       ax_flush;
	wire [4:0] ax_stall;
	wire [`AXBURST]   burst_type;
	wire [`AXSIZE]    burst_size;
	assign ax_flush = 1'b0;
	assign ax_stall = 5'b0;
	assign burst_type = 2'h1;
	assign burst_size = 3'h2;
	
	my_axi_interface axi_interface0(
        aclk,
        aresetn, 
        
        ax_flush,
        ax_stall,
        stallreq,//?????
                
        //Cache////////
        axi_ce_o,
        axi_wen_o,
        axi_ren_o,
        axi_sel_o,
        axi_raddr_o,
        axi_waddr_o,  
        axi_wdata_o,    //cache�?好保证在每个时钟沿更新要写的内容
        axi_rready_o,   //cache端准备好�?
        axi_wvalid_o,   //cache端准备好写的数据，最好是持续
        axi_wlast_o,    //cache写最后一个数�?
        axi_rdata_i,
        axi_rvalid_i,
        axi_bvalid_i,   //写响�?,每个beat发一次，成功则可以传下一数据
        //burst
        burst_type, 
        burst_size,
        axi_rlen_o,
        axi_wlen_o,
       
        //axi///////
        //ar
        arid         ,
        araddr       ,
        arlen        ,
        arsize       ,
        arburst      ,
        arlock       ,
        arcache      ,
        arprot       ,
        arvalid      ,
        arready      ,
        
        //r           
        rid          ,
        rdata        ,
        rresp        ,
        rlast        ,
        rvalid       ,
        rready       ,
        
        //aw          
        awid         ,
        awaddr       ,
        awlen        ,
        awsize       ,
        awburst      ,
        awlock       ,
        awcache      ,
        awprot       ,
        awvalid      ,
        awready      ,
        
        //w          
        wid          ,
        wdata        ,
        wstrb        ,
        wlast        ,
        wvalid       ,
        wready       ,
        
        //b           
        bid          ,
        bresp        ,
        bvalid       ,
        bready       
    );
endmodule