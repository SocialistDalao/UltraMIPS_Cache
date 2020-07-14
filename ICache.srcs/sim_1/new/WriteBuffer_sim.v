`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/06 19:46:25
// Design Name: 
// Module Name: WriteBuffer_sim
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


module WriteBuffer_sim(

    );
    reg clk=0;
    always #10 clk=~clk;
    reg rst=1;
    //CPU write request
    reg cpu_wreq_i=0;
    reg [`DataAddrBus]cpu_awaddr_i=0;
    reg [`WayBus]cpu_wdata_i=0;//一个块的大小
	//CPU read request and response
    reg cpu_rreq_i=0;
    reg [`DataAddrBus]cpu_araddr_i=0;
	 wire read_hit_o;
	 wire [`WayBus]cpu_rdata_o;
	
    //state
    wire [`FIFOStateBus]state_o;
	
    //MEM 
	reg wen =0;
     wire[`WayBus] mem_wdata_;//一个块的大小
     wire [`DataAddrBus]mem_awaddr_o;
    reg mem_bvalid_i=0;
    WriteBuffer WB0(
        .clk(clk),
        .rst(rst),
        //CPU write request
        .cpu_wreq_i(cpu_wreq_i),
        .cpu_awaddr_i(cpu_awaddr_i),
        .cpu_wdata_i(cpu_wdata_i),//一个块的大小
        //CPU read request and response
        .cpu_rreq_i(cpu_rreq_i),
        .cpu_araddr_i(cpu_araddr_i),
        .read_hit_o(read_hit_o),
        .cpu_rdata_o(cpu_rdata_o),
        
        //state
        .state_o(state_o),
        
        //MEM 
		.wen(wen),
        .mem_wdata_o(mem_wdata_o),//一个块的大小
        .mem_awaddr_o(mem_awaddr_o),
        .mem_bvalid_i(mem_bvalid_i)
    );
    
    initial begin
        #500 rst =0;
        #20 cpu_wreq_i=0;
		
		
    end
endmodule
