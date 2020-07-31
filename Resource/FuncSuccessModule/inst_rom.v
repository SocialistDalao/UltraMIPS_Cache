//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  inst_rom
// File:    inst_rom.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: Ö¸Áî´æ´¢Æ÷
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module inst_rom(

//	input clk,
	input ce,
	input[`InstAddrBus]    addr,
	output reg[`InstBus]   inst1,
	output reg[`InstBus]   inst2
);
/*
    reg[`InstBus] inst_mem[0:`InstMemNum-1];

    // initial $readmemh ("inst_rom.data", inst_mem);

    always @ (*) begin
        if (ce == `ChipDisable) begin
            inst1 = `ZeroWord;
            inst2 = `ZeroWord;
        end else begin
            inst1 = inst_mem[addr[`InstMemNumLog2+1:2]];
            inst2 = inst_mem[addr[`InstMemNumLog2+1:2]+1];
        end
    end
*/
endmodule