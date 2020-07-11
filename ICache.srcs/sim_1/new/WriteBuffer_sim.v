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
    reg [`WayBus]cpu_wdata_i=0;//һ����Ĵ�С
	//CPU read request and response
    reg cpu_rreq_i=0;
    reg [`DataAddrBus]cpu_araddr_i=0;
	 wire read_hit_o;
	 wire [`WayBus]cpu_rdata_o;
	
    //state
    wire [`FIFOStateBus]state_o;
	
    //MEM 
    reg mem_wready_i=0;
     wire mem_wvalid_o;
     wire[`WayBus] mem_wdata_;//һ����Ĵ�С
    reg mem_awready_i=0;
     wire mem_awvalid_o;
     wire [`DataAddrBus]mem_awaddr_o;
    reg mem_bvalid=0;
     wire mem_bready;
    WriteBuffer WB0(
        .clk(clk),
        .rst(rst),
        //CPU write request
        .cpu_wreq_i(cpu_wreq_i),
        .cpu_awaddr_i(cpu_awaddr_i),
        .cpu_wdata_i(cpu_wdata_i),//һ����Ĵ�С
        //CPU read request and response
        .cpu_rreq_i(cpu_rreq_i),
        .cpu_araddr_i(cpu_araddr_i),
        .read_hit_o(read_hit_o),
        .cpu_rdata_o(cpu_rdata_o),
        
        //state
        .state_o(state_o),
        
        //MEM 
        .mem_wready_i(mem_wready_i),
        .mem_wvalid_o(mem_wvalid_o),
        .mem_wdata_o(mem_wdata_o),//һ����Ĵ�С
        .mem_awready_i(mem_awready_i),
        .mem_awvalid_o(mem_awvalid_o),
        .mem_awaddr_o(mem_awaddr_o),
        .mem_bvalid(mem_bvalid),
        .mem_bready(mem_bready)
    );
    
    initial begin
        #500 rst =0;
        #20 cpu_wreq_i=0;
		
		#200 cpu_wreq_i=1;
		cpu_awaddr_i = 32'h24687_570;
		cpu_wdata_i = 256'h12345678_91023456_78910234_56789102_34567891_02345678_91023456_78910234;
		#20 cpu_wreq_i=0;
		wait(cpu_data_valid_o==`Valid && hit_o == `HitFail) begin
			#30
			if(dirty[{virtual_addr_i[`IndexBus],1'b0}] == `Dirty)
				$display("sucess:dirty write success");
			else    begin
				$display("FAIL!!!");
				$stop;
			end
		end
    end
endmodule