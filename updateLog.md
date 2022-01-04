1月4号凌晨修订记录：

数据通路部分：

1. 取消了aludec.v，将此代码的功能集成到来maindec.v中。controller.v中删除了aludec.v的相关代码。
2. 我们的aluop从原先的三位扩展到了八位，所以修改了三个阶段的锁存器参数，从原先的8位增加到了14位，并增加参数FLOP_WIDTH。
3. 在floprc增加sign_extdD和sign_extdE信号；
4. 在处理无符号扩展时，需要将原代码中的signext中有符号扩展部分新增加无符号扩展代码。
5. 此项修改需要调整数据通路结构：
   1. Controller 新增加1bit信号（sign_extd）来判断此指令是否需要有符号扩展（1表示有符号，0表示无符号）。sign_extd信号推向下一级锁存器；（对应代码中的变量是sign_extdE, sign_extdD）；
   2. signext 新增加一条无符号扩展输出，译码阶段同时输出有符号和无符号结果，两个结果都会推向下一级锁存器；
   3. 在执行阶段时，更具sign_extd选择上一阶段的锁存器选择有符号/无符号结果。

