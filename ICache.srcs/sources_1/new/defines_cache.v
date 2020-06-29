//cacheÈ«¾Ö
//Sign
`define HitSuccess 1'b1
`define HitFail 1'b0
`define Enable 1'b1
`define Disable 1'b0
`define Ready 1'b1
`define NotReady 1'b0
`define Valid 1'b1
`define Invalid 1'b0

//Num
`define CacheSize 8*1024*8
`define BlockNum 8
`define SetAccNum 2
`define WaySize `BlockNum*32
`define WayBus `BlockNum*32-1:0
`define SetNum 128 //`CacheSize/`WaySize/`SetAccNum
`define SetSize `SetAccNum*`WaySize
`define StateNum 4
`define StateNumLog2 2

//Bus
`define OffsetBus 4:0
`define IndexBus 11:5
`define TagBus 31:12
`define TagVBus 20:0
`define StateBus `StateNumLog2-1:0
`define SetBus `SetNum-1:0

//State
`define STATE_LOOK_UP `StateNumLog2'h0
`define STATE_SCAN_CACHE `StateNumLog2'h1
`define STATE_HIT_FAIL `StateNumLog2'h2
`define STATE_WRITE_BACK `StateNumLog2'h3