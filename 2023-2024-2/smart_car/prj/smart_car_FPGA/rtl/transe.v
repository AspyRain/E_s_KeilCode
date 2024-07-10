module transe(
		input	wire		clk		,  //50MHz
		input	wire		rst_n	,  //low valid
	
		input	wire 	[18:0]	data_in	, //待显示数据
		output	reg		[3:0]	cm_hund	,//100cm
		output	reg		[3:0]	cm_ten	,//10cm
		output	reg		[3:0]	cm_unit	,//1cm
		output	reg		[3:0]	point_1	,//1mm
		output	reg		[3:0]	point_2	,//0.1mm
		output	reg		[3:0]	point_3	//0.01mm
	);

	 	//reg 、wire define
	
		always @(posedge clk or negedge rst_n)begin
			if(!rst_n)begin  
				cm_hund	<= 'd0;
				cm_ten	<= 'd0;
				cm_unit	<= 'd0;
				point_1	<= 'd0;
				point_2	<= 'd0;
				point_3	<= 'd0;
			end
			else begin
				cm_hund <= data_in / 10 ** 5;
				cm_ten	<= data_in / 10 ** 4 % 10;
				cm_unit <= data_in / 10 ** 3 % 10;
				point_1 <= data_in / 10 ** 2 % 10;
				point_2 <= data_in / 10 ** 1 % 10;
				point_3 <= data_in / 10 ** 0 % 10;
			end
		end
	

	endmodule