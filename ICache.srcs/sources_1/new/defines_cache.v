//cacheÈ«¾Ö

//Num
`define StateNum 4
`define StateNumLog2 2
`define SetNum 128

//Bus
`define OffsetBus 4:0
`define IndexBus 11:5
`define TagVBus 21:0
`define StateBus `StateNumLog2-1:0
`define SetBus `SetNum-1:0

//State
`define STATE_LOOK_UP `StateNumLog2'h0
`define STATE_SCAN_CACHE `StateNumLog2'h1
`define STATE_HIT_FAIL `StateNumLog2'h2
`define STATE_WAIT_BUS `StateNumLog2'h3