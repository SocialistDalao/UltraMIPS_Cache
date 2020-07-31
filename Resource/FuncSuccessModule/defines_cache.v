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
`define Success 1'b1
`define Fail 1'b0
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
//ICache
`define STATE_LOOK_UP `StateNumLog2'h0
`define STATE_SCAN_CACHE `StateNumLog2'h1
`define STATE_HIT_FAIL `StateNumLog2'h2
`define STATE_WRITE_BACK `StateNumLog2'h3
//DCache
`define STATE_LOOK_UP `StateNumLog2'h0
`define STATE_FETCH_DATA `StateNumLog2'h1
`define STATE_WRITE_DATA `StateNumLog2'h2
//Write Buffer
`define STATE_EMPTY `FIFOStateNumLog2'h0
`define STATE_WORKING `FIFOStateNumLog2'h1
`define STATE_FULL `FIFOStateNumLog2'h3//ATTENTION: It's 3
//CacheAXI_Interface
`define STATE_WRITE_FREE 1'b0
`define STATE_WRITE_BUSY 1'b1
`define STATE_READ_FREE 2'h0
`define STATE_READ_ICACHE 2'h1
`define STATE_READ_DCACHE 2'h2

///////////////////////////////////////////////////////////////////////////////
//AXI
`define AXRESP_OKAY   2'b00
`define AXRESP_EXOKAY 2'b01
`define AXRESP_SLVERR 2'b10
`define AXRESP_DECERR 2'b11

`define AXLOCK_NORMAL     2'b00
`define AXLOCK_EXCLUSIVE  2'b01
`define AXLOCK_LOCKED     2'b10

`define AXBURST_FIXED  2'b00
`define AXBURST_INCR   2'b01
`define AXBURST_WRAP   2'b10

`define AXSIZE_FOUR_BYTE        3'b010

`define AXCACHE_REG_BUFFER      2'b00
`define AXCACHE_REG_CACHE       2'b01
`define AXCACHE_REG_READ_ALCT   2'b10
`define AXCACHE_REG_WRITE_ALCT  2'b11

`define AXPROT_REG_NORM_OR_PRI  2'b00
`define AXPROT_REG_SEC_OR_NSEC  2'b10
`define AXPROT_REG_INST_OR_DATA 2'b01
//burst
`define AXSIZE   2:0
`define AXLEN    3:0
`define AXBURST  1:0

//×´Ì¬»ú
`define AXI_IDLE 4'b00
`define ARVALID  4'b01
`define AWVALID  4'b10
`define BREADY   4'b11
