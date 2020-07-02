`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ����ܹ���
//----��ʼ���壺
//--------TLB����ʵ��ַת��
//--------BANK_RAM
//--------TAG+VALID_RAM
//--------DIRTY
//--------LRU
//----״̬��������
//--------״̬ת�ƶ���
//--------״̬ת�Ʊ�
//----����߼����������
//--------STATE_SCAN_CACHE
//--------STATE_HIT_FAIL
//--------STATE_WRITE_BACK
//----������ƣ�
//--------STATE_SCAN_CACHE
//////////////////////////////////////////////////////////////////////////////////


module DCache(

    input wire clk,
    input wire rst,
    
    //read inst request
    input wire cpu_rreq_i,
    input wire cpu_wreq_i,
    input wire [`RegAddrBus]virtual_addr_i,
    input wire [`RegBus]cpu_wdata_i,
    
    //read inst result
    output wire hit_o,
    output wire cpu_inst_valid_o,
    output wire [`InstBus] cpu_inst_o,
    
    //from_mem read result
    input wire mem_rvalid_i,
    input wire mem_arready_i,
    input wire [`WayBus]mem_rdata_i,//һ����Ĵ�С
    //to_mem ready to recieve request 
    output wire mem_ren_o,
    output wire mem_rready_o,
    output wire mem_arvalid_o,
    output wire[`InstAddrBus]mem_araddr_o
    
    //test
    );
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////��ʼ����//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
    //keep the data
    reg [`InstAddrBus]virtual_addr;
    reg [`RegBus]cpu_wdata;
    always@(posedge clk)begin
        if(rst)begin
            virtual_addr<= `ZeroWord;
            cpu_wdata<= `ZeroWord;
        end
        else if(current_state == `STATE_LOOK_UP)begin
            virtual_addr <= virtual_addr_i;
            cpu_wdata <= cpu_wdata_i;
        end
        else begin
            virtual_addr <= virtual_addr;
            cpu_wdata <= cpu_wdata_i;
        end
    end
    reg func;//�ߵ�ƽΪд���͵�ƽΪ��
    always@(posedge clk)begin
        if(current_state != `STATE_LOOK_UP)begin
            func <= func;
        end
        else if(cpu_wreq_i)
            func <= `WriteEnable;
        else if(cpu_rreq_i)
            func <= `WriteDisable;
        else
            func <= func;
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
   
    
    //BANK 0~7 WAY 0~1
    //biwj indicates bank_i way_j
//    reg [`WayBus] data_cache;
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
    bank_ram Bank0_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*1-1:32*0]),.douta(inst_cache_b0w0));
    bank_ram Bank1_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*2-1:32*1]),.douta(inst_cache_b1w0));
    bank_ram Bank2_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*3-1:32*2]),.douta(inst_cache_b2w0));
    bank_ram Bank3_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*4-1:32*3]),.douta(inst_cache_b3w0));
    bank_ram Bank4_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*5-1:32*4]),.douta(inst_cache_b4w0));
    bank_ram Bank5_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*6-1:32*5]),.douta(inst_cache_b5w0));
    bank_ram Bank6_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*7-1:32*6]),.douta(inst_cache_b6w0));
    bank_ram Bank7_way0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*8-1:32*7]),.douta(inst_cache_b7w0));
    
    wire [`RegBus]inst_cache_b0w1;
    wire [`RegBus]inst_cache_b1w1;
    wire [`RegBus]inst_cache_b2w1;
    wire [`RegBus]inst_cache_b3w1;
    wire [`RegBus]inst_cache_b4w1;
    wire [`RegBus]inst_cache_b5w1;
    wire [`RegBus]inst_cache_b6w1;
    wire [`RegBus]inst_cache_b7w1;                              
    bank_ram Bank0_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*1-1:32*0]),.douta(inst_cache_b0w1));
    bank_ram Bank1_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*2-1:32*1]),.douta(inst_cache_b1w1));
    bank_ram Bank2_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*3-1:32*2]),.douta(inst_cache_b2w1));
    bank_ram Bank3_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*4-1:32*3]),.douta(inst_cache_b3w1));
    bank_ram Bank4_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*5-1:32*4]),.douta(inst_cache_b4w1));
    bank_ram Bank5_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*6-1:32*5]),.douta(inst_cache_b5w1));
    bank_ram Bank6_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*7-1:32*6]),.douta(inst_cache_b6w1));
    bank_ram Bank7_way1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(virtual_addr[`IndexBus]), .dina(read_from_mem[32*8-1:32*7]),.douta(inst_cache_b7w1));

    //Tag+Valid
    wire [`TagVBus]tagv_cache_w0;
    wire [`TagVBus]tagv_cache_w1;
    tag_ram TagV0 (.clka(clk),.ena(`Enable),.wea(wea_way0),.addra(virtual_addr[`IndexBus]),.dina({1'b1,physical_addr[`TagBus]}),.douta(tagv_cache_w0));
    tag_ram TagV1 (.clka(clk),.ena(`Enable),.wea(wea_way1),.addra(virtual_addr[`IndexBus]),.dina({1'b1,physical_addr[`TagBus]}),.douta(tagv_cache_w1));
    
    //LRU
    reg [`SetBus]LRU;
    wire LRU_pick = LRU[virtual_addr[`IndexBus]];
    always@(posedge clk)begin
        if(rst)
            LRU <= 0;
        else if(cpu_inst_valid_o == `Valid && hit_o == `HitSuccess)
            LRU[virtual_addr[`IndexBus]] <= hit_way0;
        else if(cpu_inst_valid_o == `Valid && hit_o == `HitFail)
            LRU[virtual_addr[`IndexBus]] <= wea_way0;
        else
            LRU <= LRU;
    end
    
    //Dirty
    reg [`DirtyBus] dirty;
    always@(posedge clk)begin
        if(rst)
            dirty<=0;
        else if(current_state == `STATE_WRITE_BACK && func == `WriteEnable)
            dirty[virtual_addr[`IndexBus]] <= `True;
        else
            dirty <= dirty;
    end
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////״̬������////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

    reg [`StateBus]current_state;
    reg [`StateBus]next_state;
//    ״̬ת�ƶ���  
    always@(posedge clk)begin
        if(rst)
            current_state <= `STATE_LOOK_UP;
        else
            current_state <= next_state;
    end
    
//    ״̬ת�Ʊ� 
    always@(*)begin
        next_state <= `STATE_LOOK_UP;
        case(current_state)
            `STATE_LOOK_UP:begin
                if(cpu_rreq_i)begin
                    next_state <= `STATE_SCAN_CACHE;
                end
                else
                    next_state <= `STATE_LOOK_UP;
            end
            `STATE_SCAN_CACHE:begin
                if(hit_o && func == `WriteDisable)
                    next_state <= `STATE_LOOK_UP;
                if(hit_o && func == `WriteEnable)
                    next_state <= `STATE_WRITE_BACK;
                else
                    next_state <= `STATE_HIT_FAIL;
            end
            `STATE_HIT_FAIL:begin
                if(read_success)
                    next_state <= `STATE_WRITE_BACK;
                else
                    next_state <= `STATE_HIT_FAIL;
            end
            `STATE_WRITE_BACK:
                    next_state <= `STATE_LOOK_UP;
            default:;
        endcase
    end//always
    
    
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////����߼�//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
    
    //STATE_SCAN_CACHE��ѡ��ram�ж�Ӧ��bank
    reg [`InstBus]inst_way0;
    reg [`InstBus]inst_way1;
    //way0
    always@(*)begin
        case(virtual_addr[4:2])
            3'h0:inst_way0 <= inst_cache_b0w0;
            3'h1:inst_way0 <= inst_cache_b1w0;
            3'h2:inst_way0 <= inst_cache_b2w0;
            3'h3:inst_way0 <= inst_cache_b3w0;
            3'h4:inst_way0 <= inst_cache_b4w0;
            3'h5:inst_way0 <= inst_cache_b5w0;
            3'h6:inst_way0 <= inst_cache_b6w0;
            3'h7:inst_way0 <= inst_cache_b7w0;
            default: inst_way0 <= `ZeroWord;
        endcase
    end
    //way1
    always@(*)begin
        case(virtual_addr[4:2])
            3'h0:inst_way1 <= inst_cache_b0w1;
            3'h1:inst_way1 <= inst_cache_b1w1;
            3'h2:inst_way1 <= inst_cache_b2w1;
            3'h3:inst_way1 <= inst_cache_b3w1;
            3'h4:inst_way1 <= inst_cache_b4w1;
            3'h5:inst_way1 <= inst_cache_b5w1;
            3'h6:inst_way1 <= inst_cache_b6w1;
            3'h7:inst_way1 <= inst_cache_b7w1;
            default: inst_way1 <= `ZeroWord;
        endcase
    end
    //Tag Hit
    wire hit_way0 = (tagv_cache_w0[19:0]==physical_addr[`TagBus] && tagv_cache_w0[20]==`Valid)? `HitSuccess : `HitFail;
    wire hit_way1 = (tagv_cache_w1[19:0]==physical_addr[`TagBus] && tagv_cache_w1[20]==`Valid)? `HitSuccess : `HitFail;
    assign hit_o = (current_state==`STATE_SCAN_CACHE)? (hit_way0 | hit_way1) :`HitFail;
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
    
    
   //STATE_HIT_FAIL
   assign mem_ren_o = (current_state==`STATE_HIT_FAIL  &&  mem_arready_i == `Ready)?`ReadEnable : `ReadDisable;
   assign mem_rready_o = (current_state==`STATE_HIT_FAIL  &&  mem_rvalid_i == `Valid)?`ReadEnable : `ReadDisable;
   assign mem_arvalid_o = (current_state==`STATE_HIT_FAIL  &&  mem_arready_i == `Ready)?`Valid : `Invalid;
   assign mem_araddr_o = physical_addr;
   wire read_success = mem_rvalid_i;
   reg [`WayBus]read_from_mem;
   always@(posedge clk) begin 
        if(current_state==`STATE_HIT_FAIL )
            read_from_mem<= mem_rdata_i;
        else if(current_state == `STATE_WRITE_BACK && func == `WriteEnable)begin
            if(hit_way0_reg <= `HitSuccess)begin
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
            else if(hit_way1_reg <= `HitSuccess)begin
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
   
   
   //STATE_WRITE_BACK
    assign wea_way0 = (current_state==`STATE_WRITE_BACK && LRU_pick == 1'b0)? 4'b1111 : 4'h0;
    assign wea_way1 = (current_state==`STATE_WRITE_BACK && LRU_pick == 1'b1)? 4'b1111 : 4'h0;
    assign mem_ren_o = (current_state==`STATE_WRITE_BACK);
    
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////�������//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
    assign cpu_inst_o = (current_state==`STATE_SCAN_CACHE && hit_way0 == `HitSuccess)? inst_way0:
                        (current_state==`STATE_SCAN_CACHE && hit_way1 == `HitSuccess)? inst_way1:
                        (current_state==`STATE_WRITE_BACK &&virtual_addr[4:2] == 3'h0)? read_from_mem[32*1-1:32*0]:
                        (current_state==`STATE_WRITE_BACK &&virtual_addr[4:2] == 3'h1)? read_from_mem[32*2-1:32*1]:
                        (current_state==`STATE_WRITE_BACK &&virtual_addr[4:2] == 3'h2)? read_from_mem[32*3-1:32*2]:
                        (current_state==`STATE_WRITE_BACK &&virtual_addr[4:2] == 3'h3)? read_from_mem[32*4-1:32*3]:
                        (current_state==`STATE_WRITE_BACK &&virtual_addr[4:2] == 3'h4)? read_from_mem[32*5-1:32*4]:
                        (current_state==`STATE_WRITE_BACK &&virtual_addr[4:2] == 3'h5)? read_from_mem[32*6-1:32*5]:
                        (current_state==`STATE_WRITE_BACK &&virtual_addr[4:2] == 3'h6)? read_from_mem[32*7-1:32*6]:
                        (current_state==`STATE_WRITE_BACK &&virtual_addr[4:2] == 3'h7)? read_from_mem[32*8-1:32*7]:
                        `ZeroWord;
                        
    assign cpu_inst_valid_o = (current_state==`STATE_SCAN_CACHE && hit_o == `HitSuccess)? `Valid :
                              (current_state==`STATE_WRITE_BACK)                        ? `Valid :
                              `Invalid ;
endmodule