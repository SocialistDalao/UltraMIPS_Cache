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
    input wire[`InstAddrBus]mem_araddr_i,
	output wire inst_rvalid_o,
	output wire inst_arready_o,
	output wire [`WayBus]inst_rdata_o,//DCache: Read Channel
	
	//DCache: Read Channel
    input wire data_ren_i,
    input wire data_rready_i,
    input wire data_arvalid_i,
    input wire[`DataAddrBus]data_araddr_i,
    output wire data_rvalid_o,
    output wire data_arready_o,
    output wire [`WayBus]data_rdata_o,//一个块的大小
	
	//DCache: Write Channel
    input wire data_wready_i,
    input wire data_awready_i,
    input wire data_bvalid,
    output wire data_wvalid_o,
    output wire[`WayBus]data_wdata_o,//一个块的大小
    output wire data_awvalid_o,
    output wire [`DataAddrBus]data_awaddr_o,
    output wire data_bready,
	
	//AXI Communicate
	input wire[`RegBus]    rdata_i,        //返回到cache的读取数据
	input wire             rdata_valid_i,  //返回数据可获取
	input wire             wdata_resp_i,   //写响应,每个beat发一次，成功则可以传下一数据
	output wire             axi_ce_o,
	output wire             axi_wr_o,
	output wire[3:0]        axi_sel_o,
	output wire[`RegBus]    axi_addr_o,
	output wire[`RegBus]    axi_wdata_o,    //cache最好保证在每个时钟沿更新要写的内容
	output wire             axi_rready_o,   //cache端准备好读
	output wire             axi_wvalid_o,   //cache端准备好写的数据，最好是持续
	output wire             axi_wlast_o    //cache写最后一个数据
    );
endmodule
