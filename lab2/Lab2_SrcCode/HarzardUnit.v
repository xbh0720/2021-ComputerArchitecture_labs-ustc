`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB 
// Engineer: Wu Yuzhang
// 
// Design Name: RISCV-Pipline CPU
// Module Name: HarzardUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Deal with harzards in pipline
//////////////////////////////////////////////////////////////////////////////////
//功能说明
    //HarzardUnit用来处理流水线冲突，通过插入气泡，forward以及冲刷流水段解决数据相关和控制相关，组合�?�辑电路
    //可以�?后实现�?�前期测试CPU正确性时，可以在每两条指令间插入四条空指令，然后直接把本模块输出定为，不forward，不stall，不flush 
//输入
    //CpuRst                                    外部信号，用来初始化CPU，当CpuRst==1时CPU全局复位清零（所有段寄存器flush），Cpu_Rst==0时cpu�?始执行指�?
    //ICacheMiss, DCacheMiss                    为后续实验预留信号，暂时可以无视，用来处理cache miss
    //BranchE, JalrE, JalD                      用来处理控制相关
    //Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW     用来处理数据相关，分别表示源寄存�?1号码，源寄存�?2号码，目标寄存器号码
    //RegReadE RegReadD[1]==1                   表示A1对应的寄存器值被使用到了，RegReadD[0]==1表示A2对应的寄存器值被使用到了，用于forward的处�?
    //RegWriteM, RegWriteW                      用来处理数据相关，RegWrite!=3'b0说明对目标寄存器有写入操�?
    //MemToRegE                                 表示Ex段当前指�? 从Data Memory中加载数据到寄存器中
//输出
    //StallF, FlushF, StallD, FlushD, StallE, FlushE, StallM, FlushM, StallW, FlushW    控制五个段寄存器进行stall（维持状态不变）和flush（清零）
    //Forward1E, Forward2E                                                              控制forward
//实验要求  
    //补全模块  
    
    
module HarzardUnit(
    input wire CpuRst, ICacheMiss, DCacheMiss, 
    input wire BranchE, JalrE, JalD, 
    input wire [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
    input wire [1:0] RegReadE,
    input wire MemToRegE,
    input wire [2:0] RegWriteM, RegWriteW,
    output reg StallF, FlushF, StallD, FlushD, StallE, FlushE, StallM, FlushM, StallW, FlushW,
    output reg [1:0] Forward1E, Forward2E
    );
    
    // 请补全此处代�?
    //产生forward控制信号
    always @(*)
    begin
        //gernerate Forward1E
        if(Rs1E != 0 && Rs1E == RdM && (|RegWriteM) != 0 && RegReadE[1] == 1)
        begin
            //mem to ex forward1
            Forward1E = 2'b10;
        end
        else if(Rs1E != 0 && Rs1E == RdW && (|RegWriteW) != 0 && RegReadE[1] == 1)
        begin
            //wb to ex forward1
            Forward1E = 2'b01;
        end
        else
        begin
            Forward1E = 2'b00;
        end
    end
    //gernerate Forward2E
    always @(*)
    begin   
        if(Rs2E != 0 && Rs2E == RdM && (|RegWriteM) != 0 && RegReadE[0] == 1) //dest reg 不能�?0号寄存器
        begin
            //mem to ex forward2
            Forward2E = 2'b10;
        end
        else if(Rs2E != 0 && Rs2E == RdW && (|RegWriteW) != 0 && RegReadE[0] == 1)
        begin
            //wb to ex forward2
            Forward2E = 2'b01;
        end
        else
        begin
            Forward2E = 2'b00;
        end
    end
    //gernerate Stall load-use
    //gernerate Flush branch(2), Jump(1)
    //gernerate StallF, FlushF, StallD, FlushD, StallE, FlushE
    always @(*)
    begin
        if(CpuRst)
        begin
            FlushF = 1'b1;
            FlushD = 1'b1;
            FlushE = 1'b1;
            StallF = 1'b0;
            StallD = 1'b0;
            StallE = 1'b0;
        end
        else
        begin
            //gernerate stall load-use,在ID段即进行判断
            if((Rs1D == RdE  || Rs2D == RdE) && MemToRegE == 1 )
            begin
                //stall and bubble down
                StallF = 1'b1;
                StallD = 1'b1;
                FlushE = 1'b1;

                FlushF = 1'b0;
                FlushD = 1'b0;
                StallE = 1'b0;
            end
            //generate flush succeffully branch ,Jal, Jalr
            else if(BranchE == 1)
            begin
                FlushD = 1'b1;
                FlushE = 1'b1;
                
                FlushF = 1'b0;
                StallF = 1'b0;
                StallD = 1'b0;
                StallE = 1'b0;
            end
            else if(JalrE == 1)
            begin
                FlushD = 1'b1;
                FlushE = 1'b1;
                
                FlushF = 1'b0;
                StallF = 1'b0;
                StallD = 1'b0;
                StallE = 1'b0;
            end
            else if(JalD == 1)
            begin
                FlushD = 1'b1;

                FlushF = 1'b0;
                StallF = 1'b0;
                StallD = 1'b0;
                FlushE = 1'b0;
                StallE = 1'b0;
            end
            else
            begin
                FlushF = 1'b0;
                StallF = 1'b0;
                FlushD = 1'b0;
                StallD = 1'b0;
                FlushE = 1'b0;
                StallE = 1'b0;
            end
        end
    end
    //generate FlushM, StallM
    always @(*)
    begin
        if(CpuRst)
        begin
            FlushM = 1'b1;
            StallM = 1'b0;
        end
        else
        begin
            FlushM = 1'b0;
            StallM = 1'b0;
        end
    end
    //generate FlushW, StallW
    always @(*)
    begin
        if(CpuRst)
        begin
            FlushW = 1'b1;
            StallW = 1'b0;
        end
        else
        begin
            FlushW = 1'b0;
            StallW = 1'b0;
        end
    end

endmodule

  