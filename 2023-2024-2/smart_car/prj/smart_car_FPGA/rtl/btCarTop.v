module btCarTop (
    input                   rst_n       ,
    input                   clk         ,
    input                   uart_RXD    ,
    input       [12:00]		distance_data_f,
    input       [12:00]		distance_data_b,
    input       [12:00]		distance_data_l,
    input       [12:00]		distance_data_r,
    output                  uart_TXD    ,
    output                  beep        ,
    output      [7:0]       pwm        
);
    parameter   TIME_1MS = 5_000_000;
    wire        [15:0]      car_speed_output;
    wire        [6:0]       rx              ;
    wire        [7:0]       uart_Data       ;
    wire                    Rx_done;
    wire        [6:0]       bt_command      ;
    wire        [6:0]       left_one_one    ;
    wire        [6:0]       left_one_two    ;
    wire        [6:0]       left_two_one    ;
    wire        [6:0]       left_two_two    ;
    wire        [6:0]       right_one_one;
    wire        [6:0]       right_one_two;
    wire        [6:0]       right_two_one;
    wire        [6:0]       right_two_two;
    wire        [7:0]       close_flag      ;
    wire        [3:0]       state_ctrl      ;
    wire        [1:0]       front_beep      ;
    wire        [1:0]       back_beep       ;
    wire                    beep_f          ;
    wire                    beep_b          ;
	wire								clk_8hz;
    wire         [15:0]           car_speed_output_avi;

    // always @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         bt_command <= 7'b0; // Reset value
    //     end else if (Rx_done) begin
    //         bt_command <= uart_Data[6:0]; // Assign received data when Rx_done is high
    //     end
    // end
    assign bt_command = uart_Data[6:0];
    speedGnrt               inst_speedGnrt(
        .clk                (clk)               ,
        .rst_n              (rst_n)             ,
        .bt_command         (bt_command)        ,
        .state_ctrl         (state_ctrl)        ,
        .car_speed_output   (car_speed_output)  ,
    );
	ip_h8							inst_ip_h8(
		.c0						(clk_8hz),
		.inclk0			(clk)
	);
    sideWheelSpeedCtrl      left_sideWheelSpeedCtrl(
        .clk                (clk)                           ,
        .rst_n              (rst_n)                         ,
        .side_speed         (car_speed_output_avi[15:8])        ,
        .one_one            (left_one_one       )           ,
        .one_two            (left_one_two       )           ,
        .two_one            (left_two_one       )           ,
        .two_two            (left_two_two       )                            
    );

    sideWheelSpeedCtrl      right_sideWheelSpeedCtrl(
        .clk                (clk)                           ,
        .rst_n              (rst_n)                         ,
        .side_speed         (car_speed_output_avi[7:0])         ,
        .one_one            (right_one_one)                 ,
        .one_two            (right_one_two)                 ,
        .two_one            (right_two_one)                 ,
        .two_two            (right_two_two)                                  
    );

    uart_rx                 inst_uart_rx        (
        .clk                (clk)               ,
        .rst_n              (rst_n)             ,
        .rx                 (uart_RXD)          ,
        .po_data            (uart_Data)         ,
        .po_flag            (Rx_done)
    );

    pwmCtrl             left_front_wheel_1_pwm(
        .clk            (clk_8hz)                   ,
        .rst_n          (rst_n)                 ,
        .duty_percent   (left_one_one)    ,
        .pwm_out        (pwm[0])                
    );

    pwmCtrl             left_front_wheel_2_pwm(
        .clk            (clk_8hz)                   ,
        .rst_n          (rst_n)                 ,
        .duty_percent   (left_one_two)    ,
        .pwm_out        (pwm[1])                
    );
    
    pwmCtrl             left_behind_wheel_1_pwm(
        .clk            (clk_8hz)                   ,
        .rst_n          (rst_n)                 ,
        .duty_percent   (left_two_one)    ,
        .pwm_out        (pwm[2])                
    );
    
    pwmCtrl             left_behind_wheel_2_pwm(
        .clk            (clk_8hz)                   ,
        .rst_n          (rst_n)                 ,
        .duty_percent   (left_two_two)    ,
        .pwm_out        (pwm[3])                
    );
	 
	 
        pwmCtrl         right_front_wheel_1_pwm(
        .clk            (clk_8hz)                   ,
        .rst_n          (rst_n)                 ,
        .duty_percent   (right_one_one)    ,
        .pwm_out        (pwm[4])                
    );

    pwmCtrl             right_front_wheel_2_pwm(
        .clk            (clk_8hz)                   ,
        .rst_n          (rst_n)                 ,
        .duty_percent   (right_one_two)    ,
        .pwm_out        (pwm[5])                
    );
    
    pwmCtrl             right_behind_wheel_1_pwm(
        .clk            (clk_8hz)                   ,
        .rst_n          (rst_n)                 ,
        .duty_percent   (right_two_one)    ,
        .pwm_out        (pwm[6])                
    );
    
    pwmCtrl             right_behind_wheel_2_pwm(
        .clk            (clk_8hz)                   ,
        .rst_n          (rst_n)                 ,
        .duty_percent   (right_two_two)    ,
        .pwm_out        (pwm[7])                
    );

    avoid_control       inst_avoid_ctrl(
        .clk            (clk        ),
        .rst            (rst_n        ),
        .head_distance  (distance_data_f),
        .right_distance  (distance_data_r),
        .left_distance  (distance_data_l),
        .tail_distance  (distance_data_b),
        .state_ctrl         (state_ctrl)        ,
        .car_speed_input    (car_speed_output),
        .car_speed_output   (car_speed_output_avi),
        .front_triggered    (front_beep )       ,
        .back_triggered     (back_beep )        ,
        .close_flag         (close_flag         )
    );
    beepled front_beepled(
        .Clk        (clk),
        .Rst_n      (rst_n),
        .beep_flag     (front_beep),
        .beep       (beep_f)
    );

    beepled back_beepled(
        .Clk        (clk),
        .Rst_n      (rst_n),
        .beep_flag     (back_beep),
        .beep       (beep_b)
    );
    
    uart_tx             inst_uart_tx    (
        .clk            (clk        ),
        .rst_n          (rst_n      ),
        .din            (close_flag ),
        .din_vld        (end_cnt_1MS),
        .dout           (uart_TXD   )
    );

    reg         [23-1:0]      cnt_1MS    ; //计数器
    wire                    add_cnt_1MS; //开始计数
    wire                    end_cnt_1MS; //计数器最大值
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)begin
             cnt_1MS <= 23'b0;
        end
        else if (add_cnt_1MS)begin
            if (end_cnt_1MS)begin
                cnt_1MS<=23'b0;
            end
            else begin
                cnt_1MS <= cnt_1MS +1'd1;
            end
        end
        else begin
            cnt_1MS <= cnt_1MS;
        end
    end
    assign add_cnt_1MS = rst_n == 1'b1;
    assign end_cnt_1MS = add_cnt_1MS && (cnt_1MS==TIME_1MS - 1);


    assign beep = beep_b | beep_f;
endmodule