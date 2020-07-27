`timescale 1ns / 1ps
`include"defines.v"
`include"defines_cache.v"
module InstBuffer(
    input clk,
    input rst,
	input flush,
    //Issue
    input wire 				single_issue_i,//whether issue stage has issued one inst
    input wire 				issue_i,// Whether issue stage has issued inst
    output wire [`InstBus]	issue_inst1_o,
    output wire [`InstBus]	issue_inst2_o,
    output wire 			issue_inst1_valid_o,
    output wire 			issue_inst2_valid_o,
	//Fetch inst
    input wire [`InstBus]	ICache_inst1_i,
    input wire [`InstBus]	ICache_inst2_i,
    input wire 				ICache_inst1_valid_o,
    input wire 				ICache_inst2_valid_o,
	output wire 			buffer_full_i,
	
    );
	//队列本体
    reg [`InstBus]FIFO_data[`InstBufferSize-1:0];
	
    //头尾指针维护
    reg [`InstBufferSizeLog2-1:0]tail;//表征当前正在写入的数据位置
    reg [`InstBufferSizeLog2-1:0]head;//表征最后需要写入数据位置的后一位
    reg [`InstBufferSize-1:0]FIFO_valid;//表征buffer中的数据是否有效（高电平有效）
    always@(posedge clk)begin
        if(rst|flush)begin
            head <= `InstBufferSizeLog2'h0;
            tail <= `InstBufferSizeLog2'h0;
			FIFO_valid <= `InstBufferSize'h0;
        end
		//pop
        if( issue_i == `Valid && single_issue_i == `Valid)begin//Issue one inst
			FIFO_valid[head] <= `Invalid;
            head <= head + 1;
		end
        else if( issue_i == `Valid && single_issue_i == `Invalid)begin//Issue two inst
			FIFO_valid[head] <= `Invalid;
			FIFO_valid[head+`InstBufferSizeLog2'h1] <= `Invalid;
            head <= head + 2;
		end
		
		//push
        if( ICache_inst1_valid_o == `Valid && ICache_inst2_valid_o == `Invalid)begin//Issue one inst
			FIFO_valid[tail] <= `Valid;
            tail <= tail + 1;
		end
        else if( ICache_inst1_valid_o == `Valid && ICache_inst2_valid_o == `Valid)begin//Issue two inst
			FIFO_valid[tail] <= `Valid;
			FIFO_valid[tail+`InstBufferSizeLog2'h1] <= `Valid;
            tail <= tail + 2;
		end
    end
	
	
	//Write
    always@(posedge clk)begin
		FIFO_data[tail] <= ICache_inst1_i;
		FIFO_data[tail+`InstBufferSizeLog2'h1] <= ICache_inst2_i;
    end
	   
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////Output//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
	assign issue_inst1_o = FIFO_data[head];
	assign issue_inst2_o = FIFO_data[head+`InstBufferSizeLog2'h1];
	assign issue_inst1_valid_o = FIFO_valid[head];
	assign issue_inst1_valid_o = FIFO_valid[head+`InstBufferSizeLog2'h1];
    //full
	assign buffer_full_i = FIFO_valid[tail+`InstBufferSizeLog2'h1];
endmodule
