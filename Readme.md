## UltraMIPS Cache项目说明

The introduction has not been translated to English, and currently we have no plan to do so.

### 作者/Author

李程浩/LoanCold

loancold@qq.com

负责UltraMIPS的Cache开发

### 来源

该项目隶属于

This project belongs to 

[UltraMIPS_NSCSCC]: https://github.com/SocialistDalao/UltraMIPS_NSCSCC

工程，是其中的Cache开发分支。

该分支包含有完整的开发过程（commits），由于初期的操作失误，该分支是一个完整的vivado工程文件，较为庞大，但是可以直接运行。同时，由于开始构建的时候只是为了开发ICache，vivado工程项目的命名都是以ICache来命名，但是实际上这是完整的Cache以及衍生品的开发工程，不只含有ICache。

代码文件UltraMIPS_Cache/ICache.srcs/sources_1/new/
仿真文件UltraMIPS_Cache/ICache.srcs/sim_1/new/

其中仿真文件仅仅是临时用品，并不满足工程上所定义的测试文件应有的标准，在这里也鼓励大家用更为严格、全面、标准的方式编写测试。

#### 意义

当前Cache的开发最大的问题是需要一个领头人，初期的开发会因为入门困难而毫无头绪，该项目致力于从教学和开发的中间寻找一个平衡，以一个相对友好的方式来介绍Cache的开发，也以代码层面（commits为时间线）来具体的指导开发的过程。

#### 未来

当前正处于该项目的末尾维护期，我们不会再添加功能性的新代码，当前的工作是维护该项目的可读性，并对此加以解释和引导。未来我们期望加入开发流程的具体介绍，以及代码的架构解析。