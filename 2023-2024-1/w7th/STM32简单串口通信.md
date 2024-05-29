@[toc]


>**内容简述**
>一. 了解串口协议和RS-232标准，以及RS232电平与TTL电平的区别；了解"USB/TTL转232"模块（以CH340芯片模块为例）的工作原理。
>
>二. 安装 stm32CubeMX，配合Keil，使用HAL库（或标准库）方式，设置USART1 波特率为115200，1位停止位，无校验位，完成下列任务：
>
>1）STM32系统给上位机（win10）连续发送“hello windows！”。win10采用“串口助手”工具接收。
>
>2）在完成以上任务基础，继续扩展功能：当上位机给stm32发送一个字符“#”后，stm32暂停发送“hello windows！”；发送一个字符“*”后，stm32继续发送；
# 一、 串口协议
## 1. 什么是串口通信
1、串口通信属于基层基本性的通信规约，收发双方事先规定好通信参数。
2、它自己本身不会去协商通信参数，需要通信前通信双方事先约定好通信参数来进行通信。
3、因此，若是收发方的任何一个关键参数设置错误，都会导致通信失败。譬如波特率调错了，发送方发送没问题，接收方也能接收，但是接收到全是乱码。
4、信息以二进制流的方式在信道上传输，串口通信的发送方每隔一定时间（时间固定为1/波特率，单位是秒）将有效信息（1或者0）放到通信线上去，逐个二进制位的进行发送。
5、接收方通过定时（起始时间由读到起始位标志开始，间隔时间由波特率决定）读取通信线上的电平高低来区分发送给我的是1还是0。依次读取数据位、奇偶校验位、停止位，停止位就表示这一个通信单元（帧）结束，然后中间是不定长短的非通信时间（发送方有可能紧接着就发送第二帧，也可能半天都不发第二帧，这就叫异步通信），下来就是第二帧·····
6、通过串口不管发数字、还是文本还是命令还是什么，都要先对发送内容进行编码，编码成二进制再进行逐个位的发送。
7、串口发送的一般都是字符，一般都是ASCII码编码后的字符，所以一般设置数据位都是8，方便刚好一帧发送1个字符。

## 2. 串口协议
 串口通信指两个或两个以上的设备使用串口按位（bit）发送和接收字节。可以在使用一根线发送数据的同时用另一根线接收数据。 串口通信协议就是串口通讯时共同遵循的协议。 协议的内容是每一个bit 所代表的意义。 常用的串口通信协议 有以下几种
1         RS-232（ANSI/EIA-232标准） 只支持 点对点， 最大距离 50英尺。最大速度为128000bit/s， 距离越远 速度越慢。 支持全双工（发送同时也可接收）。
2         RS-422（EIA RS-422-AStandard），支持点对多一条平衡总线上连接最多10个接收器 将传输速率提高到10Mbps，传输距离延长到4000英尺（约1219米），所以在100kbps速率以内，传输距离最大。支持全双工（发送同时也可接收）。
3         RS-485（EIA-485标准）是RS-422的改进， 支持多对多（2线连接），从10个增加到32个，可以用超过4000英尺的线进行串行通行。速率最大10Mbps。支持全双工（发送同时也可接收）。2线连接时 是半双工状态。

## 3. RS-232
RS-232标准接口（又称EIA RS-232）是常用的串行通信接口标准之一，它是由美国电子工业协会(EIA)联合贝尔系统公司、调制解调厂家及计算机终端生产厂家于1970年共同制定，其全名是“数据终端设备( DTE)和数据通信设备(DCE)之间串行二进制数据交换接口技术标准”。

# 二、串口实验
## 1. 发送hello windows！
### Ⅰ 创建工程
在cubemx内新建项目，选择对应芯片，这里我选择c8t6
![在这里插入图片描述](https://img-blog.csdnimg.cn/4ead60d69a7441edbb3854ccda606944.png)
然后根据下图进行选择：
![在这里插入图片描述](https://img-blog.csdnimg.cn/790f00000472445cbb1119a45a3691b9.png)![在这里插入图片描述](https://img-blog.csdnimg.cn/17e07b1825d74a4ca28ea22f72040c9b.png)![在这里插入图片描述](https://img-blog.csdnimg.cn/36aed3a32234464e8fd9ac83ac7f4500.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/9353c93ae3124888908d527e1b85d705.png)
编辑好项目配置
![在这里插入图片描述](https://img-blog.csdnimg.cn/ce22d423933b4e83b944ecca4da92dbc.png)
### Ⅱ 编程
创建全局变量:
~~~c
char message[]="hello Windows!\n";//输出信息
~~~
在main函数的while语句块中写入
~~~C
		HAL_UART_Transmit(&huart1, (uint8_t *)&message, strlen(message), 0xFFFF);
		HAL_Delay(1000);
~~~
### Ⅲ 打开串口助手查看:
![在这里插入图片描述](https://img-blog.csdnimg.cn/293a6b6e1aae4c65941b0bb99cfe2820.gif)
## 2. 中断发送hello windows
创建工程与上述一样,只需要修改main.c的代码：
### Ⅰ 编程
#### ① 在/* USER CODE BEGIN PM */中添加变量定义
flag有d和u两个值，代表关闭和开启
~~~c
char c;//指令 #:停止  *:开始
char message[]="hello Windows\n";//输出信息
char tips[]="CommandError\n";//提示1
char tips1[]="Start.....\n";//提示2
char tips2[]="Stop......\n";//提示3
char flag='d';
~~~
#### ② 在  /* USER CODE BEGIN 2 */中添加
接收数据的中断
~~~c
HAL_UART_Receive_IT(&huart1, (uint8_t *)&c, 1);
~~~
#### ③ 在main的while循环中添加:
~~~c
if(flag=='u'){
			//发送信息
			HAL_UART_Transmit(&huart1, (uint8_t *)&message, strlen(message),0xFFFF); 
			
			//延时
			HAL_Delay(1000);
		}
HAL_Delay(1000);//一定要加
~~~
#### ④ 在/* USER CODE BEGIN 4 */中添加
中断回调函数重写:
~~~c
void toggle_flag(char now_flag){
	flag=now_flag;
}
void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)
{
	
	//当输入的指令为#时,发送提示并改变flag
	if(c=='#'){
		toggle_flag('d');
		HAL_UART_Transmit(&huart1, (uint8_t *)&tips2, strlen(tips2),0xFFFF); 
	}
	
	//当输入的指令为*时,发送提示并改变flag
	else if(c=='*'){
		toggle_flag('u');
		HAL_UART_Transmit(&huart1, (uint8_t *)&tips1, strlen(tips1),0xFFFF); 
	}
	
	//当输入不存在指令时,发送提示并改变flag
	else {
		toggle_flag('d');
		HAL_UART_Transmit(&huart1, (uint8_t *)&tips, strlen(tips),0xFFFF); 
	}

	//重新设置中断
		HAL_UART_Receive_IT(&huart1, (uint8_t *)&c, 1);  
}
~~~
### Ⅱ 结果
![在这里插入图片描述](https://img-blog.csdnimg.cn/22d37eeb962c44a3a17c7dc982080bd9.gif)
### Ⅲ 查看波特率
逻辑分析仪配置请查看
![在这里插入图片描述](https://img-blog.csdnimg.cn/b4c7213fac214887b6ba99c34ad0db60.png)
如何查看波特率？
如图：
![在这里插入图片描述](https://img-blog.csdnimg.cn/8851f023348946da939dcb9c46fa890c.gif)


![在这里插入图片描述](https://img-blog.csdnimg.cn/02219fc92dce4992a7286410d7f05995.png
参考链接:
[https://blog.csdn.net/weixin_46089486/article/details/108992022](https://blog.csdn.net/weixin_46089486/article/details/108992022)
[https://blog.csdn.net/afadgfansfa/article/details/120956561](https://blog.csdn.net/afadgfansfa/article/details/120956561)