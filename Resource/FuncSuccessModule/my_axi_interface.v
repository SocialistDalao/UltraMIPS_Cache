`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UltraMIPS
// Engineer: ghc
// 
// Create Date: 2020/06/23 14:31:11
// Design Name: 
// Module Name: my_axi_interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: test edition
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"
module my_axi_interface(
        input              clk,
        input              resetn, 
        
        input              flush,
        input wire[5:0]    stall,
        output reg         stallreq,//?????
                
        //Cache////////
        input wire             cache_ce,
        input wire             cache_wen,
        input wire             cache_ren,
        input wire[3:0]        cache_sel,
        input wire[`RegBus]    cache_raddr,
        input wire[`RegBus]    cache_waddr,  
        input wire[`RegBus]    cache_wdata,    //cache最好保证在每个时钟沿更新要写的内容
        input wire             cache_rready,   //cache端准备好读
        input wire             cache_wvalid,   //cache端准备好写的数据，最好是持续
        input wire             cache_wlast,    //cache写最后一个数据
        //output reg[`RegBus]    rdata_o,        //返回到cache的读取数据
        //output reg             rdata_valid_o,  //返回数据可获取
        output wire[`RegBus]    rdata_o,
        output wire             rdata_valid_o,
        output wire            wdata_resp_o,   //写响应,每个beat发一次，成功则可以传下一数据
        //burst
        input wire[`AXBURST]   cache_burst_type, 
        input wire[`AXSIZE]    cache_burst_size,
        input wire[`AXLEN]     cacher_burst_length,
        input wire[`AXLEN]     cachew_burst_length,
       
        //axi///////
        //ar
        output [3 :0]    arid         ,
        output reg[31:0] araddr       ,
        output reg[7 :0] arlen        ,
        output reg[2 :0] arsize       ,
        output reg[1 :0] arburst      ,
        output [1 :0]    arlock       ,
        output reg[3 :0] arcache      ,
        output [2 :0]    arprot       ,
        output reg       arvalid      ,
        input            arready      ,
        
        //r           
        input  [3 :0] rid          ,
        input  [31:0] rdata        ,
        input  [1 :0] rresp        ,
        input         rlast        ,
        input         rvalid       ,
        output reg    rready       ,
        
        //aw          
        output [3 :0]    awid         ,
        output reg[31:0] awaddr       ,
        output reg[7 :0] awlen        ,
        output reg[2 :0] awsize       ,
        output reg[1 :0] awburst      ,
        output [1 :0]    awlock       ,
        output reg[3 :0] awcache      ,
        output [2 :0]    awprot       ,
        output reg       awvalid      ,
        input            awready      ,
        
        //w          
        output [3 :0]    wid          ,
        //output reg[31:0] wdata        ,
        output reg[31:0] wdata        ,
        output reg[3 :0] wstrb        ,
        output reg       wlast        ,
        output reg       wvalid       ,
        input            wready       ,
        
        //b           
        input  [3 :0] bid          ,
        input  [1 :0] bresp        ,
        input         bvalid       ,
        output        bready       
    );
    
    reg[3:0] rcurrent_state;
    reg[3:0] rnext_state;
    
    reg[3:0] wcurrent_state;
    reg[3:0] wnext_state;
    
    assign arid = 4'b0000;
    assign arlock = `AXLOCK_NORMAL;
    assign arprot = 3'b000;
    
    assign awid = 4'b0000;
    assign awlock = `AXLOCK_NORMAL;
    assign awprot = 3'b000;
    
    assign wid = 4'b0000;
    assign bready = `True_v;
    
    assign wdata_resp_o = wready;
    //assign wdata = cache_wdata;
    assign rdata_valid_o = rvalid;
    assign rdata_o = rdata;
    
    always@(posedge clk)begin
        if(resetn == `RstEnable || flush == `True_v)begin
            rcurrent_state <= `AXI_IDLE;
            wcurrent_state <= `AXI_IDLE;
        end else begin
            rcurrent_state <= rnext_state;
            wcurrent_state <= wnext_state;
        end
    end
    
    //次态
    always@(*)begin
        if(resetn == `RstEnable || flush == `True_v)begin
            rnext_state = `AXI_IDLE;
        end else begin
            case(rcurrent_state)
            `AXI_IDLE: begin
                if(cache_ce == `True_v && cache_ren == `True_v)begin
                    rnext_state = `ARVALID;
                end else begin
                    rnext_state = `AXI_IDLE;
                end
            end
            `ARVALID:  begin
                if(rlast == `True_v)begin
                    rnext_state = `AXI_IDLE;
                end else begin
                    rnext_state = `ARVALID;
                end
            end
            default: rnext_state = `AXI_IDLE;
            endcase
        end
    end
    
    always@(*)begin
        if(resetn == `RstEnable || flush == `True_v)begin
            wnext_state = `AXI_IDLE;
        end else begin
            case(wcurrent_state)
            `AXI_IDLE: begin
                if(cache_ce == `True_v && cache_wen == `True_v)begin
                    wnext_state = `AWVALID;
                end else begin
                    wnext_state = `AXI_IDLE;
                end
            end
            `AWVALID:  begin
                if(wlast == `True_v)begin
                    wnext_state = `AXI_IDLE;
                end else begin
                    wnext_state = `AWVALID;
                end
            end
            `BREADY:   begin
                if(bready == `True_v)begin
                    wnext_state = `AXI_IDLE; 
                end else begin
                    wnext_state = `BREADY;
                end
            end
            default: wnext_state = `AXI_IDLE;
            endcase
        end
    end
    
     //输出信号
    
    always@(posedge clk)begin  ///???
        if(resetn == `RstEnable || flush == `True_v)begin
            araddr <= `ZeroWord;      
            arlen <= 4'b0000;     
            arsize <= `AXSIZE_FOUR_BYTE;       
            arburst <= `AXBURST_FIXED;
            arcache <= 4'b0000;
            arvalid <= `False_v;
            
            rready <= `False_v;
            
            awaddr <= `ZeroWord;       
            awlen <= 4'b0000;       
            awsize <= `AXSIZE_FOUR_BYTE;      
            awburst <= `AXBURST_FIXED;   
            awcache <= 4'b0000;
            awvalid <= `False_v;
            
            wvalid <= `False_v;
            //wdata <= `ZeroWord;
            wstrb <= 4'b0000;
            wlast <= `False_v;
            wdata <= `ZeroWord;
            //rdata_o <= `ZeroWord;
            //rdata_valid_o <= `False_v;
            //wdata_resp_o <= `False_v;
           
        end else begin
            case(rcurrent_state)
            `AXI_IDLE: begin                               
                rready <= `False_v;                                                                     
                //rdata_o <= `ZeroWord;
                //rdata_valid_o <= `False_v;
                if(cache_ce == `True_v && cache_ren == `True_v)begin  //读请求
                    arlen <= cacher_burst_length;     
                    arsize <= cache_burst_size;       
                    arburst <= cache_burst_type; 
                    arcache <= 4'b0000;    //待定
                    arvalid <= `True_v;
                    araddr <= cache_raddr;
                end else begin  //无操作
                    arvalid <= `False_v;
                    araddr <= `ZeroWord;
                    arlen <= 4'b0000;     
                    arsize <= `AXSIZE_FOUR_BYTE;       
                    arburst <= `AXBURST_FIXED;
                    arcache <= 4'b0000;
                end
            end
            `ARVALID:  begin
                if(arready == `True_v)begin  //握手成功，撤下AR信号,拉高rready
                    araddr <= `ZeroWord;      
                    arlen <= 4'b0000;     
                    arsize <= `AXSIZE_FOUR_BYTE;       
                    arburst <= `AXBURST_FIXED;
                    arcache <= 4'b0000;
                    arvalid <= `False_v;
                    rready <= `True_v; 
                end else begin
                    
                end

                if(rvalid == `True_v)begin
                    //rdata_o <= rdata;
                    //rdata_valid_o <= `True_v;
                end else begin
                    //rdata_o <= `ZeroWord;
                    //rdata_valid_o <= `False_v;
                end
            end
            default:;
            endcase
            
            case(wcurrent_state)
            `AXI_IDLE: begin                                                                                                
                wvalid <= `False_v;      
                //wdata <= `ZeroWord;
                wstrb <= 4'b0000;
                wlast <= `False_v;   
                //wdata_resp_o <= `False_v;       
                
                if(cache_ce == `True_v && cache_wen == `True_v)begin  //写请求
                    awlen <= cachew_burst_length;       
                    awsize <= cache_burst_size;      
                    awburst <= cache_burst_type;   
                    awcache <= 4'b0000;    //待定         
                    awvalid <= `True_v;
                    awaddr <= cache_waddr;
                end else begin  //无操作
          
                end
            end
            `AWVALID:  begin
                wvalid <= cache_wvalid;
                //wdata <= cache_wdata;
                wlast <= cache_wlast;
                wstrb <= cache_sel;
                
                if(awready == `True_v)begin  //握手成功
                    wdata <= cache_wdata;
                    awlen <= 4'b0000;       
                    awsize <= `AXSIZE_FOUR_BYTE;      
                    awburst <= `AXBURST_FIXED;   
                    awcache <= 4'b0000;    //待定         
                    awvalid <= `False_v;
                    awaddr <= `ZeroWord;
                end else begin
                    
                end
                
                if(wready == `True_v)begin              
                    //wdata_resp_o <= `True_v;
                end else begin
                    //wdata_resp_o <= `False_v;
                end  
            end
            `BREADY:   begin
                //wdata_resp_o <= `False_v; 
                if(bvalid ==`True_v)begin
                    case(bresp)
                    `AXRESP_OKAY:begin    //预留
                    
                    end
                    `AXRESP_EXOKAY:begin  //预留
                    
                    end
                    `AXRESP_SLVERR:begin  //预留
                    
                    end
                    `AXRESP_DECERR:begin  //预留
                    
                    end
                    default:;
                    endcase
                end
            end
            default:;        
            endcase
        end
    end

endmodule
