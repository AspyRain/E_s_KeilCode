module speedGnrt (
    input                       clk              ,
    input                       rst_n           ,
    input       wire    [6:0]   bt_command      ,
    //bt_command:蓝牙指令
    //A_B[6:0]
    //A:指令类型:{0:控制速度,1:控制方向}
    //B:指令详情
    output              [3:0]    state_ctrl     ,
    output      wire    [15:0]   car_speed_output       //左右两轮的速度各7位+方向位各1位
);
    reg     [15:0]  car_speed           ;
    wire            command             ;
    reg    [3:0]   move                ;
    //定义行驶状态
    parameter   LEFT = 1            ,
                RIGHT = 2           ,
                FORWARD = 3         ,
                BACK = 4            ,
                LEFT_FORWARD =5     ,
                LEFT_BACK = 6       ,
                RIGHT_FORWARD = 7   ,
                RIGHT_BACK = 8      ,
                STOP = 0            ;

    
    reg [3:0]   state_c             ;
    reg [3:0]   state_n             ;
    reg [6:0]   base_speed          ;
    reg [6:0]   turning_speed       ;
    reg [6:0]   set_speed           ;
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            state_c <= STOP;
        end
        else begin
            state_c <= state_n;
        end
    end

//控制方向状态机
    always @(*) begin
        case (state_c)
            STOP    :begin
                    if      (move == LEFT)     state_n = LEFT;
                    else if (move == RIGHT)    state_n = RIGHT;
                    else if (move == FORWARD)  state_n = FORWARD;
                    else if (move == BACK)     state_n = BACK; 
                    else                       state_n = STOP;
            end
            LEFT    :begin
                    if      (move == FORWARD)    state_n = LEFT_FORWARD;
                    else if (move == BACK)      state_n = LEFT_BACK;
                    else if (move == LEFT+4)    state_n = STOP;
                    else if (move == STOP)      state_n = STOP;
                    else                        state_n = LEFT; 
            end
            RIGHT   :begin
                    if      (move == FORWARD)   state_n = RIGHT_FORWARD;
                    else if (move == BACK)      state_n = RIGHT_BACK;
                    else if (move == RIGHT+4)   state_n = STOP;
                    else if (move == STOP)      state_n = STOP;
                    else                        state_n = RIGHT; 
            end
            FORWARD :begin
                    if      (move == LEFT)      state_n = LEFT_FORWARD;
                    else if (move == RIGHT)     state_n = RIGHT_FORWARD;
                    else if (move == FORWARD+4) state_n = STOP;
                    else if (move == STOP)      state_n = STOP;
                    else                        state_n = FORWARD;
            end 
            BACK    :begin
                    if      (move == LEFT)      state_n = LEFT_BACK;
                    else if (move == RIGHT)      state_n = RIGHT_BACK;
                    else if (move == BACK+4)      state_n = STOP;
                    else if (move == STOP)      state_n = STOP;
                    else                        state_n = BACK;
            end 
            LEFT_FORWARD    :begin
                    if      (move == LEFT+4)    state_n = FORWARD;
                    else if (move == FORWARD+4)      state_n = LEFT;
                    else if (move == STOP)      state_n = STOP;
                    else                        state_n = LEFT_FORWARD; 
            end
            LEFT_BACK   :begin
                    if      (move == LEFT+4)     state_n = BACK;
                    else if (move == BACK+4)     state_n = LEFT;
                    else if (move == STOP)       state_n = STOP;
                    else                         state_n = LEFT_BACK; 
            end
            RIGHT_FORWARD :begin
                    if      (move == RIGHT+4)      state_n = FORWARD;
                    else if (move == FORWARD+4)    state_n = RIGHT;
                    else if (move == STOP)         state_n = STOP;
                    else                           state_n = RIGHT_FORWARD;
            end 
            RIGHT_BACK    :begin
                    if      (move == RIGHT+4)      state_n = BACK;
                    else if (move == BACK+4)      state_n = RIGHT;
                    else if (move == STOP)      state_n = STOP;
                    else                        state_n = RIGHT_BACK;
            end 
            
            default: 
                    state_n = state_c;
        endcase
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)begin
            car_speed <= 0;
        end
        else begin
            case (state_c)
                STOP:   begin
                    car_speed <= 16'b0;
                end 
                LEFT:   begin
                    car_speed <= {1'b0,base_speed,1'b1,base_speed};
                end
                RIGHT:  begin
                    car_speed <= {1'b1,base_speed,1'b0,base_speed};
                end
                FORWARD:begin
                    car_speed <= {1'b1,base_speed,1'b1,base_speed};
                end
                BACK:   begin
                    car_speed <= {1'b0,base_speed,1'b0,base_speed};
                end
                LEFT_FORWARD: begin
                    car_speed <= {1'b1,base_speed,1'b1,turning_speed};
                end
                LEFT_BACK:    begin
                    car_speed <= {1'b0,base_speed,1'b1,turning_speed};
                end
                RIGHT_FORWARD:begin
                    car_speed <= {1'b1,turning_speed,1'b1,base_speed};
                end
                RIGHT_BACK:   begin
                    car_speed <= {1'b0,turning_speed,1'b0,base_speed};
                end
                default: 
                    car_speed <= car_speed;
            endcase
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)begin
            base_speed <= 7'd40;
            turning_speed <= 7'd80;
            move  <= 4'b0;
        end
        else begin
            if (command == 1'b1)begin
                base_speed = {1'b0,bt_command[5:0]};
                turning_speed <= base_speed*2;
                move <= move;
            end
            else begin
                base_speed <= base_speed;
                move = bt_command[3:0];
            end
        end
    end
    

    assign command = bt_command[6];
    assign car_speed_output=car_speed;
    assign state_ctrl = state_c;

endmodule