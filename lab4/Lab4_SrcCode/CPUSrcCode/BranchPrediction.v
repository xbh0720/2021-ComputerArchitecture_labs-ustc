module BranchPrediction # (
    parameter SET_ADDR_LEN = 12,
    parameter TAG_ADDR_LEN = 20
)
(
    input clk, rst,
    input [31:0] query_PC, PCX, br_target_PCX,PCD, br_target_PCD,
    input predict_brE,predict_brD,
    input update, br,       //标志EX段是否是branch指令
    input BTB_hitD,
    output reg branch_predict_fail,
    output reg [31:0] NPC,
    output predict_br,
    output reg flush1,
    output wire BTB_hit
    );
    
    localparam stage = 2;
    
    wire BTB_br;
    wire [31:0] BTB_predict_PC;
    wire BHT_br;
    wire [31:0] PC_next;
    
    assign PC_next = query_PC;
    
    wire [31:0] predict_PC;
    
    // only BTB predict
    assign predict_br = (stage == 1) ? BTB_br : BHT_br;
    assign predict_PC = (stage == 1) ? BTB_predict_PC : (BTB_hit ? BTB_predict_PC : PC_next + 4);
 
    
    
    always @ (*)
    begin
        if (update)
        begin
            // if is EX Branch instruction
            if (predict_brE == br)
            begin
                // branch predict successfully
                if(predict_brD && stage == 2 && BTB_hitD == 0)
                begin
                    NPC = br ? br_target_PCD : br_target_PCD - 4;
                    flush1 = 1;
                end
                else
                begin
                    NPC = predict_br ? (br ? predict_PC : predict_PC - 4) : (br ? PC_next + 4 : PC_next);
                    flush1 = 0;
                end
                branch_predict_fail = 0;
            end
            else
            begin
                // branch predict failed at  2 cycles before
                // if current is branch so NPC is br_target, else is PC_EX + 4
                NPC = br ? br_target_PCX : PCX;
                branch_predict_fail = 1;
                flush1 = 0;
            end
        end
        else
        begin
            // EX is not Branch Instruction
            flush1 = 0;
            branch_predict_fail = 0;
            if(predict_brD && stage == 2 && BTB_hitD == 0)
            begin
                NPC = br_target_PCD - 4;
                flush1 = 1;
            end
            else
                NPC = predict_br ? predict_PC  - 4 : PC_next;
            
        end
        
    end 
    
    
    BTB #(
        .SET_ADDR_LEN(SET_ADDR_LEN),
        .TAG_ADDR_LEN(TAG_ADDR_LEN)
    ) btb (
        .clk(clk),
        .rst(rst),
        .query_PC(query_PC),
        .PCX(PCX),
        .br_target_PCX(br_target_PCX),
        .update(update),
        .br(br),
        .BTB_hit(BTB_hit),
        .BTB_br(BTB_br),
        .predict_PC(BTB_predict_PC)
    );
    
    BHT # (
        .SET_ADDR_LEN(SET_ADDR_LEN)
    ) bht (
        .clk(clk),
        .rst(rst),
        .query_PC(query_PC),
        .PCX(PCX),
        .update(update),
        .br(br),
        .BHT_br(BHT_br)
    );
    
endmodule
