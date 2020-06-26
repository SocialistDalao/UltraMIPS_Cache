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
//--------*!状态具体操作!*
//----组合逻辑：
//--------LookUp阶段
//////////////////////////////////////////////////////////////////////////////////


module ICache(

    input wire clk,
    input wire rst,
    
    //read inst request
    input wire req_i,
    input wire [`RegBus]virtual_addr_i,
    
    //mem read result
    input wire mem_inst_valid_i,
    input wire [`InstBus]mem_inst_i,
    
    //ready to recieve request 
    output reg req_ready_o,
    //read inst result
    output wire hit_o,
    output reg inst_valid_o,
    output reg [`InstBus] inst_o
    );
    
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////初始定义//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
    wire [`RegBus]physical_addr;
    wire index = physical_addr[`IndexBus];
    wire offset = physical_addr[`OffsetBus];
    //TLB
    TLB tlb0(
    .rst(rst),
    .virtual_addr_i(virtual_addr_i),
    .physical_addr_o(physical_addr)
    );
   
    
    //BANK 0~7 WAY 0~1
    //biwj indicates bank_i way_j
    wire [`RegBus]inst_cache_b0w0;
    bank_ram Bank0_way0 (
  .clka(clk),    // input wire clka
  .ena(`ReadEnable),      // input wire ena
  .wea(wea),      // input wire [3 : 0] wea
  .addra(index),  // input wire [6 : 0] addra
  .dina(dina),    // input wire [31 : 0] dina
  .douta(inst_cache_b0w0)  // output wire [31 : 0] douta
);
    wire [`RegBus]inst_cache_b0w1;
    bank_ram Bank0_way1 (
  .clka(clk),    // input wire clka
  .ena(`ReadEnable),      // input wire ena
  .wea(wea),      // input wire [3 : 0] wea
  .addra(index),  // input wire [6 : 0] addra
  .dina(dina),    // input wire [31 : 0] dina
  .douta(inst_cache_b0w1)  // output wire [31 : 0] douta
);

    //Tag+Valid
    wire [23:0]tagv_cache_w0_tmp;
    wire [`TagVBus]tagv_cache_w0 = tagv_cache_w0_tmp[`TagVBus];
    tag_ram TagV0 (
      .clka(clk),    // input wire clka
      .ena(req_i),      // input wire ena
      .wea(wea),      // input wire [2 : 0] wea
      .addra(physical_addr[`IndexBus]),  // input wire [6 : 0] addra
      .dina(dina),    // input wire [23 : 0] dina
      .douta(tagv_cache_w0_tmp)  // output wire [23 : 0] douta
    );
    wire [23:0]tagv_cache_w1_tmp;
    wire [`TagVBus]tagv_cache_w1 = tagv_cache_w1_tmp[`TagVBus];
    tag_ram TagV1 (
      .clka(clk),    // input wire clka
      .ena(req_i),      // input wire ena
      .wea(wea),      // input wire [2 : 0] wea
      .addra(physical_addr[`IndexBus]),  // input wire [6 : 0] addra
      .dina(dina),    // input wire [23 : 0] dina
      .douta(tagv_cache_w1_tmp)  // output wire [23 : 0] douta
    );
    
    //LRU
    reg [`SetBus]LRU;
    
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
    always@(*)begin
        next_state <= `STATE_LOOK_UP;
        case(current_state)
            `STATE_LOOK_UP:begin
                
            end
            `STATE_SCAN_CACHE:begin
                if(hit_o)
                    next_state <= `STATE_LOOK_UP;
                else
                    next_state <= `STATE_HIT_FAIL;
            end
            `STATE_HIT_FAIL:
                next_state <= `STATE_WAIT_BUS;
            `STATE_WAIT_BUS:begin
                if(inst_valid_o)
                    next_state <= `STATE_LOOK_UP;
                else
                    next_state <= `STATE_WAIT_BUS;
            end
            default:;
        endcase
    end//always
    
    always@(*)begin
        case(current_state)
            `STATE_LOOK_UP:begin
                if(req_i)begin
                    next_state <= `STATE_SCAN_CACHE;
                end
                else
                    next_state <= `STATE_LOOK_UP;
            end
            `STATE_SCAN_CACHE:begin
                
            end
            `STATE_HIT_FAIL:
                next_state <= `STATE_WAIT_BUS;
            `STATE_WAIT_BUS:begin
                if(inst_valid_o)
                    next_state <= `STATE_LOOK_UP;
                else
                    next_state <= `STATE_WAIT_BUS;
            end
            default:;
        endcase
    end
    
    
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////组合逻辑//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
    
    //ScanCache：选择ram中对应的bank
    reg [`InstBus]inst_way0;
    reg [`InstBus]inst_way1;
    //way0
    always@(*)begin
        inst_way0 <= `ZeroWord;
        case(physical_addr[4:2])
            3'h0:inst_way0 <= inst_cache_b0w0;
            3'h1:inst_way0 <= inst_cache_b0w0;
            3'h2:inst_way0 <= inst_cache_b0w0;
            3'h3:inst_way0 <= inst_cache_b0w0;
            3'h4:inst_way0 <= inst_cache_b0w0;
            3'h5:inst_way0 <= inst_cache_b0w0;
            3'h6:inst_way0 <= inst_cache_b0w0;
            3'h7:inst_way0 <= inst_cache_b0w0;
            default:;
        endcase
    end
    //way0
    always@(*)begin
        inst_way1 <= `ZeroWord;
        case(physical_addr[4:2])
            3'h0:inst_way1 <= inst_cache_b0w1;
            3'h1:inst_way1 <= inst_cache_b0w1;
            3'h2:inst_way1 <= inst_cache_b0w1;
            3'h3:inst_way1 <= inst_cache_b0w1;
            3'h4:inst_way1 <= inst_cache_b0w1;
            3'h5:inst_way1 <= inst_cache_b0w1;
            3'h6:inst_way1 <= inst_cache_b0w1;
            3'h7:inst_way1 <= inst_cache_b0w1;
            default:;
        endcase
    end
    reg hit_way0;
    reg hit_way1;
    assign hit_o = hit_way0 | hit_way1;
    always@(*)begin
        if(hit_way0)
            inst_o <= inst_way0;
        else
            inst_o <= inst_way1;
    end
    
   
endmodule
