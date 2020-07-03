`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/03 20:57:03
// Design Name: 
// Module Name: DCache_sim_dirty
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


module DCache_sim_dirty(

    );
    reg clk=0;     
    always #10 clk=~clk;
    
    reg rst=1;
    reg cpu_rreq_i=0;
    reg cpu_wreq_i=0;
    reg [`RegBus]virtual_addr_i=0;
    reg [`RegBus]cpu_wdata_i=0;
    
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
    
//    reg LRU_pick=1;
    DCache dcache1(
        .clk(clk),                       
        .rst(rst), 
        
        //read inst request           
        .cpu_rreq_i(cpu_rreq_i),                 
        .cpu_wreq_i(cpu_wreq_i),                 
        .virtual_addr_i(virtual_addr_i),  
        .cpu_wdata_i(cpu_wdata_i),  
        
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
        .mem_araddr_o(mem_araddr_o)
        
        //test
//        .LRU_pick(LRU_pick)
        );
endmodule
