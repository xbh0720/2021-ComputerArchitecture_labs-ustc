`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB 
// Engineer: Wu Yuzhang
// 
// Design Name: RISCV-Pipline CPU
// Module Name: ControlUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: RISC-V Instruction Decoder
//////////////////////////////////////////////////////////////////////////////////
//功能和接口说�???
    //ControlUnit       是本CPU的指令译码器，组合�?�辑电路
//输入
    // Op               是指令的操作码部�???
    // Fn3              是指令的func3部分
    // Fn7              是指令的func7部分
//输出
    // JalD==1          表示Jal指令到达ID译码阶段
    // JalrD==1         表示Jalr指令到达ID译码阶段
    // RegWriteD        表示ID阶段的指令对应的寄存器写入模�???
    // MemToRegD==1     表示ID阶段的指令需要将data memory读取的�?�写入寄存器,
    // MemWriteD        �???4bit，采用独热码格式，对于data memory�???32bit字按byte进行写入,MemWriteD=0001表示只写入最�???1个byte，和xilinx bram的接口类�???
    // LoadNpcD==1      表示将NextPC输出到ResultM
    // RegReadD         表示A1和A2对应的寄存器值是否被使用到了，用于forward的处�???
    // BranchTypeD      表示不同的分支类型，�???有类型定义在Parameters.v�???
    // AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v�???
    // AluSrc2D         表示Alu输入�???2的�?�择
    // AluSrc1D         表示Alu输入�???1的�?�择
    // ImmType          表示指令的立即数格式
//实验要求  
    //补全模块  

`include "Parameters.v"   
module ControlUnit(
    input wire [6:0] Op,
    input wire [2:0] Fn3,
    input wire [6:0] Fn7,
    output wire JalD,
    output wire JalrD,
    output reg [2:0] RegWriteD,
    output wire MemToRegD,
    output reg [3:0] MemWriteD,
    output wire LoadNpcD,
    output reg [1:0] RegReadD,
    output reg [2:0] BranchTypeD,
    output reg [3:0] AluContrlD,
    output wire [1:0] AluSrc2D,
    output wire AluSrc1D,
    output reg [2:0] ImmType,
    output wire CSR_writeD,
    output reg CSR_imm_regD      
    ); 
    // 请补全此处代�???
    assign JalD = (Op == `J_JAL) ? 1'b1: 1'b0;
    assign JalrD = (Op == `J_JALR) ? 1'b1 : 1'b0;
    assign LoadNpcD = (Op == `J_JAL || Op == `J_JALR) ? 1'b1 : 1'b0;
    assign MemToRegD = (Op == `I_LOAD) ? 1'b1 : 1'b0;
    assign AluSrc1D = (Op == `U_AUIPC) ? 1'b1 : 1'b0;
    assign AluSrc2D = (Op == `R_TYPE || Op == `B_TYPE) ? 2'b00 : 2'b10;
    assign CSR_writeD = (Op == `CSR) ? 1'b1 : 1'b0;
    always @(*)
    begin
        CSR_imm_regD = 1'b0;  //选择rs
        case(Op)
            `R_TYPE:
            begin
                RegWriteD = 3'b011;     
                MemWriteD = 4'b0000;
                RegReadD = 2'b11;
                ImmType = `RTYPE;
                BranchTypeD = 3'b0;
                //ADD,SUB,XOR,OR,AND,...alucontrol
                if(Fn3 == 3'b000)   //add or sub
                begin
                    if(Fn7 == 7'b0000000)     //add
                    begin
                        AluContrlD = `ADD;
                    end
                    else if(Fn7 == 7'b0100000)    //sub
                    begin
                        AluContrlD = `SUB;
                    end
                    else
                    begin
                        AluContrlD = 4'b0;
                        RegWriteD = 3'b0;
                    end
                end
                else if(Fn3 == 3'b001) //SLL
                begin
                    AluContrlD = `SLL; 
                end
                else if(Fn3 == 3'b010)  //SLT
                begin
                    AluContrlD = `SLT;
                end
                else if(Fn3 == 3'b011)  //SLTU
                begin
                    AluContrlD = `SLTU;
                end
                else if(Fn3 == 3'b100)  //XOR
                begin
                    AluContrlD = `XOR;
                end
                else if(Fn3 == 3'b101)  //SRL or SRA
                begin
                    if(Fn7 == 7'b0000000)
                    begin
                        AluContrlD = `SRL;
                    end
                    else if(Fn7 == 7'b0100000)
                    begin
                        AluContrlD = `SRA;
                    end
                    else
                    begin
                        AluContrlD = 4'b0;
                        RegWriteD = 3'b0;
                    end
                end
                else if(Fn3 == 3'b110)  //OR
                begin
                    AluContrlD = `OR;
                end
                else if(Fn3 == 3'b111)  //AND
                begin
                    AluContrlD = `AND;
                end
            
            end
            `I_LOAD:
            begin
                MemWriteD = 4'b0000;
                RegReadD = 2'b10;
                ImmType = `ITYPE;
                AluContrlD = `ADD;
                BranchTypeD = 3'b0;
                //LW,LH,LB,LBU,LHU regwite
                if(Fn3 == 3'b000)   //LB
                begin
                    RegWriteD = `LB;
                end
                else if(Fn3 == 3'b001)  //LH
                begin
                    RegWriteD = `LH;
                end
                else if(Fn3 == 3'b010)  //LW
                begin
                    RegWriteD = `LW;
                end
                else if(Fn3 == 3'b100)  //LBU
                begin
                    RegWriteD = `LBU;
                end
                else if(Fn3 == 3'b101)  //LHU
                begin
                    RegWriteD = `LHU;
                end
                else
                begin
                    RegWriteD = `NOREGWRITE;
                end
            end
            `I_ARI:
            begin
                RegWriteD = 3'b011;
                MemWriteD = 4'b0000;
                RegReadD = 2'b10;
                ImmType = `ITYPE;
                BranchTypeD = 3'b0;
                //addi,xori... alucontrol
                if(Fn3 == 3'b000)   //addi
                begin
                    AluContrlD = `ADD;
                end
                else if(Fn3 == 3'b001)  //SLLI
                begin
                    AluContrlD = `SLL;
                end
                else if(Fn3 == 3'b010)  //SLTI
                begin
                    AluContrlD = `SLT;
                end
                else if(Fn3 == 3'b011)  //SLTIU
                begin
                    AluContrlD = `SLTU;
                end
                else if(Fn3 == 3'b100)  //XORI
                begin
                    AluContrlD = `XOR;
                end
                else if(Fn3 == 3'b101)  //SRLI or SRAI
                begin
                    if(Fn7 == 7'b0000000)
                    begin
                        AluContrlD = `SRL;
                    end
                    else if(Fn7 == 7'b0100000)
                    begin
                        AluContrlD = `SRA;
                    end
                    else
                    begin
                        AluContrlD = 4'b0;
                        RegWriteD = 3'b0;
                    end
                end
                else if(Fn3 == 3'b110)  //ORI
                begin
                    AluContrlD = `OR;
                end
                else if(Fn3 == 3'b111)  //ANDI
                begin
                    AluContrlD = `AND;
                end
                else
                begin
                    AluContrlD = 4'b0;
                    RegWriteD = 3'b0;
                end
            end
            `S_TYPE:
            begin
                RegWriteD = 3'b000;
                RegReadD = 2'b11;
                ImmType = `STYPE;
                AluContrlD = `ADD;
                BranchTypeD = 3'b0;
                //SW,SH,SB,memwrite
                if(Fn3 == 3'b000)   //SB
                begin
                    MemWriteD = 4'b0001;
                end
                else if(Fn3 == 3'b001)  //SH
                begin
                    MemWriteD = 4'b0011;
                end
                else if(Fn3 == 3'b010)  //SW
                begin
                    MemWriteD = 4'b1111;
                end
                else
                begin
                    MemWriteD = 4'b0000;
                end
            end
            `B_TYPE:
            begin
                RegWriteD = 3'b000;
                MemWriteD = 4'b0000;
                RegReadD = 2'b11;
                ImmType = `BTYPE;
                AluContrlD = 4'b0;  
                //branchtype bne beq bge...
                if(Fn3 == 3'b000)   //BEQ
                begin
                    BranchTypeD = `BEQ;
                end
                else if(Fn3 == 3'b001)  //BNE
                begin
                    BranchTypeD = `BNE;
                end
                else if(Fn3 == 3'b100)  //BLT
                begin
                    BranchTypeD = `BLT;
                end
                else if(Fn3 == 3'b101)  //BGE
                begin
                    BranchTypeD = `BGE;
                end
                else if(Fn3 == 3'b110)  //BLTU
                begin
                    BranchTypeD = `BLTU;
                end
                else if(Fn3 == 3'b111)  //BGEU
                begin
                    BranchTypeD = `BGEU;
                end
                else
                begin
                    BranchTypeD = `NOBRANCH;
                end

            end
            `U_LUI: //imm -> rd
            begin
                RegWriteD = 3'b011;
                MemWriteD = 4'b0000;
                RegReadD = 2'b00; 
                BranchTypeD = 3'b0;
                ImmType = `UTYPE;
                AluContrlD = `LUI;
            end
            `U_AUIPC:   //PC + imm -> rd
            begin
                RegWriteD = 3'b011;
                MemWriteD = 4'b0000;
                RegReadD = 2'b00;
                AluContrlD = `ADD;
                BranchTypeD = 3'b0;
                ImmType = `UTYPE;
            end
            `J_JAL:
            begin
                RegWriteD = 3'b011; //返回地址->rd
                MemWriteD = 4'b0000;
                RegReadD = 2'b00;
                AluContrlD = 4'b0;
                BranchTypeD = 3'b0;
                ImmType = `JTYPE;
            end
            `J_JALR:
            begin
                RegWriteD = 3'b011; //返回地址 -> rd
                MemWriteD = 4'b0000;
                RegReadD = 2'b10;
                AluContrlD = `ADD;
                BranchTypeD = 3'b0;
                ImmType = `ITYPE;
            end
            `CSR:
            begin
                RegWriteD = 3'b011; //csr -> rd
                MemWriteD = 4'b0000;
                BranchTypeD = 3'b0;
                ImmType = 0;
                CSR_imm_regD = 1'b0;
                if(Fn3 == `CSRRW) //CSRRW
                begin    
                    RegReadD = 2'b10;   //rs1 -> csr
                    AluContrlD = `OP1;            
                end
                else if(Fn3 == `CSRRS)    //CSRRS
                begin
                    RegReadD = 2'b10;
                    AluContrlD = `OR;
                end
                else if(Fn3 == `CSRRC)    //CSRRC
                begin
                    RegReadD = 2'b10;
                    AluContrlD = `NAND;
                end
                else if(Fn3 == `CSRRWI)    //CSRRWI
                begin
                    RegReadD = 2'b00;
                    AluContrlD = `OP1;
                    CSR_imm_regD = 1'b1;
                end
                else if(Fn3 == `CSRRSI)    //CSRRSI
                begin
                    RegReadD = 2'b00;
                    AluContrlD = `OR;
                    CSR_imm_regD = 1'b1;
                end
                else if(Fn3 == `CSRRCI)    //CSRRCI
                begin
                    RegReadD = 2'b00;
                    AluContrlD = `NAND;
                    CSR_imm_regD = 1'b1;
                end
                else
                begin
                    RegReadD = 2'b00;
                    AluContrlD = 0;
                end
            end
            default:
            begin
                RegWriteD = 3'b000;
                MemWriteD = 4'b0000;
                RegReadD = 2'b00;
                AluContrlD = 4'b0;
                BranchTypeD = 3'b0;
                ImmType = `RTYPE;
            end
        endcase
        
    end

endmodule

