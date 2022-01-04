### 1月4日 23:04 更新记录

错误：仿真时，寄存器堆读出的数据为未定型，这直接导致了后续指令的错误
解决：controller中添加了新的信号，但是control的长度没有更新

**controller部分**

1. 新增加信号write_hiloD表示是否写hilo

**maindec部分**

1. 新增加write_hilo信号
2. 添加 MTHI、MTLO、MFHI和MFLO的译码

**hazard部分**

1. 增加输入输出   input wire write_hiloM,  output wire forward_hilo_E,
2.   assign forward_hilo_E = write_hiloM;

**datapath部分**

1. 调用hilo_reg，并增加forword_hilo_mux来选择hilo_reg的输入信号（实现数据前推功能）

**hilo_reg部分**

1. 新建了hilo_reg.v文件
2. 此文件在datapath中被调用



### 1月4日 18:38 更新记录

将regfile.v修改回了实验4的版本

### 1月4日18:01更新记录：

**错误**

1. 仿真的结果，全部位移指令输出全为零
2. 仿真的SRA和SRAV两条指令高位补0（算数右移应该补1）

**ALU部分**

1. 将位移指令的SRA和SRAV修改为有符号扩展

**maindec.v部分**

1. 将位移指令移动到R-type下判断

结果：修订可以通过位移指令的仿真测试。



### 1月4日15：00更新记录：

**ALU部分**：新增了偏移量instr[10:6]作为输入offset，处理逻辑移位运算；

**数据通路部分**：增加了偏移量offsetD与offsetE;



### 1月4号凌晨更新记录：

**数据通路部分**

1. 取消了aludec.v，将此代码的功能集成到来maindec.v中。controller.v中删除了aludec.v的相关代码。
2. 我们的aluop从原先的三位扩展到了八位，所以修改了三个阶段的锁存器参数，从原先的8位增加到了14位，并增加参数FLOP_WIDTH。
3. 在floprc增加sign_extdD和sign_extdE信号；
4. 在处理无符号扩展时，需要将原代码中的signext中有符号扩展部分新增加无符号扩展代码。
5. 此项修改需要调整数据通路结构：
   1. Controller 新增加1bit信号（sign_extd）来判断此指令是否需要有符号扩展（1表示有符号，0表示无符号）。sign_extd信号推向下一级锁存器；（对应代码中的变量是sign_extdE, sign_extdD）；
   2. signext 新增加一条无符号扩展输出，译码阶段同时输出有符号和无符号结果，两个结果都会推向下一级锁存器；
   3. 在执行阶段时，更具sign_extd选择上一阶段的锁存器选择有符号/无符号结果。

