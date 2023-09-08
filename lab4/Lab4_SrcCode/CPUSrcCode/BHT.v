module BHT #(
    parameter SET_ADDR_LEN = 12
)
(
    input clk, rst,
    input [31:0] query_PC,  PCX,
    input br, update,
    output BHT_br
    );
    localparam SET_SIZE = 1 << SET_ADDR_LEN;
    
    reg [1 : 0] state[0 : SET_SIZE-1];
    
    
    wire [SET_ADDR_LEN-1 : 0] query_set_addr, PCX_set_addr;
    assign query_set_addr = query_PC[SET_ADDR_LEN-1 : 0];
    assign PCX_set_addr = PCX[SET_ADDR_LEN-1 : 0];
    integer i;
    always @ (posedge clk or posedge rst)
    begin
        if (rst)
        begin
            for (i = 0; i < SET_SIZE; i = i + 1)
            begin
                state[i] <= 0;
            end
        end
        else
        begin
            if (update)
            begin
                if (br == 1)
                begin
                    state[PCX_set_addr] <= (state[PCX_set_addr] == 2'b11) ? 2'b11 : state[PCX_set_addr] + 1;
                end
                else
                begin
                    state[PCX_set_addr] <= (state[PCX_set_addr] == 2'b00) ? 2'b00 : state[PCX_set_addr] - 1;
                end
            end
        end
    end
    
    assign BHT_br = (state[query_set_addr] == 2'b10 || state[query_set_addr] == 2'b11) ? 1'b1 : 1'b0;
endmodule