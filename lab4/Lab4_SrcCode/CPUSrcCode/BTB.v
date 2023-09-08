`timescale 1ns / 1ps

module BTB #(
    parameter SET_ADDR_LEN = 12,
    parameter TAG_ADDR_LEN = 20
)
(
    input clk, rst,
    input [31:0] query_PC,
    output [31:0] predict_PC,
    input update, br,
    input [31:0] PCX, br_target_PCX,
    output BTB_hit, BTB_br
    );
    localparam SET_SIZE = 1 << SET_ADDR_LEN;

    reg [TAG_ADDR_LEN-1 : 0] tag[0 : SET_SIZE-1];
    reg [31:0] target[0 : SET_SIZE-1];
    reg valid[0 : SET_SIZE-1];
    reg state[0 : SET_SIZE-1];

    wire [SET_ADDR_LEN-1 : 0]query_set_addr, PCX_set_addr;
    wire [TAG_ADDR_LEN-1 : 0]query_tag, PCX_tag;
    
    
    
    assign {query_tag, query_set_addr} = query_PC;
    assign {PCX_tag, PCX_set_addr} = PCX;
    integer i;
    always @ (posedge clk or posedge rst)
    begin
        if (rst)
        begin
            for (i = 0; i < SET_SIZE; i = i+1)
            begin
                tag[i] <= 0;
                target[i] <= 0;
                valid[i] <= 0;
                state[i] <= 0;
            end
        end
        else 
        begin
            //根据EX阶段实际是否跳转修改buffer
            if (update)
            begin
                if (br)
                begin
                    tag[PCX_set_addr] <=  PCX_tag;
                    target[PCX_set_addr] <= br_target_PCX;
                    valid[PCX_set_addr] <= 1'b1;
                    state[PCX_set_addr] <= 1'b1;     //状�?�转移预测跳�?
                end
                else
                begin
                    tag[PCX_set_addr] <=  PCX_tag;
                    target[PCX_set_addr] <= br_target_PCX;
                    valid[PCX_set_addr] <= 1'b1;
                    state[PCX_set_addr] <= 1'b0;       //实际不跳转那么下次将预测不跳�?
                end
            end
        end
    end
    
    assign BTB_hit = ( (tag[query_set_addr] == query_tag) && (valid[query_set_addr] == 1'b1) ) ? 1'b1 : 1'b0;
    //根据状�?�信息预测是否跳转当state�?1时预测跳转发�?
    assign BTB_br = ( (tag[query_set_addr] == query_tag) && (valid[query_set_addr] == 1'b1) && (state[query_set_addr] == 1'b1) ) ? 1'b1 : 1'b0;
    assign predict_PC = target[query_set_addr];
    
endmodule
