`timescale 1ns / 1ps

module cpu_tb();
    reg clk = 1'b1;
    reg rst = 1'b1;
    
    always  #2 clk = ~clk;
    initial #8 rst = 1'b0;
    wire miss, ref_signal;
    RV32Core RV32ICore_tb_inst(
        .CPU_CLK    ( clk          ),
        .CPU_RST    ( rst          ),
        .miss(miss),
        .ref_signal(ref_signal)
    );
    reg [31:0] miss_count, ref_count,clk_count;
    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            miss_count <= 0;
            ref_count <= 0;
            clk_count <= 0;
        end
        else
            clk_count <= clk_count + 1;
    end
    always @ (posedge miss)
    begin
        miss_count <= miss_count + 1;
    end
    always @(posedge ref_signal)
    begin
        ref_count <= ref_count + 1;
    end
  
    
endmodule
