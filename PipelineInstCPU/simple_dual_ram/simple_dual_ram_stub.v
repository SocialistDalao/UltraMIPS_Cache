// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Tue Jul 28 10:18:46 2020
// Host        : DESKTOP-KQ0TA7J running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/LENOVO/Desktop/perf_test_v0.02/perf_test_v0.01/soc_axi_perf/rtl/myCPU/simple_dual_ram/simple_dual_ram_stub.v
// Design      : simple_dual_ram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module simple_dual_ram(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[3:0],addra[6:0],dina[31:0],clkb,enb,addrb[6:0],doutb[31:0]" */;
  input clka;
  input ena;
  input [3:0]wea;
  input [6:0]addra;
  input [31:0]dina;
  input clkb;
  input enb;
  input [6:0]addrb;
  output [31:0]doutb;
endmodule
