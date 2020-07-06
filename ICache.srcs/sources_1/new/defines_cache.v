//cacheÈ«¾Ö
//Sign
`define HitSuccess 1'b1
`define HitFail 1'b0
`define Enable 1'b1
`define Disable 1'b0
`define Ready 1'b1
`define NotReady 1'b0
`define Dirty 1'b1
`define NotDirty 1'b0
`define Valid 1'b1
`define Invalid 1'b0
`define ZeroWay `WaySize'h0

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
//Write Buffer
`define FIFOStateNum 3
`define FIFOStateNumLog2 2
`define FIFONum 8
`define FIFONumLog2 3

//Bus
`define OffsetBus 4:0
`define IndexBus 11:5
`define TagBus 31:12
`define TagVBus 20:0
`define StateBus `StateNumLog2-1:0
`define SetBus `SetNum-1:0
`define DirtyBus 2*`SetNum-1:0
`define DataAddrBus 31:0
`define DataBus 31:0
`define FIFOBus `FIFONum-1:0
`define FIFOPointBus `FIFONumLog2-1:0
//Write Buffer
`define FIFOStateBus `StateNumLog2-1:0

//State
//Cache
`define STATE_LOOK_UP `StateNumLog2'h0
`define STATE_SCAN_CACHE `StateNumLog2'h1
`define STATE_HIT_FAIL `StateNumLog2'h2
`define STATE_WRITE_BACK `StateNumLog2'h3
//Write Buffer
`define STATE_EMPTY `FIFOStateNumLog2'h0
`define STATE_WORKING `FIFOStateNumLog2'h0
`define STATE_FULL `FIFOStateNumLog2'h0