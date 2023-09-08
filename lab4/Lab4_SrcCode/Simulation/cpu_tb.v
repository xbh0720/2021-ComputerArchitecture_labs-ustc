`timescale 1ns / 1ps

module cpu_tb();
    reg clk = 1'b1;
    reg rst = 1'b1;
    
    always  #2 clk = ~clk;
    initial #8 rst = 1'b0;
    wire update, predict_fail;
    
    RV32Core RV32Core_tb_inst(
        .CPU_CLK    ( clk          ),
        .CPU_RST    ( rst          ),
        .debug_update(update),
        .debug_BR_fail(predict_fail)
    );
    integer clk_count, br_count, fail_count;
    always@(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            clk_count = 0;
            br_count = 0;
            fail_count = 0;
        end
        else
            clk_count = clk_count + 1;
    end
    always@(posedge update)
    begin
        br_count = br_count + 1;
    end
    always@(posedge clk)
    begin
        if(predict_fail)
        begin
            fail_count = fail_count + 1;
        end
    end
     
    
endmodule
