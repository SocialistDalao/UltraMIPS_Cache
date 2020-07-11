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
    input wire inst_ren_i,
    input wire[`InstAddrBus]mem_araddr_i,
	output wire inst_rvalid_o,
	output wire [`WayBus]inst_rdata_o,//DCache: Read Channel
	
	//DCache: Read Channel
    input wire data_ren_i,
    input wire[`DataAddrBus]data_araddr_i,
    output wire data_rvalid_o,
    output wire [`WayBus]data_rdata_o,//一个块的大小
	
	//DCache: Write Channel
    input wire data_wen_i,
    input wire[`WayBus]data_wdata_i,//一个块的大小
    input wire [`DataAddrBus]data_awaddr_i,
    output wire data_bvalid_o,
	
	//AXI Communicate
	output reg             axi_ce_o,
	output reg[3:0]        axi_sel_o,
	//AXI read
	input wire[`RegBus]    rdata_i,        //返回到cache的读取数据
	input wire             rdata_valid_i,  //返回数据可获取
	output reg             axi_ren_o,
	output reg             axi_rready_o,   //cache端准备好读
	output reg[`RegBus]    axi_raddr_o,
	//AXI write
	input wire             wdata_resp_i,   //写响应,每个beat发一次，成功则可以传下一数据
	output reg             axi_wen_o,
	output reg[`RegBus]    axi_waddr_o,
	output reg[`RegBus]    axi_wdata_o,    //cache最好保证在每个时钟沿更新要写的内容
	output reg             axi_wvalid_o,   //cache端准备好写的数据，最好是持续
	output reg             axi_wlast_o    //cache写最后一个数据
    );
	assign  axi_ce_o = (rst == `RstEnable)? `ChipDisable: `ChipEnable;
	assign  axi_sel_o = 4'b1111;//byte select
	
	
	//READ(DCache first)
	//state
	reg [1:0]read_state;
	reg[2:0]read_count;
	always@(posedge clk）begin
		if(rst) 
			read_state <= `STATE_READ_FREE;
		else if( read_state == `STATE_READ_FREE && data_ren_i == `ReadEnable)//DCache
			read_state <= `STATE_READ_DCACHE;
		else if( read_state == `STATE_READ_DCACHE && rdata_valid_i == `Valid && read_count == 3'h7 )//last read successful
			read_state <= `STATE_READ_FREE;
		else if( read_state == `STATE_READ_FREE && inst_ren_i == `ReadEnable)//ICache
			read_state <= `STATE_READ_ICACHE;
		else if( read_state == `STATE_READ_ICACHE && rdata_valid_i == `Valid && read_count == 3'h7 )//last read successful
			read_state <= `STATE_READ_FREE;
		else
			read_state <= read_state;
	end
	always@(posedge clk)begin
		if(read_state == `STATE_READ_FREE)
			read_count <= 3'h0;
		else if(rdata_valid_i == `Valid)
			read_count <= read_count + 1;
		else	
			read_count <= read_count;
	end
	//AXI
	assign axi_ren_o = (read_state == `STATE_READ_FREE) = `ReadDisable : `ReadEnable;
	assign axi_rready_o = axi_ren_o;//ready when starts reading
	assign axi_raddr_o = (read_state == `STATE_READ_DCACHE)? {data_araddr_i[31:5],write_count,2'b00}:
						(read_state == `STATE_READ_ICACHE)? {data_araddr_i[31:5],write_count,2'b00}:
						`ZeroWord;
	//ICache/DCache
	assign inst_rvalid_o = ( read_state == `STATE_READ_ICACHE && rdata_valid_i == `Valid && read_count == 3'h7 )?
							`Valid: `Invalid;//can add key word optimization later
	assign data_rvalid_o = ( read_state == `STATE_READ_DCACHE && rdata_valid_i == `Valid && read_count == 3'h7 )?
							`Valid: `Invalid;//can add key word optimization later
	always@(posedge clk)begin
		case(read_count)
			3'h0:	inst_rdata_o[32*1-1:32*0] <= rdata_i;
			3'h1:	inst_rdata_o[32*2-1:32*1] <= rdata_i;
			3'h2:	inst_rdata_o[32*3-1:32*2] <= rdata_i;
			3'h3:	inst_rdata_o[32*4-1:32*3] <= rdata_i;
			3'h4:	inst_rdata_o[32*5-1:32*4] <= rdata_i;
			3'h5:	inst_rdata_o[32*6-1:32*5] <= rdata_i;
			3'h6:	inst_rdata_o[32*7-1:32*6] <= rdata_i;
			3'h7:	inst_rdata_o[32*8-1:32*7] <= rdata_i;
			default:	inst_rdata_o <= inst_rdata_o;
		endcase
	end
	always@(posedge clk)begin
		case(read_count)
			3'h0:	data_rdata_o[32*1-1:32*0] <= rdata_i;
			3'h1:	data_rdata_o[32*2-1:32*1] <= rdata_i;
			3'h2:	data_rdata_o[32*3-1:32*2] <= rdata_i;
			3'h3:	data_rdata_o[32*4-1:32*3] <= rdata_i;
			3'h4:	data_rdata_o[32*5-1:32*4] <= rdata_i;
			3'h5:	data_rdata_o[32*6-1:32*5] <= rdata_i;
			3'h6:	data_rdata_o[32*7-1:32*6] <= rdata_i;
			3'h7:	data_rdata_o[32*8-1:32*7] <= rdata_i;
			default:	data_rdata_o <= data_rdata_o;
		endcase
	end
	
	
	//WRITE
	//state
	reg write_state;
	reg[2:0]write_count;
	always@(posedge clk）begin
		if(rst) 
			write_state <= `STATE_WRITE_FREE;
		else if( write_state == `STATE_WRITE_FREE && data_wen_i == `WriteEnable)//write 
			write_state <= `STATE_WRITE_BUSY;
		else if( write_state == `STATE_WRITE_BUSY && wdata_resp_i == `Valid && write_count == 3'h7 )//last write successful
			write_state <= `STATE_WRITE_FREE;
		else
			write_state <= write_state;
	end
	always@(posedge clk)begin
		if(write_state == `STATE_WRITE_FREE)
			write_count <= 3'h0;
		else if(write_state == `STATE_WRITE_BUSY && wdata_resp_i == `Valid)
			write_count <= write_count + 1;
		else	
			write_count <= write_count;
	end
	//AXI
	assign axi_wen_o = (write_state == `STATE_WRITE_BUSY) = `WriteEnable : `WriteDisable;
	assign axi_wlast_o = (write_count == 3'h7) `Valid:`Invalid;//write last word
	assign axi_waddr_o = {data_awaddr_i[31:5],write_count,2'b00};
	assign axi_wvalid_o = (write_state == `STATE_WRITE_BUSY ) `Valid: `Invalid;
	//DCache
	assign data_bvalid_o = ( write_state == `STATE_WRITE_BUSY && wdata_resp_i == `Valid && write_count == 3'h7 )?
							`Valid: `Invalid;
	always@(*)begin
		case(write_count)
			3'h0:	axi_wdata_o <= data_wdata_i[32*1-1:32*0];
			3'h1:	axi_wdata_o <= data_wdata_i[32*2-1:32*1];
			3'h2:	axi_wdata_o <= data_wdata_i[32*3-1:32*2];
			3'h3:	axi_wdata_o <= data_wdata_i[32*4-1:32*3];
			3'h4:	axi_wdata_o <= data_wdata_i[32*5-1:32*4];
			3'h5:	axi_wdata_o <= data_wdata_i[32*6-1:32*5];
			3'h6:	axi_wdata_o <= data_wdata_i[32*7-1:32*6];
			3'h7:	axi_wdata_o <= data_wdata_i[32*8-1:32*7];
			default:	axi_wdata_o <= `ZeroWord;
		endcase
	end
	
	
	
endmodule
