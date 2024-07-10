`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 晴空-Tiso（B站同名）
// 
// Create Date: 2023/12/23 05:13:59
// Design Name: 
// Module Name: timer
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

/*
    timer #(.div_value()) TIMER0(
        .timeout(),
        .clk(),
        .rst()
    );
*/

module timer #(parameter div_value = 100_000_000,div_width = div_value > 0 ? $clog2(div_value + 1) : 1)(
    output reg timeout,
    input clk,
    input rst
);

    reg[div_width-1:0] cnt_value;
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            timeout <= 0;
        else if(cnt_value == div_value - 1)
            timeout <= 1;
        else
            timeout <= 0;
    end
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            cnt_value <= 0;
        else if(cnt_value == div_value - 1)
            cnt_value <= 0;
        else
            cnt_value <= cnt_value + 1;
    end
    
endmodule
