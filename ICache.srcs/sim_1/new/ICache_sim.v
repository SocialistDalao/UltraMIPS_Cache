`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/28 19:57:16
// Design Name: 
// Module Name: ICache_sim
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


module ICache_sim(

    );
    reg clk=0;
    reg rst=1;
    reg cpu_req_i=0;
    reg [`RegBus]virtual_addr_i=0;
    
    wire hit_o;
    wire cpu_inst_valid_o;
    wire [`InstBus] cpu_inst_o;
    
    reg mem_rvalid_i=0;
    reg mem_arready_i=1;
    reg [`WayBus]mem_rdata_i;
    
    wire mem_ren_o;
    wire mem_rready_o;
    wire mem_arvalid_o;
    wire [`InstAddrBus]mem_araddr_o;
    
    reg LRU_pick=1;
    ICache icache1(
        .clk(clk),                       
        .rst(rst), 
        
        //read inst request           
        .cpu_req_i(cpu_req_i),                 
        .virtual_addr_i(virtual_addr_i),  
        
        //read inst result                 
        .hit_o(hit_o),                    
        .cpu_inst_valid_o(cpu_inst_valid_o),          
        .cpu_inst_o(cpu_inst_o),     
        
        //from_mem read result            
        .mem_rvalid_i(mem_rvalid_i),              
        .mem_arready_i(mem_arready_i),             
        .mem_rdata_i(mem_rdata_i),
        
        //to_mem ready to recieve request 
        .mem_ren_o(mem_ren_o),                
        .mem_rready_o(mem_rready_o),             
        .mem_arvalid_o(mem_arvalid_o),            
        .mem_araddr_o(mem_araddr_o),
        
        //test
        .LRU_pick(LRU_pick)
        );
        
    always #10 clk=~clk;
    initial begin
        #500 rst =0;
        #100 cpu_req_i=1;
        virtual_addr_i = 32'h24687534;
        #20 cpu_req_i=0;
        wait(mem_arvalid_o)
         #140   mem_rvalid_i=1;
         mem_rdata_i=256'h12345678_91023456_78910234_56789102_34567891_02345678_91023456_78910234;
         #20 mem_rvalid_i=0;
        wait(cpu_inst_valid_o==`Valid)
        $display("sucess:not hit, send read request to AXI");
        
        
        #100    cpu_req_i=1;
        virtual_addr_i = 32'h24687534;
        #20 cpu_req_i=0;
        wait(hit_o==`HitSuccess)
        $display("sucess:hit, directly send data to CPU");;
        $stop;
    end
endmodule
