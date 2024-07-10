/******************************FILE HEAD**********************************
 * file_name         : Kalman.v
 * function          : 卡尔曼滤波器
 * author            : 今朝无言
 * date & version    : 2021/12/16 & v1.0
 *************************************************************************/
module kalman_filter(
input				rst_n,
input		[18:0]	data_in,
input				en,			//数据使能，上升沿有效
output	reg	[18:0]	data_out
);

// kalman滤波
// 流程:
// initial:
//   out=0;
//   P=0;
//   LastP=0;
//   Q=Q0;		//Q、R通过影响卡尔曼增益K=(Pk+Q)/(Pk+Q+R)的值，影响预测值和测量值的权重
//   R=R0;		//Q=inf(过程噪声过大) or R=0(没有观测噪声) 时，完全相信观测值，此时没有滤波效果
// end initial
// while 1:
//   %预测协方差方程：k时刻系统估算协方差 = k-1时刻的系统协方差 + 过程噪声协方差
//   P = LastP + Q;
//   %卡尔曼增益方程：卡尔曼增益 = k时刻系统估算协方差 / （k时刻系统估算协方差 + 观测噪声协方差）
//   Kg = P / (P + R);
//   %更新最优值方程：k时刻状态变量的最优值 = 状态变量的预测值 + 卡尔曼增益 * （测量值 - 状态变量的预测值）
//   out = out + Kg * (input(i) - out);%因为这一次的预测值就是上一次的输出值
//   %更新协方差方程: 本次的系统协方差赋给 kfp->LastP 为下一次运算准备。
//   LastP = (1 - Kg) * P;
//   output(i) = out;
// end while

parameter	Q	= 19'd6;		//参与计算的P,Q,R均为16-16定点数
parameter	R	= 19'd65;

reg	[18:0]	P		= 19'd0;
reg	[18:0]	LastP	= 19'd0;
reg	[15:0]	Kg		= 16'd0;	//Kg为0-16定点数
reg	[18:0]	LastOut	= 19'd0;

always @(posedge en or negedge rst_n) begin
	if(~rst_n)begin
		P		= 19'd0;
		LastP	= 19'd0;
		Kg		= 16'd0;
		LastOut	= 19'd0;
	end
	else begin
		P			= LastP + Q;	//用‘=’阻塞运算，以保证顺序执行
		Kg			= (P<<16) / (P + R);
		data_out	= (data_in>LastOut)?
					   LastOut + ((Kg * (data_in - LastOut))>>16):
					   LastOut - ((Kg * (LastOut - data_in))>>16);
		LastP		= ((16'd65535 - Kg) * P)>>16;
		LastOut		= data_out;
	end
end

endmodule
//END OF Kalman.v FILE***************************************************