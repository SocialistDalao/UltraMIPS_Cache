`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/25 16:03:16
// Design Name: 
// Module Name: TLB
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


module TLB(
    input wire rst,
    
    input wire [`RegBus]virtual_addr_i,
    output reg [`RegBus]physical_addr_o
    );
    

    always@(*)begin
        if(rst)
            physical_addr_o <= `ZeroWord;
        else
//            physical_addr_o <= virtual_addr_i+32'h21453_000;
            physical_addr_o <= virtual_addr_i;
    end

endmodule
