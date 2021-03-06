`timescale 1ns / 1ps
`include "defines.vh"

module maindec(
         // input
         input wire[5:0] op,
         input wire [5:0] funct,
         input wire[31:0] instrD,
         input wire stallD,
         // output
         // 新信号
         output wire sign_extd,
         output wire memenD,
         // HILO 控制信号
         output wire write_hilo, // 是否要写 HILO, 1代表写HILO, 0代表不写HILO
         output wire linkD,//需要写入31号寄存器
         output wire jrD,//需要跳转到指定寄存器
         output wire jwriteD,// 写的是pc+8还是aluout
         // 旧信号
         output wire memtoreg,memwrite,
         output wire branch,alusrc,
         output wire regdst,regwrite,
         output wire jump,
         output wire[7:0] aluop
       );
reg[16:0] controls;

	assign memenD =( (op == `EXE_LB)||(op == `EXE_LBU)||(op == `EXE_LH)||
                (op == `EXE_LHU)||(op == `EXE_LW)||(op == `EXE_SB)||(op == `EXE_SH)||(op == `EXE_SW)) && ~stallD;

assign jwriteD = ( op == `EXE_JAL ) | 
              ( (op==6'b000000) & ( (funct==`EXE_JALR) | (funct ==`EXE_JR) ) ) | 
              ( (op==6'b000001) & ( (instrD[20:16]==`EXE_BGEZAL) | (instrD[20:16] ==`EXE_BLTZAL) ) );

assign linkD = ( ( (op==6'b000001) & ( (instrD[20:16] == `EXE_BGEZAL) | (instrD[20:16] == `EXE_BLTZAL) ) ) |
                 ( op == `EXE_JAL ) |
                 ( (op==6'b000000) & (funct == `EXE_JALR) & (instrD[15:11] == 5'b00000) )
                );
assign jrD = (
              (op==6'b000000)&
              ( (funct==`EXE_JALR) | (funct==`EXE_JR) )
             );
assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,sign_extd,write_hilo,aluop} = controls;
always @(*)
  begin
    case (op)
      6'b000000://指令前6位，R-type再需要根据低6位缺点aluop
        case (funct)
          //----------------寄存器算数运算---------------
          `EXE_ADD:
            controls <= {8'b1100_0000,1'b0,`EXE_ADD_OP};//ADD
          `EXE_SUB:
            controls <= {8'b1100_0000,1'b0,`EXE_SUB_OP};//SUB
          `EXE_SLT:
            controls <= {8'b1100_0000,1'b0,`EXE_SLT_OP};//SLT
          `EXE_SLTU:
            controls<={8'b1100_0000,1'b0,`EXE_SLTU_OP};//SLTU
          `EXE_ADDU:
            controls <= {8'b1100_0000,1'b0,`EXE_ADDU_OP};//ADDU
          `EXE_SUBU:
            controls <= {8'b1100_0000,1'b0,`EXE_SUBU_OP};//SUBU
          `EXE_MULT:
            controls <= {8'b0000_0000,1'b1,`EXE_MULT_OP};//MULT
          `EXE_MULTU:
            controls <= {8'b0000_0000,1'b1,`EXE_MULTU_OP};//MULTU
          `EXE_DIV:
            controls <= {8'b0000_0000,1'b1,`EXE_DIV_OP}; //DIV
          `EXE_DIVU:
            controls <= {8'b0000_0000,1'b1,`EXE_DIVU_OP}; //DIVU
          //-----------------寄存器逻辑运算--------------------
          `EXE_AND:
            controls <= {8'b1100_0000,1'b0,`EXE_AND_OP};//AND
          `EXE_OR:
            controls <= {8'b1100_0000,1'b0,`EXE_OR_OP};//OR
          `EXE_NOR:
            controls <= {8'b1100_0000,1'b0,`EXE_NOR_OP};//NOR
          `EXE_XOR:
            controls <= {8'b1100_0000,1'b0,`EXE_XOR_OP};//XOR
          //-----------移位运算----------------
          //   regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,sign_extd,aluop
          `EXE_SLL:
            controls <= {8'b1100_0000,1'b0,`EXE_SLL_OP};//SLL
          `EXE_SRL:
            controls <= {8'b1100_0000,1'b0,`EXE_SRL_OP};//SRL
          `EXE_SRA:
            controls <={8'b1100_0000,1'b0,`EXE_SRA_OP};//SRA 算数右移
          `EXE_SLLV:
            controls <={8'b1100_0000,1'b0,`EXE_SLLV_OP};//SLLV
          `EXE_SRLV:
            controls <={8'b1100_0000,1'b0,`EXE_SRLV_OP};//SRLV
          `EXE_SRAV:
            controls <={8'b1100_0000,1'b0,`EXE_SRAV_OP};//SRAV
          // --------数据移动指令------------
          `EXE_MTHI:
            controls <= {8'b0000_0000,1'b1,`EXE_MTHI_OP};//MTHI
          `EXE_MTLO:
            controls <= {8'b0000_0000,1'b1,`EXE_MTLO_OP};//MTLO
          `EXE_MFHI:
            controls <= {8'b1100_0000,1'b0,`EXE_MFHI_OP};//MFHI
          `EXE_MFLO:
            controls <= {8'b1100_0000,1'b0,`EXE_MFLO_OP};//MFLO
          //------------跳转指令--------------
          `EXE_JR:
            controls<= {8'b0000_0011,1'b0,`EXE_JR_OP};//JR
      // {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,sign_extd,write_hilo,aluop}
          `EXE_JALR:
            controls<= {8'b1100_0011,1'b0,`EXE_JALR_OP};//JALR
          default:
            controls <= {8'b1100_0000,1'b0,8'b0000_0000}; //
        endcase
      6'b000001:
        case (instrD[20:16])
          `EXE_BLTZ:
            controls <= {8'b0001_0001,1'b0,`EXE_BLTZ_OP};//BLTZ
          `EXE_BLTZAL:
            controls <= {8'b1001_0001,1'b0,`EXE_BLTZAL_OP};//BLTZAL
          `EXE_BGEZ:
            controls <= {8'b0001_0001,1'b0,`EXE_BGEZ_OP};//BGEZ
          `EXE_BGEZAL:
            controls <= {8'b1001_0001,1'b0,`EXE_BGEZAL_OP};//BGEZAL
          default:
            controls <= {8'b0000_0000,1'b0,8'b0000_0000};//非法指令
          endcase
      // 52条新指令
      //-----------立即数逻辑运算--------------
      `EXE_ANDI:
        controls <= {8'b1010_0000,1'b0,`EXE_ANDI_OP};//ANDI
      `EXE_LUI:
        controls <= {8'b1010_0000,1'b0,`EXE_LUI_OP};//LUI,将 16 位立即数 imm 写入寄存器 rt 的高 16 位，寄存器 rt 的低 16 位置 0
      `EXE_ORI:
        controls <= {8'b1010_0000,1'b0,`EXE_ORI_OP};//ORI
      `EXE_XORI:
        controls <= {8'b1010_0000,1'b0,`EXE_XORI_OP};//XORI
      //立即数算数运算
      `EXE_ADDI:
        controls <= {8'b1010_0001,1'b0,`EXE_ADDI_OP};//ADDI
      `EXE_ADDIU:
        controls <= {8'b1010_0001,1'b0,`EXE_ADDI_OP};//ADDIU
      `EXE_SLTI:
        controls<= {8'b1010_0001,1'b0,`EXE_SLTI_OP};//SLTI
      `EXE_SLTIU:
        controls<= {8'b1010_0001,1'b0,`EXE_SLTIU_OP};//SLTIU
      //存取指令
      `EXE_LW:
        controls <= {8'b1010_0101,1'b0,`EXE_LW_OP};//LW
      `EXE_SW:
        controls <= {8'b0010_1001,1'b0,`EXE_SW_OP};//SW
      `EXE_LB:
        controls<={8'b1010_0101,1'b0,`EXE_LB_OP};//LB
      `EXE_LBU:
        controls<={8'b1010_0101,1'b0,`EXE_LBU_OP};//LBU
      `EXE_LH:
        controls<={8'b1010_0101,1'b0,`EXE_LH_OP};//LH
      `EXE_LHU:
        controls<={8'b1010_0101,1'b0,`EXE_LHU_OP};//LHU
      `EXE_SB:
        controls<={8'b0010_1001,1'b0,`EXE_SB_OP};//SB
      `EXE_SH:
        controls<={8'b0010_1001,1'b0,`EXE_SH_OP};//SH
      // ----------- 分支跳转指令 ---------
      //   regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,sign_extd,aluop
      `EXE_BEQ:
        controls <= {8'b0001_0001,1'b0,`EXE_BEQ_OP};//BEQ
      `EXE_BNE:
        controls <= {8'b0001_0001,1'b0,`EXE_BNE_OP};//BNE
      `EXE_BLEZ:
        controls <= {8'b0001_0001,1'b0,`EXE_BLEZ_OP};//BLEZ
      `EXE_BGTZ:
        controls <= {8'b0001_0001,1'b0,`EXE_BGTZ_OP};//BGTZ
      //  regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,sign_extd,aluop
      // J target	无条件直接跳转
      // JAL target	无条件直接跳转至子程序并保存返回地址
      // JR rs	无条件寄存器跳转
      // JALR rd, rs	无条件寄存器跳转至子程序并保存返回地址
      `EXE_J:
        controls <= {8'b0000_0011,1'b0,`EXE_J_OP};//J
      `EXE_JAL:
        controls<={8'b1000_0011,1'b0,`EXE_JAL_OP};//JAL
      // `EXE_JR:
      //   controls <= {8'b0011_0000,1'b0,`EXE_JR_OP}; // JR
      // `EXE_JALR:
      //   controls <= {8'b1111_0000,1'b0,`EXE_JALR}; // JALR
      default:
        controls <= {8'b00000000,1'b0,8'b0000_0000};//illegal op
    endcase
    ////////////////////////////////////////
		//bug
		//只能在不stall的时候出结果，否则trace无法判断。
    if(stallD)begin
			controls[6]<=0;
			controls[4]<=0;
			controls[1]<=0;
		end
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
  // sign_extd 0
  //--------------------------------------------------------------------------------
  // controls <= 9'b110000010;//R-TYRE
  // 6'b100011:controls <= 9'b101001000;//LW
  // 6'b101011:controls <= 9'b001010000;//SW
  // 6'b000100:controls <= 9'b000100001;//BEQ
  // 6'b001000:controls <= 9'b101000000;//ADDI

  // 6'b000010:controls <= 9'b000000100;//J
  // default:  controls <= 9'b000000000;//illegal op
  //--------------------------------------------------------------------------------
