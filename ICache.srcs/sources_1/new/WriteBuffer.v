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
	output wire write_hit_o,
	//CPU read request and response
    input wire cpu_rreq_i,
    input wire [`DataAddrBus]cpu_araddr_i,
	output wire read_hit_o,
	output reg [`WayBus]cpu_rdata_o,
	
    //state
    output reg [`FIFOStateBus]state_o,
	
    //MEM 
    input wire mem_bvalid_i,
    output wire mem_wen_o,
    output wire[`WayBus] mem_wdata_o,//一个块的大小
    output wire [`DataAddrBus]mem_awaddr_o
    );
	//地址对齐处理
	wire [`DataAddrBus]cpu_awaddr = {cpu_awaddr_i[31:5],5'h0};
	wire [`DataAddrBus]cpu_araddr = {cpu_araddr_i[31:5],5'h0};
	
    //当前队列状态
    reg[`FIFONumLog2-1:0] count;
    always@(posedge clk)begin
        if(rst)
            count <= `FIFONumLog2'h0;
        else if( mem_bvalid_i == `Valid)
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
    reg [`FIFONum-1:0]FIFO_valid;//表征buffer中的数据是否有效（高电平有效）
    always@(posedge clk)begin
        if(rst)begin
            head <= `FIFONumLog2'h0;
            tail <= `FIFONumLog2'h0;
			FIFO_valid <= `FIFONum'h0;
        end
        if( mem_bvalid_i == `Valid)begin//写入完毕
			FIFO_valid[head] <= `Invalid;
            head <= head + 1;
		end
        if(cpu_wreq_i == `WriteEnable && write_hit_o == `HitFail)begin //增加写入，入队
            tail <= tail + 1;
			FIFO_valid[tail] <= `Valid;
		end
    end
	
	
	//队列本体
    reg [`FIFONum-1:0]FIFO_data[`WayBus];
    reg [`FIFONum-1:0]FIFO_addr[`DataAddrBus];
    //数据写入，包括写冲突
	//冲突检测
	reg [`FIFONum-1:0]read_hit;
	assign read_hit_o = read_hit[7]| read_hit[6]| read_hit[5]| read_hit[4]| read_hit[3]| read_hit[2]| read_hit[1]| read_hit[0];
	always@(*)begin
		read_hit <= `FIFONum'h0;
		if(cpu_araddr == FIFO_addr[0] && FIFO_valid[0])begin
			read_hit[0] <= `HitSuccess;
		end
		else if(cpu_araddr == FIFO_addr[1] && FIFO_valid[1])begin
			read_hit[1] <= `HitSuccess;
		end
		else if(cpu_araddr == FIFO_addr[2] && FIFO_valid[2])begin
			read_hit[2] <= `HitSuccess;
		end
		else if(cpu_araddr == FIFO_addr[3] && FIFO_valid[3])begin
			read_hit[3] <= `HitSuccess;
		end
		else if(cpu_araddr == FIFO_addr[4] && FIFO_valid[4])begin
			read_hit[4] <= `HitSuccess;
		end
		else if(cpu_araddr == FIFO_addr[5] && FIFO_valid[5])begin
			read_hit[5] <= `HitSuccess;
		end
		else if(cpu_araddr == FIFO_addr[6] && FIFO_valid[6])begin
			read_hit[6] <= `HitSuccess;
		end
		else if(cpu_araddr == FIFO_addr[7] && FIFO_valid[7])begin
			read_hit[7] <= `HitSuccess;
		end
	end
	
	reg [`FIFONum-1:0]write_hit;
	assign write_hit_o = write_hit[7]| write_hit[6]| write_hit[5]| write_hit[4]| write_hit[3]| write_hit[2]| write_hit[1]| write_hit[0];
	always@(*)begin
		write_hit <= `FIFONum'h0;
		if(cpu_awaddr_i == FIFO_addr[tail] && FIFO_valid[tail])begin
			write_hit[tail] <= `HitSuccess;
		end
		else if(cpu_awaddr_i == FIFO_addr[tail-1] && FIFO_valid[tail-1])begin
			write_hit[tail-1] <= `HitSuccess;
		end
		else if(cpu_awaddr_i == FIFO_addr[tail-2] && FIFO_valid[tail-2])begin
			write_hit[tail-2] <= `HitSuccess;
		end
		else if(cpu_awaddr_i == FIFO_addr[tail-3] && FIFO_valid[tail-3])begin
			write_hit[tail-3] <= `HitSuccess;
		end
		else if(cpu_awaddr_i == FIFO_addr[tail-4] && FIFO_valid[tail-4])begin
			write_hit[tail-4] <= `HitSuccess;
		end
		else if(cpu_awaddr_i == FIFO_addr[tail-5] && FIFO_valid[tail-5])begin
			write_hit[tail-5] <= `HitSuccess;
		end
		else if(cpu_awaddr_i == FIFO_addr[tail-6] && FIFO_valid[tail-6])begin
			write_hit[tail-6] <= `HitSuccess;
		end
		else if(cpu_awaddr_i == FIFO_addr[tail-7] && FIFO_valid[tail-7])begin
			write_hit[tail-7] <= `HitSuccess;
		end
	end
	
	//写入（包括写冲突）
    always@(posedge clk)begin
        if(cpu_wreq_i == `WriteEnable && write_hit_o == `HitSuccess)begin
			case(write_hit)
				`FIFONum'b00000001: FIFO_data[0] <= cpu_wdata_i;
				`FIFONum'b00000010: FIFO_data[1] <= cpu_wdata_i;
				`FIFONum'b00000100: FIFO_data[2] <= cpu_wdata_i;
				`FIFONum'b00001000: FIFO_data[3] <= cpu_wdata_i;
				`FIFONum'b00010000: FIFO_data[4] <= cpu_wdata_i;
				`FIFONum'b00100000: FIFO_data[5] <= cpu_wdata_i;
				`FIFONum'b01000000: FIFO_data[6] <= cpu_wdata_i;
				`FIFONum'b10000000: FIFO_data[7] <= cpu_wdata_i;
				default:begin//没有冲突的入队操作
					FIFO_data[tail] <= cpu_wdata_i;
					FIFO_addr[tail] <= cpu_awaddr;
				end
			endcase
        end//if
		else begin//没有冲突的入队操作
				FIFO_data[tail] <= cpu_wdata_i;
				FIFO_addr[tail] <= cpu_awaddr;
		end
    end//always
	
	//读冲突
	always@(*)begin
		if(cpu_rreq_i)begin
			case(read_hit)
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
    
    
    //总线处理
    assign mem_wen_o = (state_o == `STATE_EMPTY)? `Invalid:`Valid;
    assign mem_awaddr_o = FIFO_addr[head];
    assign mem_wdata_o = FIFO_data[head];
endmodule
