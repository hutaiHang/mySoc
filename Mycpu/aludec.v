`timescale 1ns / 1ps


module aludec(
         input wire[5:0] funct,
         input wire[1:0] aluop,
         output reg[2:0] alucontrol
       );
always @(*)
  begin
    case (aluop)
      2'b00:
        alucontrol <= 3'b010;//add (for lw/sw/addi)
      2'b01:
        alucontrol <= 3'b110;//sub (for beq)
      default :
        case (funct)
          6'b100000:
            alucontrol <= 3'b010; //add
          6'b100010:
            alucontrol <= 3'b110; //sub
          6'b100100:
            alucontrol <= 3'b000; //and
          6'b100101:
            alucontrol <= 3'b001; //or
          6'b101010:
            alucontrol <= 3'b111; //slt
          default:
            alucontrol <= 3'b000;
        endcase
    endcase

  end
endmodule
