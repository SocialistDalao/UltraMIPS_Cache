`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 代码架构：
//----初始定义：
//--------TLB：虚实地址转换
//--------BANK_RAM
//--------TAG+VALID_RAM
//--------DIRTY
//--------LRU
//----状态机描述：
//--------状态转移动作
//--------状态转移表
//----组合逻辑具体操作：
//--------STATE_SCAN_CACHE
//--------STATE_HIT_FAIL
//--------STATE_WRITE_BACK
//----输出控制：
//--------STATE_SCAN_CACHE
//////////////////////////////////////////////////////////////////////////////////

`include"defines.v";
`include"defines_cache.v";
module DCache(

    input wire clk,
    input wire rst,
    
    //cpu data request
    input wire cpu_rreq_i,
    input wire cpu_wreq_i,
    input wire [`DataAddrBus]virtual_addr_i,
    input wire [`DataBus]cpu_wdata_i,
    
    //cpu date result
    output wire hit_o,
    output wire cpu_data_valid_o,
    output wire [`DataBus] cpu_data_o,
	
	//cache state
	output cache_busy_o
    
    //from_mem read result
    input wire mem_rvalid_i,
    input wire mem_arready_i,
    input wire [`WayBus]mem_rdata_i,//一个块的大小
    //to_mem ready to recieve request 
    output wire mem_ren_o,
    output wire mem_rready_o,
    output wire mem_arvalid_o,
    output wire[`DataAddrBus]mem_araddr_o,
	//mem write
    input wire mem_wready_i,
    output wire mem_wvalid_o,
    output wire[`WayBus] mem_wdata_o,//一个块的大小
    input wire mem_awready_i,
    output wire mem_awvalid_o,
    output wire [`DataAddrBus]mem_awaddr_o,
    input wire mem_bvalid,
    output wire mem_bready,
    
    //test
    output [`DirtyBus] dirty
    );
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////初始定义//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
    //keep the data
    reg [`InstAddrBus]virtual_addr;
    reg [`RegBus]cpu_wdata;
    reg func;//高电平为写，低电平为读
    always@(posedge clk)begin
        if(rst)begin
            virtual_addr<= `ZeroWord;
            cpu_wdata<= `ZeroWord;
            func <= `Invalid;
        end
        else if(current_state == `STATE_LOOK_UP)begin
            virtual_addr <= virtual_addr_i;
            cpu_wdata <= cpu_wdata_i;
            func <= cpu_wreq_i;
        end
        else begin
            virtual_addr <= virtual_addr;
            cpu_wdata <= cpu_wdata;
            func <= func;
        end
    end
    wire [`InstAddrBus]physical_addr;
    wire index = physical_addr[`IndexBus];
    wire offset = physical_addr[`OffsetBus];
    //TLB
    TLB tlb0(
    .rst(rst),
    .virtual_addr_i(virtual_addr),
    .physical_addr_o(physical_addr)
    );
	//WriteBuffer
	reg [`WayBus]FIFO_rdata;
	reg FIFO_hit;
	reg FIFO_wreq;
    WriteBuffer WB0(
        .clk(clk),
        .rst(rst),
        //CPU write request
        .cpu_wreq_i(FIFO_wreq),
        .cpu_awaddr_i(physical_addr),
        .cpu_wdata_i(cpu_wdata),//一个块的大小
        //CPU read request and response
        .cpu_rreq_i(cpu_rreq_i),
        .cpu_araddr_i(physical_addr),
        .read_hit_o(FIFO_hit),
        .cpu_rdata_o(FIFO_rdata),
        
        //state
        .state_o(state_o),
        
        //MEM 
        .mem_wready_i(mem_wready_i),
        .mem_wvalid_o(mem_wvalid_o),
        .mem_wdata_o(mem_wdata_o),//一个块的大小
        .mem_awready_i(mem_awready_i),
        .mem_awvalid_o(mem_awvalid_o),
        .mem_awaddr_o(mem_awaddr_o),
        .mem_bvalid(mem_bvalid),
        .mem_bready(mem_bready)
    );
   
    
    //BANK 0~7 WAY 0~1
    //biwj indicates bank_i way_j
//    reg [`WayBus] data_cache;
    wire [`InstAddrBus]ram_addr = (current_state == `STATE_LOOK_UP) virtual_addr_i : physical_addr; 
	reg [`WayBus]read_from_mem;
	
    wire [3:0]wea_way0;
    wire [3:0]wea_way1;
    
    wire [`RegBus]inst_cache_b0w0;
    wire [`RegBus]inst_cache_b1w0;
    wire [`RegBus]inst_cache_b2w0;
    wire [`RegBus]inst_cache_b3w0;
    wire [`RegBus]inst_cache_b4w0;
    wire [`RegBus]inst_cache_b5w0;
    wire [`RegBus]inst_cache_b6w0;
    wire [`RegBus]inst_cache_b7w0;
    bank_ram Bank0_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*1-1:32*0]),.douta(inst_cache_b0w0));
    bank_ram Bank1_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*2-1:32*1]),.douta(inst_cache_b1w0));
    bank_ram Bank2_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*3-1:32*2]),.douta(inst_cache_b2w0));
    bank_ram Bank3_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*4-1:32*3]),.douta(inst_cache_b3w0));
    bank_ram Bank4_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*5-1:32*4]),.douta(inst_cache_b4w0));
    bank_ram Bank5_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*6-1:32*5]),.douta(inst_cache_b5w0));
    bank_ram Bank6_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*7-1:32*6]),.douta(inst_cache_b6w0));
    bank_ram Bank7_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*8-1:32*7]),.douta(inst_cache_b7w0));
    
    wire [`RegBus]inst_cache_b0w1;
    wire [`RegBus]inst_cache_b1w1;
    wire [`RegBus]inst_cache_b2w1;
    wire [`RegBus]inst_cache_b3w1;
    wire [`RegBus]inst_cache_b4w1;
    wire [`RegBus]inst_cache_b5w1;
    wire [`RegBus]inst_cache_b6w1;
    wire [`RegBus]inst_cache_b7w1;                              
    bank_ram Bank0_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*1-1:32*0]),.douta(inst_cache_b0w1));
    bank_ram Bank1_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*2-1:32*1]),.douta(inst_cache_b1w1));
    bank_ram Bank2_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*3-1:32*2]),.douta(inst_cache_b2w1));
    bank_ram Bank3_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*4-1:32*3]),.douta(inst_cache_b3w1));
    bank_ram Bank4_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*5-1:32*4]),.douta(inst_cache_b4w1));
    bank_ram Bank5_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*6-1:32*5]),.douta(inst_cache_b5w1));
    bank_ram Bank6_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*7-1:32*6]),.douta(inst_cache_b6w1));
    bank_ram Bank7_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(ram_addr[`IndexBus]), .dina(read_from_mem[32*8-1:32*7]),.douta(inst_cache_b7w1));

    //Tag+Valid
    wire [`TagVBus]tagv_cache_w0;
    wire [`TagVBus]tagv_cache_w1;
    tag_ram TagV0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(ram_addr[`IndexBus]),.dina({1'b1,physical_addr[`TagBus]}),.douta(tagv_cache_w0));
    tag_ram TagV1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(ram_addr[`IndexBus]),.dina({1'b1,physical_addr[`TagBus]}),.douta(tagv_cache_w1));
    
    //LRU
    reg [`SetBus]LRU;
    wire LRU_pick = LRU[virtual_addr[`IndexBus]];
    always@(posedge clk)begin
        if(rst)
            LRU <= 0;
        else if(cpu_data_valid_o == `Valid && hit_o == `HitSuccess)
            LRU[virtual_addr[`IndexBus]] <= hit_way0;
        else if(cpu_data_valid_o == `Valid && hit_o == `HitFail)
            LRU[virtual_addr[`IndexBus]] <= wea_way0;
        else
            LRU <= LRU;
    end
    
    //Dirty 
    reg [`DirtyBus] dirty;
    always@(posedge clk)begin
        if(rst)
            dirty<=0;
		else if(current_state == `STATE_FETCH_DATA && mem_arvalid_o == `Valid && func == `WriteEnable)
            dirty[{virtual_addr[`IndexBus],wea_way1}] <= `Dirty;
		else if(current_state == `STATE_FETCH_DATA && mem_arvalid_o == `Valid && func == `WriteDisable)
            dirty[{virtual_addr[`IndexBus],wea_way1}] <= `NotDirty;
        else
            dirty <= dirty;
    end
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////状态机描述////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

    reg [`StateBus]current_state;
    reg [`StateBus]next_state;
//    状态转移动作  
    always@(posedge clk)begin
        if(rst)
            current_state <= `STATE_LOOK_UP;
        else
            current_state <= next_state;
    end
    
//    状态转移表
	reg write_dirty; 
	wire bus_read_success = mem_rvalid_i;//总线读数据成功
    always@(*)begin
        next_state <= `STATE_LOOK_UP;
        case(current_state)
            `STATE_LOOK_UP:begin
                if(cpu_rreq_i | cpu_wreq_i)begin
                    next_state <= `STATE_FETCH_DATA;
                end
                else
                    next_state <= `STATE_LOOK_UP;
            end
            `STATE_FETCH_DATA:begin
                if(hit_o == `HitSuccess)//读写命中
                    next_state <= `STATE_LOOK_UP;
                else if(bus_read_success == `Success && write_dirty == `WriteDisable)//读写不命中但是不需要回写脏块
                    next_state <= `STATE_LOOK_UP;
                else if(bus_read_success == `Fail && write_dirty == `WriteEnable)//读写不命中但是需要回写脏块
                    next_state <= `STATE_WRITE_DATA;
            end
            `STATE_WRITE_DATA:begin
                    next_state <= `STATE_LOOK_UP;
            end
            default:;
        endcase
    end//always
    
    
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////组合逻辑//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
    
    //STATE_LOOK_UP：选择ram中对应的bank
    reg [`InstBus]data_way0;
    reg [`InstBus]data_way1;
    reg [`InstBus]data_FIFO;
    //way0
    always@(*)begin
        case(virtual_addr[4:2])
            3'h0:data_way0 <= inst_cache_b0w0;
            3'h1:data_way0 <= inst_cache_b1w0;
            3'h2:data_way0 <= inst_cache_b2w0;
            3'h3:data_way0 <= inst_cache_b3w0;
            3'h4:data_way0 <= inst_cache_b4w0;
            3'h5:data_way0 <= inst_cache_b5w0;
            3'h6:data_way0 <= inst_cache_b6w0;
            3'h7:data_way0 <= inst_cache_b7w0;
            default: data_way0 <= `ZeroWord;
        endcase
    end
    //way1
    always@(*)begin
        case(virtual_addr[4:2])
            3'h0:data_way1 <= inst_cache_b0w1;
            3'h1:data_way1 <= inst_cache_b1w1;
            3'h2:data_way1 <= inst_cache_b2w1;
            3'h3:data_way1 <= inst_cache_b3w1;
            3'h4:data_way1 <= inst_cache_b4w1;
            3'h5:data_way1 <= inst_cache_b5w1;
            3'h6:data_way1 <= inst_cache_b6w1;
            3'h7:data_way1 <= inst_cache_b7w1;
            default: data_way1 <= `ZeroWord;
        endcase
    end
    //FIFO
    always@(*)begin
        case(virtual_addr[4:2])
            3'h0:data_FIFO <= FIFO_rdata[32*1-1:32*0];
            3'h1:data_FIFO <= FIFO_rdata[32*2-1:32*1];
            3'h2:data_FIFO <= FIFO_rdata[32*3-1:32*2];
            3'h3:data_FIFO <= FIFO_rdata[32*4-1:32*3];
            3'h4:data_FIFO <= FIFO_rdata[32*5-1:32*4];
            3'h5:data_FIFO <= FIFO_rdata[32*6-1:32*5];
            3'h6:data_FIFO <= FIFO_rdata[32*7-1:32*6];
            3'h7:data_FIFO <= FIFO_rdata[32*8-1:32*7];
            default: data_FIFO <= `ZeroWord;
        endcase
    end
	
	
    //STATE_FETCH_DATA
    //Tag Hit
    wire hit_way0 = (tagv_cache_w0[19:0]==physical_addr[`TagBus] && tagv_cache_w0[20]==`Valid)? `HitSuccess : `HitFail;
    wire hit_way1 = (tagv_cache_w1[19:0]==physical_addr[`TagBus] && tagv_cache_w1[20]==`Valid)? `HitSuccess : `HitFail;
    assign hit_o = (current_state==`STATE_FETCH_DATA)? (hit_way0 | hit_way1 | FIFO_hit) :`HitFail;
    reg hit_way0_reg;
    reg hit_way1_reg;
    always@(posedge clk)begin
        if(rst)
            hit_way0_reg <= `HitFail;
        else if(current_state==`STATE_SCAN_CACHE)
            hit_way0_reg <= hit_way0;
        else
            hit_way0_reg <= hit_way0_reg;
    end
    always@(posedge clk)begin
        if(rst)
            hit_way1_reg <= `HitFail;
        else if(current_state==`STATE_SCAN_CACHE)
            hit_way1_reg <= hit_way1;
        else
            hit_way1_reg <= hit_way1_reg;
    end
    
    
   //Tag not hit
   //AXI
   assign mem_ren_o = (current_state==`STATE_FETCH_DATA && hit_o == `HitFail) ? `ReadEnable :`ReadDisable;
//                      (current_state==`STATE_WRITE_BACK  &&  func == `WriteEnable)? `ReadEnable :  `ReadDisable;
   assign mem_rready_o = (current_state==`STATE_FETCH_DATA && hit_o == `HitFail) ? `ReadEnable : `ReadDisable;
   assign mem_arvalid_o = (current_state==`STATE_FETCH_DATA && hit_o == `HitFail) ? `Valid : `Invalid;
   assign mem_araddr_o = physical_addr;
   //
   always@(posedge clk) begin 
        if(current_state==`STATE_HIT_FAIL )
            read_from_mem<= mem_rdata_i;
        else if(current_state == `STATE_SCAN_CACHE && func == `WriteEnable)begin
            if(hit_way0 == `HitSuccess)begin
                case(virtual_addr[4:2])
                    3'h0:read_from_mem <= {inst_cache_b7w0,inst_cache_b6w0,inst_cache_b5w0,inst_cache_b4w0,inst_cache_b3w0,inst_cache_b2w0,inst_cache_b1w0,cpu_wdata};
                    3'h1:read_from_mem <= {inst_cache_b7w0,inst_cache_b6w0,inst_cache_b5w0,inst_cache_b4w0,inst_cache_b3w0,inst_cache_b2w0,cpu_wdata,inst_cache_b0w0};
                    3'h2:read_from_mem <= {inst_cache_b7w0,inst_cache_b6w0,inst_cache_b5w0,inst_cache_b4w0,inst_cache_b3w0,cpu_wdata,inst_cache_b1w0,inst_cache_b0w0};
                    3'h3:read_from_mem <= {inst_cache_b7w0,inst_cache_b6w0,inst_cache_b5w0,inst_cache_b4w0,cpu_wdata,inst_cache_b2w0,inst_cache_b1w0,inst_cache_b0w0};
                    3'h4:read_from_mem <= {inst_cache_b7w0,inst_cache_b6w0,inst_cache_b5w0,cpu_wdata,inst_cache_b3w0,inst_cache_b2w0,inst_cache_b1w0,inst_cache_b0w0};
                    3'h5:read_from_mem <= {inst_cache_b7w0,inst_cache_b6w0,cpu_wdata,inst_cache_b4w0,inst_cache_b3w0,inst_cache_b2w0,inst_cache_b1w0,inst_cache_b0w0};
                    3'h6:read_from_mem <= {inst_cache_b7w0,cpu_wdata,inst_cache_b5w0,inst_cache_b4w0,inst_cache_b3w0,inst_cache_b2w0,inst_cache_b1w0,inst_cache_b0w0};
                    3'h7:read_from_mem <= {cpu_wdata,inst_cache_b6w0,inst_cache_b5w0,inst_cache_b4w0,inst_cache_b3w0,inst_cache_b2w0,inst_cache_b1w0,inst_cache_b0w0};
                    default:read_from_mem<={inst_cache_b7w0,inst_cache_b6w0,inst_cache_b5w0,inst_cache_b4w0,inst_cache_b3w0,inst_cache_b2w0,inst_cache_b1w0,inst_cache_b0w0};
                endcase
            end//if
            else if(hit_way1 == `HitSuccess)begin
                case(virtual_addr[4:2])
                    3'h0:read_from_mem <= {inst_cache_b7w1,inst_cache_b6w1,inst_cache_b5w1,inst_cache_b4w1,inst_cache_b3w1,inst_cache_b2w1,inst_cache_b1w1,cpu_wdata};
                    3'h1:read_from_mem <= {inst_cache_b7w1,inst_cache_b6w1,inst_cache_b5w1,inst_cache_b4w1,inst_cache_b3w1,inst_cache_b2w1,cpu_wdata,inst_cache_b0w1};
                    3'h2:read_from_mem <= {inst_cache_b7w1,inst_cache_b6w1,inst_cache_b5w1,inst_cache_b4w1,inst_cache_b3w1,cpu_wdata,inst_cache_b1w1,inst_cache_b0w1};
                    3'h3:read_from_mem <= {inst_cache_b7w1,inst_cache_b6w1,inst_cache_b5w1,inst_cache_b4w1,cpu_wdata,inst_cache_b2w1,inst_cache_b1w1,inst_cache_b0w1};
                    3'h4:read_from_mem <= {inst_cache_b7w1,inst_cache_b6w1,inst_cache_b5w1,cpu_wdata,inst_cache_b3w1,inst_cache_b2w1,inst_cache_b1w1,inst_cache_b0w1};
                    3'h5:read_from_mem <= {inst_cache_b7w1,inst_cache_b6w1,cpu_wdata,inst_cache_b4w1,inst_cache_b3w1,inst_cache_b2w1,inst_cache_b1w1,inst_cache_b0w1};
                    3'h6:read_from_mem <= {inst_cache_b7w1,cpu_wdata,inst_cache_b5w1,inst_cache_b4w1,inst_cache_b3w1,inst_cache_b2w1,inst_cache_b1w1,inst_cache_b0w1};
                    3'h7:read_from_mem <= {cpu_wdata,inst_cache_b6w1,inst_cache_b5w1,inst_cache_b4w1,inst_cache_b3w1,inst_cache_b2w1,inst_cache_b1w1,inst_cache_b0w1};
                    default:read_from_mem<={inst_cache_b7w1,inst_cache_b6w1,inst_cache_b5w1,inst_cache_b4w1,inst_cache_b3w1,inst_cache_b2w1,inst_cache_b1w1,inst_cache_b0w1};
                endcase
            end//elseif
            else
                read_from_mem<={`ZeroWord,`ZeroWord,`ZeroWord,`ZeroWord,`ZeroWord,`ZeroWord,`ZeroWord,`ZeroWord};
        end//elseif
        else
            read_from_mem<= read_from_mem;
   end
   
   
    assign wea_way0 = (bus_read_success==`Valid && LRU_pick == 1'b0 && func == `WriteDisable)? 4'b1111 :
                     (bus_read_success==`Valid && hit_way0 == `HitSuccess && func == `WriteEnable)? 4'b1111 : 4'h0;
    
    assign wea_way1 = (bus_read_success==`Valid && LRU_pick == 1'b1 && func == `WriteDisable)? 4'b1111 :
                     (bus_read_success==`Valid && hit_way1 == `HitSuccess && func == `WriteEnable)? 4'b1111 : 4'h0;
//    assign mem_ren_o
    
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////输出控制//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
    assign cpu_data_o = (current_state==`STATE_SCAN_CACHE && hit_way0 == `HitSuccess)? data_way0:
                        (current_state==`STATE_SCAN_CACHE && hit_way1 == `HitSuccess)? data_way1:
                        (current_state==`STATE_SCAN_CACHE && hit_FIFO == `HitSuccess)? data_FIFO:
						//关键字优先读取
                        (current_state==`STATE_SCAN_CACHE && bus_read_success ==`Success && virtual_addr[4:2] == 3'h0)? read_from_mem[32*1-1:32*0]:
                        (current_state==`STATE_SCAN_CACHE && bus_read_success ==`Success && virtual_addr[4:2] == 3'h1)? read_from_mem[32*2-1:32*1]:
                        (current_state==`STATE_SCAN_CACHE && bus_read_success ==`Success && virtual_addr[4:2] == 3'h2)? read_from_mem[32*3-1:32*2]:
                        (current_state==`STATE_SCAN_CACHE && bus_read_success ==`Success && virtual_addr[4:2] == 3'h3)? read_from_mem[32*4-1:32*3]:
                        (current_state==`STATE_SCAN_CACHE && bus_read_success ==`Success && virtual_addr[4:2] == 3'h4)? read_from_mem[32*5-1:32*4]:
                        (current_state==`STATE_SCAN_CACHE && bus_read_success ==`Success && virtual_addr[4:2] == 3'h5)? read_from_mem[32*6-1:32*5]:
                        (current_state==`STATE_SCAN_CACHE && bus_read_success ==`Success && virtual_addr[4:2] == 3'h6)? read_from_mem[32*7-1:32*6]:
                        (current_state==`STATE_SCAN_CACHE && bus_read_success ==`Success && virtual_addr[4:2] == 3'h7)? read_from_mem[32*8-1:32*7]:
                        `ZeroWord;
                        
    assign cpu_data_valid_o = (current_state==`STATE_SCAN_CACHE && hit_o == `HitSuccess)? `Valid :
                              (current_state==`STATE_WRITE_BACK)                        ? `Valid :
                              `Invalid ;
endmodule
