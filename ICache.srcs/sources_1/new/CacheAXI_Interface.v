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


module CacheAXI_Interface(
    input clk,
    input rst,
	//ICahce: Read Channel
    input wire inst__ren_i,
    input wire inst_rready_i,
    input wire inst_arvalid_i,
    input wire[`InstAddrBus]mem_araddr_i
	output wire inst_rvalid_o,
	output wire inst_arready_o,
	output wire [`WayBus]inst_rdata_o//DCache: Read Channel
	
	//DCache: Write Channel
    input wire data_ren_i,
    input wire data_rready_i,
    input wire data_arvalid_i,
    input wire[`DataAddrBus]data_araddr_i,
    output wire data_rvalid_o,
    output wire data_arready_o,
    output wire [`WayBus]data_rdata_o,//һ����Ĵ�С
	
	//mem write
    input wire mem_wready_i,
    input wire mem_awready_i,
    input wire mem_bvalid,
    output wire mem_wvalid_o,
    output wire[`WayBus] mem_wdata_o,//һ����Ĵ�С
    output wire mem_awvalid_o,
    output wire [`DataAddrBus]mem_awaddr_o,
    output wire mem_bready,
	
	
	//AXI Communicate
	input reg[`RegBus]    rdata_i,        //���ص�cache�Ķ�ȡ����
	input reg             rdata_valid_i,  //�������ݿɻ�ȡ
	input reg             wdata_resp_i,   //д��Ӧ,ÿ��beat��һ�Σ��ɹ�����Դ���һ����
	output wire             axi_ce_o,
	output wire             axi_wr_o,
	output wire[3:0]        axi_sel_o,
	output wire[`RegBus]    axi_addr_o,
	output wire[`RegBus]    axi_wdata_o,    //cache��ñ�֤��ÿ��ʱ���ظ���Ҫд������
	output wire             axi_rready_o,   //cache��׼���ö�
	output wire             axi_wvalid_o,   //cache��׼����д�����ݣ�����ǳ���
	output wire             axi_wlast_o,    //cacheд���һ������
    );
	//Ԥ��ֵ
	
	
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
	//��ͻ���
	reg [`FIFONum-1:0]hit;
	always@(*)begin
		hit <= `FIFONum'h0;
		if(cpu_araddr == FIFO_addr[0] && FIFO_valid[0])begin
			hit[0] <= `HitSuccess;
		end
		else if(cpu_araddr == FIFO_addr[1] && FIFO_valid[1])begin
			hit[1] <= `HitSuccess;
		end
		else if(cpu_araddr == FIFO_addr[2] && FIFO_valid[2])begin
			hit[2] <= `HitSuccess;
		end
		else if(cpu_araddr == FIFO_addr[3] && FIFO_valid[3])begin
			hit[3] <= `HitSuccess;
		end
		else if(cpu_araddr == FIFO_addr[4] && FIFO_valid[4])begin
			hit[4] <= `HitSuccess;
		end
		else if(cpu_araddr == FIFO_addr[5] && FIFO_valid[5])begin
			hit[5] <= `HitSuccess;
		end
		else if(cpu_araddr == FIFO_addr[6] && FIFO_valid[6])begin
			hit[6] <= `HitSuccess;
		end
		else if(cpu_araddr == FIFO_addr[7] && FIFO_valid[7])begin
			hit[7] <= `HitSuccess;
		end
	end
	
	//���б���
	//д�루����д��ͻ��
    reg [`FIFONum-1:0]FIFO_data[`WayBus];
    reg [`FIFONum-1:0]FIFO_addr[`DataAddrBus];
    always@(posedge clk)begin
        if(cpu_wreq_i == `WriteEnable)begin
			case(hit)
				`FIFONum'b00000001: FIFO_data[0] <= cpu_wdata_i;
				`FIFONum'b00000010: FIFO_data[1] <= cpu_wdata_i;
				`FIFONum'b00000100: FIFO_data[2] <= cpu_wdata_i;
				`FIFONum'b00001000: FIFO_data[3] <= cpu_wdata_i;
				`FIFONum'b00010000: FIFO_data[4] <= cpu_wdata_i;
				`FIFONum'b00100000: FIFO_data[5] <= cpu_wdata_i;
				`FIFONum'b01000000: FIFO_data[6] <= cpu_wdata_i;
				`FIFONum'b10000000: FIFO_data[7] <= cpu_wdata_i;
				default:begin//û�г�ͻ����Ӳ���
					FIFO_data[tail] <= cpu_wdata_i;
					FIFO_addr[tail] <= cpu_awaddr;
				end
			endcase
        end//if
		//������ʱ�򱣳�ԭ״
    end//always
	
	//����ͻ
	always@(*)begin
		if(cpu_rreq_i)begin
			case(hit)
				`FIFONum'b00000001: cpu_rdata_o <= FIFO_data[0];
				`FIFONum'b00000010: cpu_rdata_o <= FIFO_data[1];
				`FIFONum'b00000100: cpu_rdata_o <= FIFO_data[2];
				`FIFONum'b00001000: cpu_rdata_o <= FIFO_data[3];
				`FIFONum'b00010000: cpu_rdata_o <= FIFO_data[4];
				`FIFONum'b00100000: cpu_rdata_o <= FIFO_data[5];
				`FIFONum'b01000000: cpu_rdata_o <= FIFO_data[6];
				`FIFONum'b10000000: cpu_rdata_o <= FIFO_data[7];
				default:  cpu_rdata_o <= `ZeroWay;
			endcase
		end
		else begin
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
