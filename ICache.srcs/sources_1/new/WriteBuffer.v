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
	//CPU read request and response
    input wire cpu_rreq_i,
    input wire [`DataAddrBus]cpu_araddr_i,
	output reg read_hit_o,
	output reg [`WayBus]cpu_rdata_o,
	
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
	//��ַ���봦��
	wire [`DataAddrBus]cpu_awaddr = {cpu_awaddr_i[31:5],5'h0};
	wire [`DataAddrBus]cpu_araddr = {cpu_araddr_i[31:5],5'h0};
	
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
    reg [`FIFONum-1:0]FIFO_valid;//����buffer�е������Ƿ���Ч���ߵ�ƽ��Ч��
    always@(posedge clk)begin
        if(rst)begin
            head <= `FIFONumLog2'h0;
            tail <= `FIFONumLog2'h0;
			FIFO_valid <= `FIFONum'h0;
        end
        else if( mem_bvalid == `Valid)begin//д�����
			FIFO_valid[head] <= `Invalid;
            head <= head + 1;
		end
        else if(cpu_wreq_i == `WriteEnable)begin //����д�룬���
            tail <= tail + 1;
			FIFO_valid[tail] <= `Valid;
		end
        else begin
            head <= head;
            tail <= tail;
			FIFO_valid <= FIFO_valid;
        end
    end
	
    //����д�룬����д��ͻ
    reg [`FIFONum-1:0]FIFO_data[`WayBus];
    reg [`FIFONum-1:0]FIFO_addr[`DataAddrBus];
    always@(posedge clk)begin
        if(cpu_wreq_i == `WriteEnable)begin
			if(cpu_awaddr == FIFO_addr[0] && FIFO_valid[0])begin
                FIFO_data[0] <= cpu_wdata_i;
			end
			if(cpu_awaddr == FIFO_addr[1] && FIFO_valid[1])begin
                FIFO_data[1] <= cpu_wdata_i;
			end
			if(cpu_awaddr == FIFO_addr[2] && FIFO_valid[2])begin
                FIFO_data[2] <= cpu_wdata_i;
			end
			if(cpu_awaddr == FIFO_addr[3] && FIFO_valid[3])begin
                FIFO_data[3] <= cpu_wdata_i;
			end
			if(cpu_awaddr == FIFO_addr[4] && FIFO_valid[4])begin
                FIFO_data[4] <= cpu_wdata_i;
			end
			if(cpu_awaddr == FIFO_addr[5] && FIFO_valid[5])begin
                FIFO_data[5] <= cpu_wdata_i;
			end
			if(cpu_awaddr == FIFO_addr[6] && FIFO_valid[6])begin
                FIFO_data[6] <= cpu_wdata_i;
			end
			if(cpu_awaddr == FIFO_addr[7] && FIFO_valid[7])begin
                FIFO_data[7] <= cpu_wdata_i;
			end
			else begin//û�г�ͻ����Ӳ���
                FIFO_data[tail] <= cpu_wdata_i;
                FIFO_addr[tail] <= cpu_awaddr;
            end
        end//if
		//������ʱ�򱣳�ԭ״
    end//always
	
	//����ͻ
	always@(*)begin
		if(cpu_rreq_i)begin
			if(cpu_araddr == FIFO_addr[0] && FIFO_valid[0])begin
				read_hit_o <= `HitSuccess;
				cpu_rdata_o <= FIFO_data[0];
			end
			if(cpu_araddr == FIFO_addr[1] && FIFO_valid[1])begin
				read_hit_o <= `HitSuccess;
				cpu_rdata_o <= FIFO_data[1];
			end
			if(cpu_araddr == FIFO_addr[2] && FIFO_valid[2])begin
				read_hit_o <= `HitSuccess;
				cpu_rdata_o <= FIFO_data[2];
			end
			if(cpu_araddr == FIFO_addr[3] && FIFO_valid[3])begin
				read_hit_o <= `HitSuccess;
				cpu_rdata_o <= FIFO_data[3];
			end
			if(cpu_araddr == FIFO_addr[4] && FIFO_valid[4])begin
				read_hit_o <= `HitSuccess;
				cpu_rdata_o <= FIFO_data[4];
			end
			if(cpu_araddr == FIFO_addr[5] && FIFO_valid[5])begin
				read_hit_o <= `HitSuccess;
				cpu_rdata_o <= FIFO_data[5];
			end
			if(cpu_araddr == FIFO_addr[6] && FIFO_valid[6])begin
				read_hit_o <= `HitSuccess;
				cpu_rdata_o <= FIFO_data[6];
			end
			if(cpu_araddr == FIFO_addr[7] && FIFO_valid[7])begin
				read_hit_o <= `HitSuccess;
				cpu_rdata_o <= FIFO_data[7];
			end
			else begin
				read_hit_o <= `HitFail;
				cpu_rdata_o <= `ZeroWay;
			end
		end
		else begin
				read_hit_o <= `HitFail;
				cpu_rdata_o <= `ZeroWay;
		end
	end
    
    
    //���ߴ���
    assign mem_bready=1'b1;
    assign mem_wvalid_o = (state_o == `STATE_EMPTY)? `Invalid:`Valid;
    assign mem_awvalid_o = (state_o == `STATE_EMPTY)? `Invalid:`Valid;
    assign mem_awaddr_o = FIFO_addr[head];
    assign mem_wdata_o = FIFO_data[head];
endmodule
