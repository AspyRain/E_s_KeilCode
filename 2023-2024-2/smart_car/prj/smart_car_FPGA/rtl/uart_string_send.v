`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 晴空-Tiso（B站同名）
// 
// Create Date: 2024/01/01 00:50:15
// Design Name: 
// Module Name: uart_string_send
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.03 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*
    uart_string_send #(.byte_num()) UART_SEND0(
        .uart_data(),
        .uart_start(),
        .done(),
        .idle(),
        .string_in(),
        .uart_tx_done(),
        .uart_tx_idle(),
        .send_start(),
        .clk(),
        .rst()
        );
*/

module uart_string_send #(parameter byte_num = 1) (
    output reg[7:0] uart_data,
    output reg uart_start,
    output reg done,
    output idle,
    input[byte_num * 8 - 1 : 0] str_in,
    input uart_tx_done,
    input uart_tx_idle,
    input send_start,
    input clk,
    input rst
    );
    wire send_cnt_done;
    wire baud_cnt_done;
    localparam cnt_width = byte_num > 0 ? $clog2(byte_num) : 1;
    
    localparam IDLE  = 0,
               SEND = 1,
               FINISH = 2;
    
    reg[1:0] state;
    
    wire[cnt_width-1:0] send_cnt;
    
    assign idle = state == IDLE;
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            state <= IDLE;
        else begin
            case(state)
                IDLE:
                    if(send_start && uart_tx_idle)
                        state <= SEND;
                
                SEND:
                    if(send_cnt_done)
                        state <= FINISH;
                
                FINISH:
                    if(uart_tx_idle)
                        state <= IDLE;
                
                default:
                    state <= IDLE;
            endcase
        end
    end
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            uart_start <= 0;
        else begin
            case(state)
                IDLE:
                    if(send_start && uart_tx_idle)
                        uart_start <= 1;
                    else
                        uart_start <= 0;
                
                SEND:
                    if(uart_tx_done)
                        uart_start <= 1;
                    else
                        uart_start <= 0;
                
                default:
                    uart_start <= 0;
            endcase
        end
    end
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            done <= 0;
        else if(state == FINISH && uart_tx_idle)
            done <= 1;
        else
            done <= 0;
    end
    
    always@(*)
    begin
        uart_data <= str_in[(send_cnt+1)*8-1-:8];
    end
    
    cnt #(
        .dir(1),
        .en(1),
        .max_value(byte_num)
        ) CNT0
        (
        .cnt_value(send_cnt),
        .done(send_cnt_done),
        .cnt_en(uart_start),
        .clk(clk),
        .rst(rst)
        );
    
endmodule
