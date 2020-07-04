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
    reg [`DataAddrBus]virtual_addr_i=0;
    reg [`DataBus]cpu_wdata_i=0;
    
    wire hit_o;
    wire cpu_data_valid_o;
    wire [`DataBus] cpu_data_o;
    
    reg mem_rvalid_i=0;
    reg mem_arready_i=1;
    reg [`WayBus]mem_rdata_i;
    
    wire mem_ren_o;
    wire mem_rready_o;
    wire mem_arvalid_o;
    wire [`DataAddrBus]mem_araddr_o;
    
    wire [`DirtyBus] dirty;
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
        .cpu_data_valid_o(cpu_data_valid_o),          
        .cpu_data_o(cpu_data_o),     
        
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
        .dirty(dirty)
        );
        
        //normal test
        initial begin
            #500 rst =0;
        
            //normal read
            #505 cpu_rreq_i=1;
            virtual_addr_i = 32'h24687_570;
            #20 cpu_rreq_i=0;
            wait(mem_arvalid_o)begin
                 #140   mem_rvalid_i=1;
                 mem_rdata_i=256'h12345678_91023456_78910234_56789102_34567891_02345678_91023456_78910234;
                 wait(mem_rready_o==`Ready) #20 mem_rvalid_i=0;
             end
            wait(cpu_data_valid_o==`Valid && hit_o == `HitFail) begin
                if(cpu_data_o == 32'h56789102)
                    $display("sucess:not hit, send to way0");
                else    begin
                    $display("FAIL!!!");
                    $stop;
                end
            end
            
            
            #505 cpu_wreq_i=1;
            virtual_addr_i = 32'h24687_570;
            cpu_wdata_i = 32'h1111_1111;
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
            
            
            //write result test
            #500 cpu_rreq_i=1;
            virtual_addr_i = 32'h24687_570;
            #20 cpu_rreq_i=0;
            wait(cpu_data_valid_o==`Valid && hit_o == `HitSuccess) begin
                if(cpu_data_o == 32'h1111_1111)
                    $display("sucess:write success");
                else    begin
                    $display("FAIL!!!");
                    $stop;
                end
            end
            
            #500 $stop;
        end//initial
        
        
        
        
endmodule
