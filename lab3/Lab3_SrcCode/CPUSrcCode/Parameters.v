`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB 
// Engineer: Wu Yuzhang
// 
// Design Name: RISCV-Pipline CPU
// Module Name: 
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Define some constant values
//////////////////////////////////////////////////////////////////////////////////
//功能说明
    //为了代码可读性，定义了常量�??
//实验要求  
    //无需修改

`ifndef CONST_VALUES
`define CONST_VALUES
//ALUContrl[3:0]
    `define SLL  4'd0
    `define SRL  4'd1
    `define SRA  4'd2
    `define ADD  4'd3
    `define SUB  4'd4
    `define XOR  4'd5
    `define OR  4'd6
    `define AND  4'd7
    `define SLT  4'd8
    `define SLTU  4'd9
    `define LUI  4'd10
    `define OP1 4'd11
    `define NAND 4'd12
//BranchType[2:0]
    `define NOBRANCH  3'd0
    `define BEQ  3'd1
    `define BNE  3'd2
    `define BLT  3'd3
    `define BLTU  3'd4
    `define BGE  3'd5
    `define BGEU  3'd6
//ImmType[2:0]
    `define RTYPE  3'd0
    `define ITYPE  3'd1
    `define STYPE  3'd2
    `define BTYPE  3'd3
    `define UTYPE  3'd4
    `define JTYPE  3'd5  
//RegWrite[2:0]  six kind of ways to save values to Register
    `define NOREGWRITE  3'b0	//	Do not write Register
    `define LB  3'd1			//	load 8bit from Mem then signed extended to 32bit
    `define LH  3'd2			//	load 16bit from Mem then signed extended to 32bit
    `define LW  3'd3			//	write 32bit to Register
    `define LBU  3'd4			//	load 8bit from Mem then unsigned extended to 32bit
    `define LHU  3'd5			//	load 16bit from Mem then unsigned extended to 32bit

//opcode value
    `define R_TYPE 7'b0110011
    `define I_LOAD 7'b0000011
    `define I_ARI  7'b0010011
    `define S_TYPE 7'b0100011
    `define B_TYPE 7'b1100011
    //U_TYPE
    `define U_LUI  7'b0110111
    `define U_AUIPC 7'b0010111
    //J_TYPE
    `define J_JALR 7'b1100111
    `define J_JAL  7'b1101111
    //CSR
    `define CSR 7'b1110011
    `define CSRRC 3'b011
    `define CSRRCI 3'b111
    `define CSRRS 3'b010
    `define CSRRSI 3'b110
    `define CSRRW 3'b001
    `define CSRRWI 3'b101
`endif
