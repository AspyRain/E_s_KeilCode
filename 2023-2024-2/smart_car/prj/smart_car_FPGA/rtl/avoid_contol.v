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
            LEFT_DIS    ：左拐
            RIGHT_DIS   ：右拐
            STOP    ：停止

        状态转移条件：
        IDLE ：
            head_distance <= 5cm    ：STOP
            head_distance <= 10cm   ：FORWARD
            right_distance <= 5cm   ：LEFT_DIS
            left_distance <= 5cm    ：RIGHT_DIS
            tail_distance <= 5cm    ：STOP

        FORWARD ：
            head_distance <= 5cm    ：STOP
            head_distance <= 10cm   ：FORWARD
            right_distance <= 5cm   ：LEFT_DIS
            left_distance <= 5cm    ：RIGHT_DIS
            tail_distance <= 5cm    ：STOP

        LEFT_DIS ：
            head_distance <= 5cm    ：STOP
            head_distance <= 10cm   ：FORWARD
            right_distance <= 5cm   ：LEFT_DIS
            left_distance <= 5cm    ：RIGHT_DIS
            tail_distance <= 5cm    ：STOP

        RIGHT_DIS ：
            head_distance <= 5cm    ：STOP
            head_distance <= 10cm   ：FORWARD
            right_distance <= 5cm   ：LEFT_DIS
            left_distance <= 5cm    ：RIGHT_DIS
            tail_distance <= 5cm    ：STOP
            
        STOP ：
            head_distance <= 5cm    ：STOP
            head_distance <= 10cm   ：FORWARD
            right_distance <= 5cm   ：LEFT_DIS
            left_distance <= 5cm    ：RIGHT_DIS
            tail_distance <= 5cm    ：STOP
    */

module avoid_control (
    input       wire            clk,
    input       wire            rst,

    input       wire [12:0]      head_distance  ,
    input       wire [12:0]      right_distance ,
    input       wire [12:0]      left_distance  ,
    input       wire [12:0]      tail_distance  ,
    input       wire [15:0]      car_speed_input,       //传入遥控模块的速度参数
    input       wire [3:0]       state_ctrl     ,
    output      reg        [1:0]    front_triggered     ,
    output      reg        [1:0]    back_triggered      ,
    output      wire [7:0]       close_flag     ,       //距离状态参数 [前，后，左，右]；各两位


    output   [15:0]   car_speed_output
);
    reg        [1:0]    left_triggered      ;
    reg        [1:0]    right_triggered     ; 
    reg        [6:0]    left_speed          ;
    reg        [6:0]    right_speed          ;
    parameter           FRONT_DIS   =   1       ,
                        BACK_DIS    =   2       ,
                        LEFT_DIS    =   3       ,
                        RIGHT_DIS   =   4       ;

    parameter   LEFT = 1            ,
                RIGHT = 2           ,
                FORWARD = 3         ,
                BACK = 4            ,
                LEFT_FORWARD =5     ,
                LEFT_BACK = 6       ,
                RIGHT_FORWARD = 7   ,
                RIGHT_BACK = 8      ,
                STOP = 0            ;
    
        always @(posedge clk or negedge rst) begin
        if (!rst)begin
            front_triggered <= 2'b00;
            left_triggered <= 2'b00;
            right_triggered <= 2'b00;
        end
        else begin
            //设置trigger触发
            //头部
            if (head_distance < 13'd200)begin
                if (head_distance < 13'd100)begin
                    front_triggered <= 2'b10;
                end
                else begin
                    front_triggered <= 2'b01;
                end
            end
            else begin
                front_triggered <= 2'b00;
            end
        end
        end


        always @(posedge clk or negedge rst) begin
        if (!rst)begin
            back_triggered <= 2'b00;
        end
        else begin
            //设置trigger触发
            //头部
            if (tail_distance < 13'd200)begin
                if (tail_distance < 13'd100)begin
                    back_triggered <= 2'b10;
                end
                else begin
                    back_triggered <= 2'b01;
                end
            end
            else begin
                back_triggered <= 2'b00;
            end
        end
        end

    
    //判断 障距
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            left_speed <= 7'b0;
            right_speed <= 7'b0;
        end
        else begin
            // 根据状态触发设置速度
        case ({front_triggered[1:0], back_triggered[1:0], left_triggered[1:0], right_triggered[1:0]})
            
            8'b01000000: begin 
                //头部触发处理 第一阶段
                if (state_ctrl == FORWARD)begin
                    left_speed <= ( head_distance - 100)*car_speed_input[14:8]/100;
                    right_speed <=(head_distance- 100)*car_speed_input[6:0]/100;
                    
                end
                else if (state_ctrl == LEFT_FORWARD) begin
                    left_speed <= (head_distance- 100)*car_speed_input[14:8]/100;
                    right_speed <= car_speed_input[6:0];
                    
                end
                else if (state_ctrl == RIGHT_FORWARD) begin
                    right_speed <= (head_distance- 100)*car_speed_input[14:8]/100;
                    left_speed <= car_speed_input[14:8];
                    
                end
                else  begin
                    left_speed <= car_speed_input[14:8];
                    right_speed <= car_speed_input[6:0];
                    
                end
            end
            8'b10000000: begin 
                //头部触发处理 第二阶段
                if (state_ctrl == FORWARD || state_ctrl == LEFT_FORWARD || state_ctrl == RIGHT_FORWARD) begin
                    left_speed <= 7'b0;
                    right_speed <=  7'b0;
                    
                end
                    
                else  begin
                    left_speed <= car_speed_input[14:8];
                    right_speed <= car_speed_input[6:0];
                    
                end
                    
            end

            8'b00010000: begin 
                //尾部触发处理 第一阶段
                if (state_ctrl == BACK)begin
                    left_speed <= ( tail_distance - 100)*car_speed_input[14:8]/100;
                    right_speed <=(tail_distance- 100)*car_speed_input[6:0]/100;
                    
                end
                else if (state_ctrl == LEFT_BACK) begin
                    left_speed <= (tail_distance- 100)*car_speed_input[14:8]/100;
                    right_speed <= car_speed_input[6:0];
                    
                end
                else if (state_ctrl == RIGHT_BACK) begin
                    right_speed <= (tail_distance- 100)*car_speed_input[14:8]/100;
                    left_speed <= car_speed_input[14:8];
                    
                end
                else  begin
                    left_speed <= car_speed_input[14:8];
                    right_speed <= car_speed_input[6:0];
                    
                end
            end
            8'b10000000: begin 
                //尾部触发处理 第二阶段
                if (state_ctrl == BACK || state_ctrl == LEFT_BACK || state_ctrl == RIGHT_BACK) begin
                    left_speed <= 7'b0;
                    right_speed <=  7'b0;
                    
                end
                    
                else  begin
                    left_speed <= car_speed_input[14:8];
                    right_speed <= car_speed_input[6:0];
                    
                end
                    
            end
            default: begin
                // 无优先级触发或手动控制
                left_speed <= car_speed_input[14:8];
                right_speed <= car_speed_input[6:0];
            end
        endcase
        end
    end

    assign close_flag = {front_triggered,back_triggered,left_triggered,right_triggered};
    assign car_speed_output = {car_speed_input[15],left_speed,car_speed_input[7],right_speed};
endmodule
