`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/07 22:42:57
// Design Name: 
// Module Name: CSR_regfile
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


module CSR_regfile(
    input wire clk,
    input wire rst,
    input wire CSR_write_en,
    input wire [11:0] CSR_write_addr,
    input wire [11:0] CSR_read_addr,
    input wire [31:0] CSR_data_write,
    output wire [31:0] CSR_data_read
    );
    parameter CSR_num = 4096;
    reg [31:0] reg_file[CSR_num - 1:0];
    integer i;

    // init register file
    initial
    begin
        for(i = 0; i < CSR_num; i = i + 1) 
            reg_file[i][31:0] <= 32'b0;
    end

    always@(posedge clk or posedge rst) 
    begin 
        if (rst)
            for (i = 1; i < CSR_num; i = i + 1) 
                reg_file[i][31:0] <= 32'b0;
        else if(CSR_write_en)
            reg_file[CSR_write_addr] <= CSR_data_write;   
    end
    
    assign CSR_data_read = reg_file[CSR_read_addr];


endmodule

