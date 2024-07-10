module top4bt_avi (
    input                   rst_n       ,
    input                   clk         ,
    input                   uart_RXD    ,
    input                   f_echo,
    input                   b_echo,
    input                   l_echo,
    input                   r_echo,


    output                  f_trig,
    output                  b_trig,
    output                  beep    ,
    output 	[6:0]	hex1	, // -共阳极，低电平有效
    output  [6:0]	hex2	, // -
    output  [6:0]	hex3	, // -
    output  [6:0]	hex4	, //连接符
    output  [6:0]	hex5	, //cm -
    output  [6:0]	hex6	, //cm -
    output  [6:0]	hex7	, //cm -
    output  [6:0]	hex8	,	  //熄

    output                  uart_TXD_BT    ,
    output                  uart_tx         ,
    output      [7:0]       pwm         
);
    wire                trig                    ;
    wire 				clk_us		            ;
    wire    [18:00]     b_data_o                  ;
    wire    [18:00]     f_data_o                  ;
    wire    [18:00]     filter_data_f           ;
    wire    [18:00]     filter_data_b           ;
    wire	[12:00]		distance_data_f		    ;
    wire	[12:00]		distance_data_b		    ;
    wire[7:0] uart_ctrl_data;
    wire [3:0] f_cm_ten;
    wire [3:0] f_cm_unit;
    wire [3:0] b_cm_ten;
    wire [3:0] b_cm_unit;
    wire        beep_f;
    wire        beep_b;
    timer #(.div_value(50_000_000)) TIMER0(
        .timeout(timer_1s),
        .clk(clk),
        .rst(~rst_n)
    );

    clk_div	u_clk_div(
        .clk		(clk	),
        .rstn		(rst_n	),
        .clk_us		(clk_us )
    );

    trig_driver	u_trig_driver(
        .clk_us		(clk_us	),
        .rstn		(rst_n	),
        .trig		(trig	)
    );

    echo_driver	f_echo_driver(
        .clk		(clk	),
        .clk_us		(clk_us	),
        .rstn		(rst_n	),
        .echo		(f_echo	),
        .data_o		(f_data_o	)
        );

    echo_driver	b_echo_driver(
        .clk		(clk	),
        .clk_us		(clk_us	),
        .rstn		(rst_n	),
        .echo		(b_echo	),
        .data_o		(b_data_o	)
        );


    kalman_filter   f_kalman_filter(
        .rst_n      (rst_n),
        .data_in    (f_data_o),
        .en         (clk),
        .data_out   (filter_data_f)
    );

    kalman_filter   b_kalman_filter(
        .rst_n      (rst_n),
        .data_in    (b_data_o),
        .en         (clk),
        .data_out   (filter_data_b)
    );



    btCarTop        inst_btCarTop(
        .rst_n              (rst_n),
        .clk                (clk  ),
        .uart_RXD           (uart_RXD),
        .distance_data_f    (distance_data_f),
        .distance_data_b    (distance_data_b),
        .uart_TXD           (uart_TXD_BT   ),
        .beep               (beep),
        .pwm                (pwm)
    );
    
    //串口发送驱动，需要给定时钟频率和波特率
    uart_const_baud_tx #(.clock_freq(50_000_000),.baud_rate(115200)) UART_TX0(
        .tx(uart_tx),  
        .tx_done(uart_tx_done),
        .tx_idle(uart_tx_idle),
        .tx_start(uart_start),
        .tx_data(uart_ctrl_data),
        .clk(clk),
        .rst(~rst_n)
    );
    
    //串口发送字符串模块，string_in端口输入要发送的内容
    //byte_num计算方法：每个中文文字占两位，每个英文字符占一位，回车换行（16'h0d0a）占两位。
    //如果是使用了压缩包内的文件，那么此时编码方式为utf-8，此时一个中文字符占三位
    //所以如果是quartus或者gaoyun等utf-8的编码EDA工具，byte_num应改为26
    uart_string_send #(.byte_num(16)) UART_SEND0(
        .uart_data(uart_ctrl_data),
        .uart_start(uart_start),
        .str_in({f_cm_ten+8'h30,f_cm_unit+8'h30,16'h0d0a,
                 b_cm_ten+8'h30,b_cm_unit+8'h30,16'h0d0a,
                 l_cm_ten+8'h30,l_cm_unit+8'h30,16'h0d0a,
                 r_cm_ten+8'h30,r_cm_unit+8'h30,16'h0d0a
}),
        .uart_tx_done(uart_tx_done),
        .uart_tx_idle(uart_tx_idle),
        .send_start(timer_1s),
        .clk(clk),
        .rst(~rst_n)
        );
     transe finst_transe(
	    .clk		(clk	),  //50MHz
	    .rst_n	    (rst_n	),  //low valid
	    .data_in	(filter_data_f), //待显示数据
	    .cm_ten	    (f_cm_ten	),//10cm
	    .cm_unit    (f_cm_unit)	//1cm
	);
     transe binst_transe(
	    .clk		(clk	),  //50MHz
	    .rst_n	    (rst_n	),  //low valid
	    .data_in	(filter_data_f), //待显示数据
	    .cm_ten	    (b_cm_ten	),//10cm
	    .cm_unit    (b_cm_unit)	//1cm
	);
     transe linst_transe(
	    .clk		(clk	),  //50MHz
	    .rst_n	    (rst_n	),  //low valid
	    .data_in	(filter_data_f), //待显示数据
	    .cm_ten	    (l_cm_ten	),//10cm
	    .cm_unit    (l_cm_unit)	//1cm
	);
     transe rinst_transe(
	    .clk		(clk	),  //50MHz
	    .rst_n	    (rst_n	),  //low valid
	    .data_in	(filter_data_f), //待显示数据
	    .cm_ten	    (r_cm_ten	),//10cm
	    .cm_unit    (r_cm_unit)	//1cm
     );

    seg_driver u_seg_driver(
        .clk		(clk	),
        .rst_n		(rst_n	    ),
        .data_in	(filter_data_f	), //待显示数据
        .hex1		(hex1	    ), // -共阳极，低电平有效
        .hex2		(hex2	    ), // -
        .hex3		(hex3	    ), // -
        .hex4		(hex4	    ), //连接符
        .hex5		(hex5	    ), //cm - 
        .hex6		(hex6	    ), //cm - 
        .hex7		(hex7	    ), //cm - 
        .hex8		(hex8	    )  //熄灭
    );


    // filter          inst_filter(
    //     .rst_n        (rst_n),
    //     .clk           (clk),
    //     .pulse_num      (data_o),
    //     .filter_num     (data_f)
    // );
    assign f_trig = trig;
    assign b_trig = trig;
    assign distance_data_f=filter_data_f/100;
    assign distance_data_b=filter_data_b/100;
endmodule