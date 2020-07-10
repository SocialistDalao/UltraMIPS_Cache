`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ????????
//----??????��
//--------CPU????????????
//--------TLB???????????
//--------WriteBuffer??��?????????
//--------BANK_RAM
//--------TAG+VALID_RAM
//--------LRU
//--------DIRTY
//----??????????
//--------??????
//----???????????????
//--------STATE_FETCH_DATA
//------------tag hit
//------------tag not hit
//--------STATE_WRITE_DATA
//----???????
//////////////////////////////////////////////////////////////////////////////////

`include"defines.v"
`include"defines_cache.v"
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
	output cache_busy_o,
    
    //from_mem read result
    input wire mem_rvalid_i,
    input wire [`WayBus]mem_rdata_i,
    //to_mem ready to recieve request 
    output wire mem_ren_o,
    output wire[`DataAddrBus]mem_araddr_o,
	//mem write
    input wire mem_bvalid_i,
    output wire mem_wen_o,
    output wire[`WayBus] mem_wdata_o,//һ����Ĵ�С
    output wire [`DataAddrBus]mem_awaddr_o
    
    //test
    output [`DirtyBus] dirty
    );
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////???????//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
    //keep the data of STATE_LOOK_UP
    reg [`InstAddrBus]virtual_addr;
    reg [`RegBus]cpu_wdata;
    reg func;//?????��?????????
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
	wire [`WayBus]FIFO_rdata;
	reg [`WayBus]FIFO_wdata;
	wire FIFO_hit;
	wire FIFO_wreq;
    WriteBuffer WB0(
        .clk(clk),
        .rst(rst),
        //CPU write request
        .cpu_wreq_i(FIFO_wreq),
        .cpu_awaddr_i(physical_addr),
        .cpu_wdata_i(FIFO_wdata),//???????��
        //CPU read request and response
        .cpu_rreq_i(cpu_rreq_i),
        .cpu_araddr_i(physical_addr),
        .hit_o(FIFO_hit),
        .cpu_rdata_o(FIFO_rdata),
        //state
        .state_o(state_o),
        //MEM 
        .mem_bvalid_i(mem_bvalid_i),
        .mem_wen_o(mem_wen_o),
        .mem_wdata_o(mem_wdata_o),
        .mem_awaddr_o(mem_awaddr_o)
    );
   
    
    //BANK 0~7 WAY 0~1
    //biwj indicates bank_i way_j
//    reg [`WayBus] data_cache;
    wire [`InstAddrBus]ram_addr = (current_state == `STATE_LOOK_UP)? virtual_addr_i : physical_addr; 
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
	wire write_dirty = dirty[{virtual_addr[`IndexBus],wea_way1}]; 
    always@(posedge clk)begin
        if(rst)
            dirty<=0;
		else if(current_state == `STATE_FETCH_DATA && hit_o == `HitFail && func == `WriteDisable)//Read not hit
            dirty[{virtual_addr[`IndexBus],wea_way1}] <= `NotDirty;
		else if(current_state == `STATE_FETCH_DATA && hit_o == `HitFail && func == `WriteEnable)//write not hit
            dirty[{virtual_addr[`IndexBus],wea_way1}] <= `Dirty;
		else if(current_state == `STATE_FETCH_DATA && (hit_way0|hit_way1) == `HitSuccess && func == `WriteEnable)//write hit but not FIFO
            dirty[{virtual_addr[`IndexBus],wea_way1}] <= `Dirty;
        else
            dirty <= dirty;
    end
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////????????////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

    reg [`StateBus]current_state;
    reg [`StateBus]next_state;
//  //????????  
    always@(posedge clk)begin
        if(rst)
            current_state <= `STATE_LOOK_UP;
        else
            current_state <= next_state;
    end
    
//  //??????
	wire bus_read_success = mem_rvalid_i;//???????????
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
                if(hit_o == `HitSuccess)//??��????
                    next_state <= `STATE_LOOK_UP;
                else if(bus_read_success == `Success && write_dirty == `WriteDisable)//??��?????��?????????��???
                    next_state <= `STATE_LOOK_UP;
                else if(bus_read_success == `Fail && write_dirty == `WriteEnable)//??��?????��????????��???
                    next_state <= `STATE_WRITE_DATA;
            end
            `STATE_WRITE_DATA:begin
                    next_state <= `STATE_LOOK_UP;
            end
            default:;
        endcase
    end//always
    
    
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////??????//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
    
    //STATE_LOOK_UP?? Detail operation is at the first of this file.
	
	
    //STATE_FETCH_DATA
	//hit judgement
    wire hit_way0 = (tagv_cache_w0[19:0]==physical_addr[`TagBus] && tagv_cache_w0[20]==`Valid)? `HitSuccess : `HitFail;
    wire hit_way1 = (tagv_cache_w1[19:0]==physical_addr[`TagBus] && tagv_cache_w1[20]==`Valid)? `HitSuccess : `HitFail;
    assign hit_o = (current_state==`STATE_FETCH_DATA)? (hit_way0 | hit_way1 | FIFO_hit) :`HitFail;
	
	//tag hit
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
    
    
   //Tag not hit
   //write to ram
    assign wea_way0 = (bus_read_success==`Valid && LRU_pick == 1'b0 && func == `WriteDisable)? 4'b1111 : //Read/Write Not Hit
                     (bus_read_success==`Valid && hit_way0 == `HitSuccess && func == `WriteEnable)? 4'b1111 : 4'h0;//Write Hit
    
    assign wea_way1 = (bus_read_success==`Valid && LRU_pick == 1'b1 && func == `WriteDisable)? 4'b1111 :
                     (bus_read_success==`Valid && hit_way1 == `HitSuccess && func == `WriteEnable)? 4'b1111 : 4'h0;
                     
	assign FIFO_wreq = (current_state == `STATE_FETCH_DATA && FIFO_hit == `HitSuccess)? `WriteEnable:
	                   (current_state == `STATE_WRITE_DATA)? `WriteEnable: `WriteDisable;
   //AXI read requirements
   assign mem_ren_o = (current_state==`STATE_FETCH_DATA && hit_o == `HitFail) ? `ReadEnable :`ReadDisable;
   assign mem_araddr_o = physical_addr;
   //��??ram?????wea??????????????��?????????????��????
   always@(*) begin 
		if(current_state == `STATE_FETCH_DATA && hit_o == `HitFail && func == `WriteDisable)begin//??��???��?????????��??
			read_from_mem <= mem_rdata_i;
		end
		else if(current_state == `STATE_FETCH_DATA && hit_o == `HitFail && func == `WriteEnable)begin//�զ�???��?��???????????????��??
			case(virtual_addr[4:2])
				3'h0:read_from_mem <= {mem_rdata_i[32*8-1:32*7],mem_rdata_i[32*7-1:32*6],mem_rdata_i[32*6-1:32*5],mem_rdata_i[32*5-1:32*4],mem_rdata_i[32*4-1:32*3],mem_rdata_i[32*3-1:32*2],mem_rdata_i[32*2-1:32*1],cpu_wdata};
				3'h0:read_from_mem <= {mem_rdata_i[32*8-1:32*7],mem_rdata_i[32*7-1:32*6],mem_rdata_i[32*6-1:32*5],mem_rdata_i[32*5-1:32*4],mem_rdata_i[32*4-1:32*3],mem_rdata_i[32*3-1:32*2],cpu_wdata,mem_rdata_i[32*1-1:32*0]};
				3'h0:read_from_mem <= {mem_rdata_i[32*8-1:32*7],mem_rdata_i[32*7-1:32*6],mem_rdata_i[32*6-1:32*5],mem_rdata_i[32*5-1:32*4],mem_rdata_i[32*4-1:32*3],cpu_wdata,mem_rdata_i[32*2-1:32*1],mem_rdata_i[32*1-1:32*0]};
				3'h0:read_from_mem <= {mem_rdata_i[32*8-1:32*7],mem_rdata_i[32*7-1:32*6],mem_rdata_i[32*6-1:32*5],mem_rdata_i[32*5-1:32*4],cpu_wdata,mem_rdata_i[32*3-1:32*2],mem_rdata_i[32*2-1:32*1],mem_rdata_i[32*1-1:32*0]};
				3'h0:read_from_mem <= {mem_rdata_i[32*8-1:32*7],mem_rdata_i[32*7-1:32*6],mem_rdata_i[32*6-1:32*5],cpu_wdata,mem_rdata_i[32*4-1:32*3],mem_rdata_i[32*3-1:32*2],mem_rdata_i[32*2-1:32*1],mem_rdata_i[32*1-1:32*0]};
				3'h0:read_from_mem <= {mem_rdata_i[32*8-1:32*7],mem_rdata_i[32*7-1:32*6],cpu_wdata,mem_rdata_i[32*5-1:32*4],mem_rdata_i[32*4-1:32*3],mem_rdata_i[32*3-1:32*2],mem_rdata_i[32*2-1:32*1],mem_rdata_i[32*1-1:32*0]};
				3'h0:read_from_mem <= {mem_rdata_i[32*8-1:32*7],cpu_wdata,mem_rdata_i[32*6-1:32*5],mem_rdata_i[32*5-1:32*4],mem_rdata_i[32*4-1:32*3],mem_rdata_i[32*3-1:32*2],mem_rdata_i[32*2-1:32*1],mem_rdata_i[32*1-1:32*0]};
				3'h0:read_from_mem <= {cpu_wdata,mem_rdata_i[32*7-1:32*6],mem_rdata_i[32*6-1:32*5],mem_rdata_i[32*5-1:32*4],mem_rdata_i[32*4-1:32*3],mem_rdata_i[32*3-1:32*2],mem_rdata_i[32*2-1:32*1],mem_rdata_i[32*1-1:32*0]};
				default: read_from_mem <= mem_rdata_i;
			endcase
		end
		else if(current_state == `STATE_FETCH_DATA && hit_o == `HitSuccess)begin//��???��????��??
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
            else if(FIFO_hit == `HitSuccess)begin
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
                read_from_mem<={`ZeroWord,`ZeroWord,`ZeroWord,`ZeroWord,`ZeroWord,`ZeroWord,`ZeroWord,`ZeroWord};
   end
  
   //STATE_WRITE_DATA
   //write to FIFO 
	always@(*)begin
	   FIFO_wdata <= `ZeroWay;
	   if(current_state == `STATE_FETCH_DATA)begin
            case(virtual_addr[4:2])
                3'h0:FIFO_wdata <= {FIFO_rdata[8*32-1:1*32],cpu_wdata};
                3'h1:FIFO_wdata <= {FIFO_rdata[8*32-1:2*32],cpu_wdata,FIFO_rdata[1*32-1:0*32]};
                3'h2:FIFO_wdata <= {FIFO_rdata[8*32-1:3*32],cpu_wdata,FIFO_rdata[2*32-1:1*32]};
                3'h3:FIFO_wdata <= {FIFO_rdata[8*32-1:4*32],cpu_wdata,FIFO_rdata[3*32-1:2*32]};
                3'h4:FIFO_wdata <= {FIFO_rdata[8*32-1:5*32],cpu_wdata,FIFO_rdata[4*32-1:3*32]};
                3'h5:FIFO_wdata <= {FIFO_rdata[8*32-1:6*32],cpu_wdata,FIFO_rdata[5*32-1:4*32]};
                3'h6:FIFO_wdata <= {FIFO_rdata[8*32-1:7*32],cpu_wdata,FIFO_rdata[6*32-1:5*32]};
                3'h7:FIFO_wdata <= {cpu_wdata,FIFO_rdata[7*32-1:6*32]};
                default:;                                         
            endcase
	   end
	   else if(current_state == `STATE_WRITE_DATA)begin
            if(LRU_pick == 1'b0)begin//0��???�I
                FIFO_wdata <= {inst_cache_b7w0,inst_cache_b6w0,inst_cache_b5w0,inst_cache_b4w0,inst_cache_b3w0,inst_cache_b2w0,inst_cache_b1w0,inst_cache_b0w0};
            end
            else if(LRU_pick == 1'b1)begin//1��???�I
                FIFO_wdata <= {inst_cache_b7w1,inst_cache_b6w1,inst_cache_b5w1,inst_cache_b4w1,inst_cache_b3w1,inst_cache_b2w1,inst_cache_b1w1,inst_cache_b0w1};
            end
       end
	end
   
   
//    assign mem_ren_o
    
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////???????//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
    assign cpu_data_o = (current_state==`STATE_FETCH_DATA && hit_way0 == `HitSuccess)? data_way0:
                        (current_state==`STATE_FETCH_DATA && hit_way1 == `HitSuccess)? data_way1:
                        (current_state==`STATE_FETCH_DATA && FIFO_hit == `HitSuccess)? data_FIFO:
						//???????????
                        (current_state==`STATE_FETCH_DATA && bus_read_success ==`Success && virtual_addr[4:2] == 3'h0)? read_from_mem[32*1-1:32*0]:
                        (current_state==`STATE_FETCH_DATA && bus_read_success ==`Success && virtual_addr[4:2] == 3'h1)? read_from_mem[32*2-1:32*1]:
                        (current_state==`STATE_FETCH_DATA && bus_read_success ==`Success && virtual_addr[4:2] == 3'h2)? read_from_mem[32*3-1:32*2]:
                        (current_state==`STATE_FETCH_DATA && bus_read_success ==`Success && virtual_addr[4:2] == 3'h3)? read_from_mem[32*4-1:32*3]:
                        (current_state==`STATE_FETCH_DATA && bus_read_success ==`Success && virtual_addr[4:2] == 3'h4)? read_from_mem[32*5-1:32*4]:
                        (current_state==`STATE_FETCH_DATA && bus_read_success ==`Success && virtual_addr[4:2] == 3'h5)? read_from_mem[32*6-1:32*5]:
                        (current_state==`STATE_FETCH_DATA && bus_read_success ==`Success && virtual_addr[4:2] == 3'h6)? read_from_mem[32*7-1:32*6]:
                        (current_state==`STATE_FETCH_DATA && bus_read_success ==`Success && virtual_addr[4:2] == 3'h7)? read_from_mem[32*8-1:32*7]:
                        `ZeroWord;
                        
    assign cpu_data_valid_o = (current_state==`STATE_FETCH_DATA && hit_o == `HitSuccess)? `Valid :
                              (current_state==`STATE_WRITE_DATA)                        ? `Valid :
                              `Invalid ;
endmodule
