`timescale 1ns / 1ps
`include "defines.vh"

module maindec(
         // input
         input wire[5:0] op,
         input wire [5:0] funct,

         // output
         // 新信号
         output wire sign_extd,
         // 旧信号
         output wire memtoreg,memwrite,
         output wire branch,alusrc,
         output wire regdst,regwrite,
         output wire jump,
         output wire[7:0] aluop
       );
reg[15:0] controls;
assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,sign_extd,aluop} = controls;
always @(*)
  begin
    case (op)
      6'b000000://指令前6位，R-type再需要根据低6位缺点aluop
        case (funct)
          `EXE_ADD:
            controls <= {8'b1100_0000,`EXE_ADD_OP};//ADD
          `EXE_SUB:
            controls <= {8'b1100_0000,`EXE_SUB_OP};//SUB
          `EXE_AND:
            controls <= {8'b1100_0000,`EXE_AND_OP};//AND
          `EXE_OR:
            controls <= {8'b1100_0000,`EXE_OR_OP};//OR
          `EXE_SLT:
            controls <= {8'b1100_0000,`EXE_SLT_OP};//SLT
          `EXE_NOR:
            controls <= {8'b1100_0000,`EXE_NOR_OP};//NOR
          `EXE_XOR:
            controls <= {8'b1100_0000,`EXE_XOR_OP};//XOR
            //-----------移位运算
            //   regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,sign_extd,aluop
          `EXE_SLL:
            controls <= {8'b1100_0000,`EXE_SLL_OP};//SLL
          `EXE_SRL:
              controls <= {8'b1100_0000,`EXE_SRL_OP};//SRL
          `EXE_SRA:
            controls <={8'b1100_0000,`EXE_SRA_OP};//SRA 算数右移
          `EXE_SLLV:
            controls <={8'b1100_0000,`EXE_SLLV_OP};//SLLV
          `EXE_SRLV:
            controls <={8'b1100_0000,`EXE_SRLV_OP};//SRLV
          `EXE_SRAV:
            controls <={8'b1100_0000,`EXE_SRAV_OP};//SRAV
          default:
            controls <= {8'b1100_0000,8'b0000_0000}; //{}运算符语法未知
        endcase
      // 实验4指令
      `EXE_LW:
        controls <= {8'b1010_0101,`EXE_LW_OP};//LW
      `EXE_SW:
        controls <= {8'b0010_1001,`EXE_SW_OP};//SW
      `EXE_BEQ:
        controls <= {8'b0001_0001,`EXE_BEQ_OP};//BEQ
      `EXE_ADDI:
        controls <= {8'b1010_0001,`EXE_ADDI_OP};//ADDI
      `EXE_J:
        controls <= {8'b0000_0011,`EXE_J_OP};//J
      // 52条新指令
	  //-----------逻辑运算
      `EXE_ANDI:
        controls <= {8'b1010_0000,`EXE_ANDI_OP};//ANDI
      `EXE_LUI:
        controls <= {8'b1010_0000,`EXE_LUI_OP};//LUI,将 16 位立即数 imm 写入寄存器 rt 的高 16 位，寄存器 rt 的低 16 位置 0
      `EXE_ORI:
        controls <= {8'b1010_0000,`EXE_ORI_OP};//ORI
      `EXE_XORI:
        controls <= {8'b1010_0000,`EXE_XORI_OP};//XORI

      default:
        controls <= {8'b00000000,8'b0000_0000};//illegal op
    endcase
  end
endmodule
  // ANDI各信号取值,立即数指令各信号与之相同
  // regwrite, 1
  // regdst, 	0
  // alusrc,	1
  // branch,	0
  // memwrite,	0
  // memtoreg,	0
  // jump	0
  // sign_extd 1
  //--------------------------------------------------------------------------------
  // controls <= 9'b110000010;//R-TYRE
  // 6'b100011:controls <= 9'b101001000;//LW
  // 6'b101011:controls <= 9'b001010000;//SW
  // 6'b000100:controls <= 9'b000100001;//BEQ
  // 6'b001000:controls <= 9'b101000000;//ADDI

  // 6'b000010:controls <= 9'b000000100;//J
  // default:  controls <= 9'b000000000;//illegal op
  //--------------------------------------------------------------------------------
