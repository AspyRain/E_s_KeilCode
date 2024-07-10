module sideWheelSpeedCtrl (
    input                   clk             ,
    input                   rst_n           ,
    input       [7:0]       side_speed      ,
    output                  dir_out         ,
    output      [6:0]       one_one       ,
    output      [6:0]       one_two       ,
    output      [6:0]       two_one       ,
    output      [6:0]       two_two              
);
    wire                      dir             ;//转向
    wire        [27:0]        wheel_speed     ;//车轮速度


	 assign dir = side_speed[7];
    assign wheel_speed = (dir == 1'b0)?{side_speed[6:0],7'b0,side_speed[6:0],7'b0}:{7'b0,side_speed[6:0],7'b0,side_speed[6:0]};
    assign one_one = wheel_speed[27:21];
    assign one_two = wheel_speed[20:14];
    assign two_one = wheel_speed[13:7];
    assign two_two = wheel_speed[6:0];
    assign dir_out = dir;
    
endmodule