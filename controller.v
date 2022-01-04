`timescale 1ns / 1ps


module controller(
         input wire clk,rst,
         //译码
         input wire[5:0] opD,functD,
         output wire pcsrcD,branchD,equalD,jumpD,

         //执行
         input wire flushE,
         output wire memtoregE,alusrcE,
         output wire regdstE,regwriteE,
         output wire[7:0] aluopE,

         // 执行阶段有符号/无符号选择信号
         output wire sign_extdE,
         //访存
         output wire memtoregM,memwriteM,regwriteM,
         //回写
         output wire memtoregW,regwriteW


       );

//译码
wire[7:0] aluopD;
wire memtoregD,memwriteD,alusrcD,regdstD,regwriteD;
// 有符号/无符号选择信号
wire sign_extdD;
// wire[2:0] alucontrolD;

//执行
wire memwriteE;
//主译码器，产生控制信号
maindec md(
          // input
          opD,functD,

          // output
          // 新信号
          sign_extdD,
          // 旧信号
          memtoregD,memwriteD,
          branchD,alusrcD,
          regdstD,regwriteD,
          jumpD,
          aluopD
        );
//ALU译码器，产生ALU控制信号
// aludec ad(functD,aluopD,alucontrolD);

assign pcsrcD = branchD & equalD;

//流水线D触发器，每一级用到的信号无需向下一级传递
//译码-执行
parameter FLOP_WIDTH = 14;
floprc #(FLOP_WIDTH) regE(
         // input
         clk,
         rst,
         flushE,
         {memtoregD, memwriteD, alusrcD, regdstD, regwriteD, sign_extdD, aluopD},

         // output
         {memtoregE, memwriteE, alusrcE, regdstE, regwriteE, sign_extdE, aluopE}
       );
//执行-访存
flopr #(FLOP_WIDTH) regM(
        clk,rst,
        {memtoregE,memwriteE,regwriteE},
        {memtoregM,memwriteM,regwriteM}
      );
//访存-回写
flopr #(FLOP_WIDTH) regW(
        clk,rst,
        {memtoregM,regwriteM},
        {memtoregW,regwriteW}
      );
endmodule
