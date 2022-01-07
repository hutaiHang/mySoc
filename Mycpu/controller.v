`timescale 1ns / 1ps


module controller(
         input wire clk,rst,
         //译码
         input wire[5:0] opD,functD,
         input wire [31:0] instrD,
         input wire flushD,//刷新信号
         input wire stallD,//TODO D阶段阻塞信号，目前没处理
         input wire equalD,
         output wire pcsrcD,branchD,jumpD,
         output wire linkD,
         output wire jrD,
        output wire jwriteD,
         //执行
         input wire flushE,stallE,
         output wire memtoregE,alusrcE,
         output wire regdstE,regwriteE,
         output wire[7:0] aluopE,

         // 执行阶段有符号/无符号选择信号
         output wire sign_extdE,
         //访存
         input wire flushM,stallM,
         output wire memtoregM,memwriteM,regwriteM,write_hiloM,
         output wire memenM,
         //回写
         input wire flushW,stallW,
         output wire memtoregW,regwriteW,write_hiloW
       );

//译码
wire[7:0] aluopD;
wire memtoregD,memwriteD,alusrcD,regdstD,regwriteD;
wire memenD, memenE;
// 有符号/无符号选择信号
wire sign_extdD;
// 是否写HILO, 1代表写HILO, 0代表不写HILO
// wire[2:0] alucontrolD;

//执行
wire memwriteE;
//主译码器，产生控制信号
maindec md(
          // input
          opD,functD,
          instrD,
          stallD,
          // output
          // 新信号
          sign_extdD,
          memenD,
          write_hiloD,
          linkD,
          jrD,
          jwriteD,
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
parameter FLOP_WIDTH = 32;
flopenrc #(FLOP_WIDTH) regE(
         // input
         clk,
         rst,
         ~stallE,
         flushE,
         {memtoregD, memwriteD, alusrcD, regdstD, regwriteD, sign_extdD, write_hiloD,memenD, aluopD},

         // output
         {memtoregE, memwriteE, alusrcE, regdstE, regwriteE, sign_extdE, write_hiloE,memenE, aluopE}
       );

//执行-访存
flopenrc #(FLOP_WIDTH) regM(
        clk,rst,
        ~stallM,
        flushM,
        {memtoregE,memwriteE,regwriteE,memenE, write_hiloE},
        {memtoregM,memwriteM,regwriteM,memenM, write_hiloM}
      );
//访存-回写

flopenrc #(FLOP_WIDTH) regW(
        clk,rst,
        ~stallW,
        flushW,
        {memtoregM,regwriteM, write_hiloM},
        {memtoregW,regwriteW, write_hiloW}
      );
endmodule
