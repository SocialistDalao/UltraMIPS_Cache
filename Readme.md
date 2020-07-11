# Cache开发说明

当前目录下为半成品的ICache与DCache。

ICache与DCache的输入输出接口均为半成品，能够支持完成一定的功能，但是不能够进行完整的接口配置。ICache其内部功能已经初步仿真正确，可综合验证。DCache的功能没有仿真验证，但是目前可综合。

由于本人英文水平差，又硬凑，代码里面中英注释夹杂，实属抱歉。

这tm？太夸张了吧，我DCache还没仿真就发现一堆逻辑错误，真就人体debug机器吗？还有一堆命名遗留错误，等跑通了再改吧！奥里给！

发现现在的信号简直是叫一个混乱，各种if，if中间好多判断，估计综合出来的组合延迟肯定会非常大，但是先这样吧，到时候改成流水线之后再进行相应的调整。到时候综合看看先啦，阿sir。

我发现如果同时出现两条访存指令，我就鸭屎了，但是这种不应该出现的阻塞可以通过流水来完成，所以将功能完成之后应该将这方面的修改放到第一优先级。

#### 流水线思考

DCache的一部分遗留问题如下：首先是结构和状态机不能够与流水线进行对接，同时整个流水线的结构显得扑朔迷离，不仅如此，当前的代码和数据通路的构造显得不够清晰和合理，状态机的设计也存在着相当的不合理性。关于将bank的各部分的写使能分开，不要一起写，这个等整个的功能一步一步开发之后再进行重构和关键路径的优化。还有就是假如是两级的流水线，那么如果读和（脏数据）写冲突了，那么就应该是写优先。写数据会比读数据慢一拍，这样的话就刚好碰在一起，就不用读RAM了，只执行写操作，对于读操作直接拿写的数据就好了（好有道理，这不就解决了写相关）。

对于信号func，之后切成流水的时候要注意到流水线中的无效情况，也是就是不是二选一的关系，还需要加入无效。则之后换成write_valid和read_valid信号。

cache这边基本确定，取指和访存最好是三级而非两级，也就是cpu至少是7级流水。

#### 状态机非流水思考

现在的状态机基本符合预期，但是在Look Up和Write Data两个状态没有太多的操作，很多操作都在fetch data中，其中写ram的操作也在这里完成，因此可以考虑之后从中分配一部分操作出去。现在x

稍后将ram变成simple-dual模式。

在Write Buffer中出现一个非常诡异的现象，就是当写命中正在写入的块的时候，不能够算写命中啊喂！这个导致hit在读写情况下是不同的，所以要格外注意。

#### 结构设计文档

对于cache的结构和设计的思想的文档都在Cache_Design.md中，但是里面目前的不仅不全面而且有部分未更新，并且排版偏向混乱，至于具体的结构设计文档，包括硬件框图，都会在单发射性能测试成功后或者是双发射性能测试成功之后进行补充。为了方便团队内部和之后学校内部的传承，这都是必须要做的事情。

至于开源版本，可能会有一定设计上的精简，考虑到整个比赛的良性循环以及学习精神，开源版本应该附加的Cache Design更加注重原理上而非细节上的设计，这两个版本将为校内同学的学习提供Cache设计的参考。

#### 紧接着要做的事情

- FIFO的仿真
- FIFO输入的信号命名不应该是cpu而是cache
- FIFO的写入与cpu的写入不同步，需要先判定是否需要写入FIFO（即写命中的判断）
- FIFO写逻辑有问题，首先要读不命中，才会写进去，那么写的块不可能会出现在FIFO中。写不命中的时候转换为从总线中读数据，然后写。
- FIFO满的时候，若此时要写入就要使得Cache停止工作

#### 剩余待实现的功能

- 流水切割（初具成果的cache）
- Cache指令
- 硬件初始化（决赛的基本要求）
- 指令预取
- 双发射（最终成品的cache的基础版）
- 开发文档和结构设计的撰写
- 这之后就是各种提升性能的关键所在了


