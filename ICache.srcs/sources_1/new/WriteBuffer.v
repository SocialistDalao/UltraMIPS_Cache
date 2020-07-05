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
    input wire [`WayBus]cpu_wdata_i,//һ����Ĵ�С
    //state
    output reg [`FIFOStateBus]state_o,
    //MEM 
    input wire mem_wready_i,
    output wire mem_wvalid_o,
    output wire[`WayBus] mem_wdata_o,//һ����Ĵ�С
    input wire mem_awready_i,
    output wire mem_awvalid_o,
    output wire [`DataAddrBus]mem_awaddr_o,
    input wire mem_bvalid,
    output wire mem_bready
    );
    //��ǰ����״̬
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
    
    
    //����
    //ͷβָ��ά��
    reg [`FIFONumLog2-1:0]tail;//������ǰ����д�������λ��
    reg [`FIFONumLog2-1:0]head;//���������Ҫд������λ�õĺ�һλ
    always@(posedge clk)begin
        if(rst)begin
            head <= `FIFONumLog2'h0;
            tail <= `FIFONumLog2'h0;
        end
        else if( mem_bvalid == `Valid)//д�����
            head <= head + 1;
        else if(cpu_wreq_i == `WriteEnable)//����д�룬���
            tail <= tail + 1;
        else begin
            head <= head;
            tail <= tail;
        end
    end
    //����д��
    reg [`FIFONum-1:0]FIFO_data[`WayBus];
    reg [`FIFONum-1:0]FIFO_addr[`DataAddrBus];
    always@(posedge clk)begin
        if(cpu_wreq_i == `WriteEnable)begin//����д��
            FIFO_data[tail] <= cpu_wdata_i;
            FIFO_addr[tail] <= cpu_awaddr_i;
        end
    end
    
    
    //���ߴ���
    assign mem_bready=1'b1;
    always@(posedge clk)begin
        
    end
endmodule
