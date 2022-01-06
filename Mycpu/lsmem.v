`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/02 19:44:24
// Design Name: 
// Module Name: lsmem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "defines.vh"

module lsmem(
    input wire[5:0]opM,
    input wire[32:0]aluoutM,
    output reg[32:0]readdataM_real,
    input wire[32:0]readdataM,
    output reg[31:0]writedataM,
    input wire[31:0]writedataM_temp,
    output reg [3:0]data_sram_wenM,
    output reg adelM,adesM,
    output reg [31:0]bad_addr,
    input wire [31:0]pcM
    );
always @(*) begin
    bad_addr <= pcM;
    adesM <= 1'b0;
    adelM <= 1'b0;
    case(opM)
        `EXE_LB: begin
            data_sram_wenM <= 4'b0000;
            case(aluoutM[1:0])
                2'b11: readdataM_real <= {{24{readdataM[31]}},readdataM[31:24]};
                2'b10: readdataM_real <= {{24{readdataM[23]}},readdataM[23:16]};
                2'b01: readdataM_real <= {{24{readdataM[15]}},readdataM[15:8]};
                2'b00: readdataM_real <= {{24{readdataM[7]}},readdataM[7:0]};
            endcase
        end
        `EXE_LBU: begin
            data_sram_wenM <= 4'b0000;
            case(aluoutM[1:0])
                2'b11: readdataM_real <= {{24{1'b0}},readdataM[31:24]};
                2'b10: readdataM_real <= {{24{1'b0}},readdataM[23:16]};
                2'b01: readdataM_real <= {{24{1'b0}},readdataM[15:8]};
                2'b00: readdataM_real <= {{24{1'b0}},readdataM[7:0]};
            endcase
        end
        `EXE_LH: begin
            data_sram_wenM <= 4'b0000;
            if(aluoutM[0] != 1'b0)begin
                 adelM <= 1'b1;
                 bad_addr <= aluoutM;
             end
             else begin
                 case(aluoutM[1])
                     2'b1: readdataM_real <= {{24{readdataM[31]}},readdataM[31:16]};
                     2'b0: readdataM_real <= {{24{readdataM[15]}},readdataM[15:0]};
                 endcase
             end
         end
         `EXE_LHU: begin
             data_sram_wenM <= 4'b0000;
             if(aluoutM[0] != 1'b0)begin
                 adelM <= 1'b1;
                 bad_addr <= aluoutM;
             end
             else begin
                 case(aluoutM[1])
                     2'b1: readdataM_real <= {{24{1'b0}},readdataM[31:16]};
                     2'b0: readdataM_real <= {{24{1'b0}},readdataM[15:0]};
                 endcase
             end
         end
         `EXE_LW: begin
             data_sram_wenM <= 4'b0000;
             if(aluoutM[1:0] != 2'b00)begin
                 adelM <= 1'b1;
                 bad_addr <= aluoutM;
             end
             else begin
                readdataM_real <= readdataM;
             end
         end
         `EXE_SB: begin
             writedataM <= {writedataM_temp[7:0],writedataM_temp[7:0],writedataM_temp[7:0],writedataM_temp[7:0]};
             case(aluoutM[1:0])
                 2'b11: data_sram_wenM <= 4'b1000;
                 2'b10: data_sram_wenM <= 4'b0100;
                 2'b01: data_sram_wenM <= 4'b0010;
                 2'b00: data_sram_wenM <= 4'b0001;
                 default: ;
             endcase
         end
         `EXE_SH: begin
             if(aluoutM[0] != 1'b0) begin
                 data_sram_wenM <= 4'b0000;
                 adesM <= 1'b1;
                 bad_addr <= aluoutM;
             end
             else begin
                writedataM <= {writedataM_temp[15:0],writedataM_temp[15:0]};
                case(aluoutM[1:0])
                     2'b10: data_sram_wenM <= 4'b1100;
                     2'b00: data_sram_wenM <= 4'b0011;
                     default: ;
                endcase
             end
         end
         `EXE_SW: begin
             if(aluoutM[1:0] != 2'b0) begin
                 data_sram_wenM <= 4'b0000;
                 adesM <= 1'b1;
                 bad_addr <= aluoutM;
             end
             else begin
                writedataM <= writedataM_temp;
                data_sram_wenM <=4'b1111;
             end
         end
         default:data_sram_wenM <= 4'b0000;
    endcase
end
endmodule
