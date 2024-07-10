module filter(
    input clk,                 
    input rst_n,              
    input [18:0] pulse_num,    // 输入距离

    output [18:0] pul_dev,
    output [18:0] filter_num   // 输出过滤后的距离
);

// 定义一个寄存器数组，用于存储过去 pulse_num 的值
reg [18:0] pul_buf[7:0];
// 当时钟上升沿或复位信号下降沿时执行
always @(posedge clk or negedge rst_n) begin
    // 如果复位信号为低，则将所有缓冲寄存器清零
    if (!rst_n) begin
        pul_buf[0] <= 19'd0;
        pul_buf[1] <= 19'd0;
        pul_buf[2] <= 19'd0;
        pul_buf[3] <= 19'd0;
        pul_buf[4] <= 19'd0;
        pul_buf[5] <= 19'd0;
        pul_buf[6] <= 19'd0;
        pul_buf[7] <= 19'd0;
    end
    else if (pul_dev <= pulse_num)begin
            pul_buf[0] <= pulse_num;
            pul_buf[1] <= pul_buf[0];
            pul_buf[2] <= pul_buf[1];
            pul_buf[3] <= pul_buf[2];
            pul_buf[4] <= pul_buf[3];
            pul_buf[5] <= pul_buf[4];
            pul_buf[6] <= pul_buf[5];
            pul_buf[7] <= pul_buf[6];
    end
    else begin
            pul_buf[0] <= pul_buf[0];
            pul_buf[1] <= pul_buf[1];
            pul_buf[2] <= pul_buf[2];
            pul_buf[3] <= pul_buf[3];
            pul_buf[4] <= pul_buf[4];
            pul_buf[5] <= pul_buf[5];
            pul_buf[6] <= pul_buf[6];
            pul_buf[7] <= pul_buf[7];
    end
end

// 定义一个寄存器，用于计算缓冲区中所有值的总和
reg [20:0] sum_pul;

// 当时钟上升沿或复位信号下降沿时执行
always @(posedge clk or negedge rst_n) begin
    // 如果复位信号为低，则将总和寄存器清零
    if (!rst_n) begin
        sum_pul <= 21'd0;
    end
    // 否则，计算缓冲区中所有值的总和
    else begin
        sum_pul <= pul_buf[0] + pul_buf[1] + pul_buf[2] + pul_buf[3] + pul_buf[4] + pul_buf[5] + pul_buf[6] + pul_buf[7];
    end
end

// 将总和的高位部分赋值给输出信号 filter_num，并右移 3 位(除以 8)
assign filter_num = {3'b0, sum_pul[20:3]};
assign pul_dev = (pulse_num > pul_buf[0])?pulse_num-pul_buf[0]:pul_buf[0]-pulse_num;
endmodule
