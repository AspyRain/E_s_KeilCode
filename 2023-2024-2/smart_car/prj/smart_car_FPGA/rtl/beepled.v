
module beepled (
    input   wire        Clk,
    input   wire        Rst_n,
	input	[1:0]		beep_flag,
    output  wire        beep
);

parameter	MAX1S	=	26'd2500_0000	;
parameter	MAX1_2S	=	26'd1250_0000	;
parameter	Time_100ms	=22'd12_500_000	;
reg [25:0]	cnt1s						;
reg [25:0]  cnt1_2s                     ;
reg         beep_r                      ;

reg		[21:0]	cnt1		;
wire			add_cnt1 ;
wire			end_cnt1 ;
	

//1s计数器
always @(posedge Clk or negedge Rst_n) begin
	if (!Rst_n) begin
		cnt1s <= 26'd0;						//复位，重新计数
	end
	else if (cnt1s == MAX1S - 1'd1) begin
		cnt1s <= 26'd0;						//记到最大数4999_9999后复位
	end
	else begin
		cnt1s <= cnt1s + 1'd1;				//其他情况+1
	end
end

//0.5s计数器
always @(posedge Clk or negedge Rst_n) begin
	if (!Rst_n) begin
		cnt1_2s <= 26'd0;						//复位，重新计数
	end
	else if (cnt1s == MAX1_2S - 1'd1) begin
		cnt1_2s <= 26'd0;						//记到最大数2499_9999后复位
	end
	else begin
		cnt1_2s <= cnt1_2s + 1'd1;				//其他情况+1
	end
end




//蜂鸣器

always@(posedge Clk or negedge Rst_n)begin
	if(!Rst_n)begin//复位信号
		beep_r <= 1'b0;//蜂鸣器默认设置为0
	end
	else if (beep_flag == 2'b00)begin
		beep_r <= 1'b0;
	end
	else if (beep_flag == 2'b01 || beep_flag == 2'b10)begin
		if (cnt1s == MAX1S - 1'd1)begin
			beep_r <= ~beep_r;
		end
		else if (beep_flag == 2'b10 && cnt1s == MAX1_2S - 1'd1)begin
			beep_r <= ~beep_r;
		end
		else begin
			beep_r <= beep_r;
		end
	end
	else begin 
		beep_r <= 1'b0;//否则不变 
    end
end


assign beep = beep_r;

endmodule