`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/05 17:28:24
// Design Name: 
// Module Name: WriteBuffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module WriteBuffer(
    input clk,
    input rst,
    //CPU write request
    input wire cpu_wreq_i,
    input wire [`DataAddrBus]cpu_awaddr_i,
    input wire [`WayBus]cpu_wdata_i,//一个块的大小
    //state
    output reg [`FIFOStateBus]state_o,
    //MEM 
    input wire mem_wready_i,
    output wire mem_wvalid_o,
    output wire[`WayBus] mem_wdata_o,//一个块的大小
    input wire mem_awready_i,
    output wire mem_awvalid_o,
    output wire [`DataAddrBus]mem_awaddr_o,
    input wire mem_bvalid,
    output wire mem_bready
    );
    //当前队列状态
    reg[`FIFONumLog2-1:0] count;
    always@(posedge clk)begin
        if(rst)
            count <= `FIFONumLog2'h0;
        else if( mem_bvalid == `Valid)
            count <= count - 1;
        else if(cpu_wreq_i == `WriteEnable)
            count <= count + 1;
        else
            count <= count;
    end
    always@(*)begin
        if(rst)begin
            state_o <= `STATE_EMPTY;
        end
        else if(count == `FIFONum)begin
            state_o <= `STATE_FULL;
        end
        else if(count == `FIFONumLog2'h0)begin
            state_o <= `STATE_EMPTY;
        end
        else begin
            state_o <= `STATE_WORKING;
        end
    end
    
    
    //队列
    //头尾指针维护
    reg [`FIFONumLog2-1:0]tail;//表征当前正在写入的数据位置
    reg [`FIFONumLog2-1:0]head;//表征最后需要写入数据位置的后一位
    always@(posedge clk)begin
        if(rst)begin
            head <= `FIFONumLog2'h0;
            tail <= `FIFONumLog2'h0;
        end
        else if( mem_bvalid == `Valid)//写入完毕
            head <= head + 1;
        else if(cpu_wreq_i == `WriteEnable)//增加写入，入队
            tail <= tail + 1;
        else begin
            head <= head;
            tail <= tail;
        end
    end
    //数据写入
    reg [`FIFONum-1:0]FIFO_data[`WayBus];
    reg [`FIFONum-1:0]FIFO_addr[`DataAddrBus];
    always@(posedge clk)begin
        if(cpu_wreq_i == `WriteEnable)begin//增加写入
            FIFO_data[tail] <= cpu_wdata_i;
            FIFO_addr[tail] <= cpu_awaddr_i;
        end
    end
    
    
    //总线处理
    assign mem_bready=1'b1;
    always@(posedge clk)begin
        
    end
endmodule
