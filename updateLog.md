### 1月6日 10:14 更新记录

**错误修订**：SB和SH无法正确将数据写进存储器的bug

**修改方法**：将写入的数据扩展复制到字的每一个部分



### 1月6日 2:09 更新记录

主要将branch和jump位置从D阶段跳转改为M阶段跳转

**datapath部分**

1. 将原先D阶段的选择器和比较器注释掉
2. 在alu中增加zero的计算
3. 在datapath中新增zero和overflow控制信号
4. 新增pcjumpD = {pcplus4D[31:28], instrD[25:0], 2'b00};
5. 新增pcsrcM = branchM & zeroM;
6. 将branch、jump、pcbranch、pcjump、pcplus4、zero和overflow推至M阶段

**hazard部分**

1. 新增了控制信号jump_branchM = jumpM | pcsrcM;
2. 取代了之前的stall和flush信号的判断条件



### 1月5日 21:00 更新记录

**错误：**LHU指令无法正确计算相应的地址

**修订：**地址应该乘4再去访问存储器，alu少打了LHU字符

添加了访存指令

**datapath部分**

1. 新增了输出部分，将四位字节写使能信号作为输出，并添加每一阶段的锁存器保存此结果。字节写使能信号由解码出的alucontrol字段进行赋值。
2. 将存储器中读出的值进行处理，单独提取出相关的有符号/无符号的字节、半字

**Hazard部分**

1. 添加相关的流水线暂停部分（WAR冒险）

**MIPS部分**

1. 将四位字节写使能信号作为输出

**mycpu_top部分**

1. 将四位字节写使能信号作为输出

**top部分**

1. 将四位字节写使能信号输入到data存储器中，替换掉原来的4位全1

**maindec和alu部分**

1. 添加了LB、LBU、LH、LHU、SH和SB指令相关处理代码



### 1月5日 13:03 更新记录

完成了除法器不能正常停止流水线的错误

将hazard中的stall信号补全，在datapath中修订相关的stall信号连线。因为在stall状态下，流水线会将暂停的流水级锁存器内容进行情况，故在datapath中建立一个reg变量存储stall后的相关值。在流水下重新启动时读取相对应的数据。



### 1月5日 2:55 更新记录

**错误**：除法无法正常停止流水线

**新增模块 div.v**

更新了defines.vh文件，在其中包含除法器相关的宏定义

**alu部分**

1. 新增加clk, rst, div_stall 信号
2. 导入除法器模块
3. 新增了一个always模块，在其中更新除法器相关控制信号

**Datapath部分**

1. 将alu和冒险部分的控制信号更新
2. 将执行阶段的D除法器全部更新为flopenrc





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

