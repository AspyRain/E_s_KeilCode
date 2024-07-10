/*管脚说明：
管脚名		标签		 用途
L1_IN1		PB10(T2C3)	左前轮信号输入1
L1_IN2		PB11(T2C4)	左前轮信号输入2
L2_IN1		PB0(T3C3)	左后轮信号输入1
L2_IN2		PB1(T3C4)	左后轮信号输入2
R1_IN1		PA6(T3C1)	右前轮信号输入1
R1_IN2		PA7(T3C2)	右前轮信号输入2
R2_IN1		PA0(T2C1)	右后轮信号输入1
R2_IN2		PA1(T2C2)	右后轮信号输入2
enable_L	PB13		左侧轮胎使能信号
enable_R	PB12		右侧轮胎使能信号
*/

// 逻辑功能描述：
/*  
        初始状态
            车辆状态：前进
            基础速度：50%

        车头测距
            head_distance >  10cm       ：方向不变，            速度不变
            head_distance <= 10cm       ：方向不变，            减速：速度 = head_distance * base_speed * 10%
            head_distance <= 5cm        ：停止  

        左车身测距  
            left_distance <= 5cm        ：方向改变，向右拐，     速度 = 20%

        右车身测距  
            right_distance <= 5cm       ：方向改变，向左拐，     速度 = 20%

        车尾测距    
            tail_distance >  10cm       ：方向不变，            速度不变
            tail_distance <= 10cm       ：方向不变，            减速，速度 = head_distance * base_speed * 10%
            tail_distance <= 5cm        ：停止  

        优先级
            当满足多个条件时，优先级顺序为
                                          车头
                                          车尾
                                          左车身
                                          右车身

        测距使能：
        当测距模块输出为0时，表示测距模块未工作，由人工控制车辆运动
        当测距模块输出为1时，表示测距模块工作，提醒操作人：车辆即将变速

        速度与方向的控制参数 16位 car_speed_output       //1+7+1+7


*/ 
/*
    根据逻辑功能设计状态机：
        状态机状态：
            IDLE    ：初始状态
            FORWARD ：前进
            LEFT    ：左拐
            RIGHT   ：右拐
            STOP    ：停止

        状态转移条件：
        IDLE ：
            head_distance <= 5cm    ：STOP
            head_distance <= 10cm   ：FORWARD
            right_distance <= 5cm   ：LEFT
            left_distance <= 5cm    ：RIGHT
            tail_distance <= 5cm    ：STOP

        FORWARD ：
            head_distance <= 5cm    ：STOP
            head_distance <= 10cm   ：FORWARD
            right_distance <= 5cm   ：LEFT
            left_distance <= 5cm    ：RIGHT
            tail_distance <= 5cm    ：STOP

        LEFT ：
            head_distance <= 5cm    ：STOP
            head_distance <= 10cm   ：FORWARD
            right_distance <= 5cm   ：LEFT
            left_distance <= 5cm    ：RIGHT
            tail_distance <= 5cm    ：STOP

        RIGHT ：
            head_distance <= 5cm    ：STOP
            head_distance <= 10cm   ：FORWARD
            right_distance <= 5cm   ：LEFT
            left_distance <= 5cm    ：RIGHT
            tail_distance <= 5cm    ：STOP
            
        STOP ：
            head_distance <= 5cm    ：STOP
            head_distance <= 10cm   ：FORWARD
            right_distance <= 5cm   ：LEFT
            left_distance <= 5cm    ：RIGHT
            tail_distance <= 5cm    ：STOP
    */

module  (
    input wire clk,
    input wire rst,

    input wire [7:0] head_distance,
    input wire [7:0] right_distance,
    input wire [7:0] left_distance,
    input wire [7:0] tail_distance,

    output reg [15:0] car_speed_output
);

// 当前速度
reg [7:0] speed_L;
reg [7:0] speed_R;
// 车辆状态
reg [2:0] car_state;
// 基础速度
parameter base_speed = 8'd50;
// 转向速度
parameter turn_speed = base_speed * 2;

// 状态机参数定义
localparam  IDLE    = 3'b000, // 空闲
            FORWARD = 3'b001, // 前进
            LEFT    = 3'b010, // 左拐
            RIGHT   = 3'b011, // 右拐
            STOP    = 3'b100; // 停止

// 状态机转移条件
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        car_state <= IDLE;
    end else begin
        case (car_state)
            IDLE: begin
                if (head_distance <= 8'd5) begin
                    car_state <= STOP;
                end else if (head_distance <= 8'd10) begin
                    car_state <= FORWARD;
                end else if (right_distance <= 8'd5) begin
                    car_state <= LEFT;
                end else if (left_distance <= 8'd5) begin
                    car_state <= RIGHT;
                end else if (tail_distance <= 8'd5) begin
                    car_state <= STOP;
                end
            end
            FORWARD: begin
                if (head_distance <= 8'd5) begin
                    car_state <= STOP;
                end else if (head_distance <= 8'd10) begin
                    car_state <= FORWARD;
                end else if (right_distance <= 8'd5) begin
                    car_state <= LEFT;
                end else if (left_distance <= 8'd5) begin
                    car_state <= RIGHT;
                end else if (tail_distance <= 8'd5) begin
                    car_state <= STOP;
                end
            end
            LEFT: begin
                if (head_distance <= 8'd5) begin
                    car_state <= STOP;
                end else if (head_distance <= 8'd10) begin
                    car_state <= FORWARD;
                end else if (right_distance <= 8'd5) begin
                    car_state <= LEFT;
                end else if (left_distance <= 8'd5) begin
                    car_state <= RIGHT;
                end else if (tail_distance <= 8'd5) begin
                    car_state <= STOP;
                end
            end
            RIGHT: begin
                if (head_distance <= 8'd5) begin
                    car_state <= STOP;
                end else if (head_distance <= 8'd10) begin
                    car_state <= FORWARD;
                end else if (right_distance <= 8'd5) begin
                    car_state <= LEFT;
                end else if (left_distance <= 8'd5) begin
                    car_state <= RIGHT;
                end else if (tail_distance <= 8'd5) begin
                    car_state <= STOP;
                end
            end
            STOP: begin
                if (head_distance <= 8'd5) begin
                    car_state <= STOP;
                end else if (head_distance <= 8'd10) begin
                    car_state <= FORWARD;
                end else if (right_distance <= 8'd5) begin
                    car_state <= LEFT;
                end else if (left_distance <= 8'd5) begin
                    car_state <= RIGHT;
                end else if (tail_distance <= 8'd5) begin
                    car_state <= STOP;
                end
            end
        endcase
    end
end

// 状态机输出
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        car_speed_output <= {1'b1, base_speed, 1'b1, base_speed};
    end else begin
        case (car_state)
            IDLE: begin
                car_speed_output <= {1'b1, base_speed, 1'b1, base_speed};
            end
            FORWARD: begin
                car_speed_output <= {1'b1, base_speed, 1'b1, base_speed};
            end
            LEFT: begin
                car_speed_output <= {1'b1, turn_speed, 1'b1, base_speed};
            end
            RIGHT: begin
                car_speed_output <= {1'b1, base_speed, 1'b1, turn_speed};
            end
            STOP: begin
                car_speed_output <= {1'b1, 7'b0, 1'b1, 7'b0};
            end
        endcase
    end
end

endmodule
