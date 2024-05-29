@[TOC](这里写自定义目录标题)
# 本次任务
一.  了解并掌握STM32中断原理，HAL库函数开发方法。安装 stm32CubeMX，配合Keil，使用HAL库方式完成下列任务：

1、重做上一个LED流水灯作业，即用GPIO端口完成3只LED红绿灯的周期闪烁。

2、用stm32F103核心板的GPIOA端某一管脚接一个开关（用杜邦线模拟代替）。采用中断模式编程，当开关接高电平时，LED流水灯工作；

接低电平时，LED流水灯停止工作。



二. 在没有示波器条件下，可以使用Keil的软件仿真逻辑分析仪功能观察管脚的时序波形，更方便动态跟踪调试和定位代码故障点。

 请用此功能观察第1题中3个GPIO端口流水灯的输出波形，并分析时序状态正确与否，高低电平转换周期（LED闪烁周期）实际为多少。

# 一、 使用HAL库点亮流水灯
## 1.安装stm32cubeMX
### Ⅰ 安装java
>STM32CubeMX需要JDK支持，如果已经下载可以跳过此流程

下载地址： [https://www.java.com/zh_CN/download/windows-64bit.jsp](https://www.java.com/zh_CN/download/windows-64bit.jsp)（尽量安装最新版 64 位的Java）

点击同意并开始免费下载

![在这里插入图片描述](https://img-blog.csdnimg.cn/6ad8305ef34d4de6b05f913aa046a8b6.png)
###  Ⅱ、 CubeMX下载
>下载地址：
>[官网下载](https://www.st.com/content/st_com/en/stm32cubemx.html)

点击download:
![在这里插入图片描述](https://img-blog.csdnimg.cn/531ac05c23e245b18cc959896a71b19a.png)
选择版本，这里选择windows：
![在这里插入图片描述](https://img-blog.csdnimg.cn/3b77fee14c154d3196ebbd1e7fbd92a4.png)
点击ACCEPT接受:
![在这里插入图片描述](https://img-blog.csdnimg.cn/b02690b829834774986954390230cd58.png)
输入信息后即可下载（邮箱真实即可）
![在这里插入图片描述](https://img-blog.csdnimg.cn/d6eae2073e4a446bb276c632eb4c5dfc.png)
### Ⅲ、 CubeMX 安装
打开 SetupSTM32CubeMX-6.0.0.exe 文件，如果未安装 Java 环境，将会出现报错；
![在这里插入图片描述](https://img-blog.csdnimg.cn/5bd9bd5adc354d2fba1e69f0fa348653.png)

安装 Java 后，打开 SetupSTM32CubeMX-6.0.0.exe 文件，其他系统安装参考 Readme.html，点击 Next；
![在这里插入图片描述](https://img-blog.csdnimg.cn/c5565fef1948470b89da2a90702e8665.png)

勾选 I accpt，点击 Next；
![在这里插入图片描述](https://img-blog.csdnimg.cn/702d18f6733f48a9a4d695e696aa0a9d.png)

勾选第一个，点击 Next；
![在这里插入图片描述](https://img-blog.csdnimg.cn/8165f8dbc4804e60b235d3e214ac9d83.png)

（第二个勾选表示参加改善用户体验计划，即上传用户日志数据，若勾选安装后，可在软件 Help > User Preferences > General Settings 里取消）
选择合适的安装路径，点击 Next；（若路径未创建，会提示路径将被创建）
![在这里插入图片描述](https://img-blog.csdnimg.cn/6fa9c7e00f18425cb7dfc36a7c28fc55.png)

![在这里插入图片描述](https://img-blog.csdnimg.cn/3c050c9e7b4c40e08bcba75675780292.png)

根据需求勾选，点击 Next；
![在这里插入图片描述](https://img-blog.csdnimg.cn/5d8d6a175bd14ba8997864a7c8a76d42.png)

程序自动安装，安装完成后，点击 Next；

![在这里插入图片描述](https://img-blog.csdnimg.cn/4e170d2ba5b5446c938392e751de4e3c.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/a7a23708314940b7898eba4c62f985d3.png)

提示安装成功和一个卸载程序被创建在安装目录的 Uninstaller 文件夹中，点击 Done；
![在这里插入图片描述](https://img-blog.csdnimg.cn/1ab0013860d841baa1dccdfe839fc487.png)
配置：
点击图示
![在这里插入图片描述](https://img-blog.csdnimg.cn/62b1061814ca4cff9d4f71a242374b18.png)
联网状态下点击：
![在这里插入图片描述](https://img-blog.csdnimg.cn/bf1fe03940b248ef8650995ab7f03a51.png)
点击进入软件包管理
![在这里插入图片描述](https://img-blog.csdnimg.cn/abeec9b053824adc8defb590d585cc29.png)
选择F1型号进行下载
![在这里插入图片描述](https://img-blog.csdnimg.cn/c255aa1405d1444cabff21e7f4cd7a7a.png)

## 2. 创建项目
启动cubeMX
![在这里插入图片描述](https://img-blog.csdnimg.cn/a13fef73540e4960aaf10aa3ed613c89.png)
新建项目：

![在这里插入图片描述](https://img-blog.csdnimg.cn/55869daf5e3841ccbc064e1b4c82cb77.png)
选择芯片型号，这里选择F103C8T6，双击即可

![在这里插入图片描述](https://img-blog.csdnimg.cn/db12129f32fe42489dc4c74850907371.png)
在Pinout&Configiration界面单击要使能的GPIO管脚，并选择GPIO_Output（）设置为推挽输出![在这里插入图片描述](https://img-blog.csdnimg.cn/e5892c2e78914183a0734fb8f5c4e211.png)
在SYS栏中选择serial wire：
![在这里插入图片描述](https://img-blog.csdnimg.cn/4032f820a54443de9324bd8bbbe2f052.png)
在Project Manager里面填入创建项目的基本信息
注：IDE一定要选好，这里选择MDK_ARM
![在这里插入图片描述](https://img-blog.csdnimg.cn/f4bc40a44e0a40248d77c2575a51c2f0.png)
然后就可以点击GENERATE CODE创建项目了
创建完成之后可以点击Open Project从KEIL打开项目
![在这里插入图片描述](https://img-blog.csdnimg.cn/342e2e36560346219050980a95cc9d6c.png)
找到main.c的这个位置即可开始编程
![在这里插入图片描述](https://img-blog.csdnimg.cn/dd06295158114dcea1764394aee38158.png)
## 3. 写代码
将以下代码复制至main.c的main函数里的while循环里
~~~c
		//红灯亮
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_10, GPIO_PIN_SET);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_5, GPIO_PIN_RESET);
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_SET);
		HAL_Delay(1000);
		
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_10, GPIO_PIN_RESET);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_5, GPIO_PIN_SET);
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_SET);
		HAL_Delay(1000);
    
		
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_10, GPIO_PIN_RESET);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_5, GPIO_PIN_RESET);
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_RESET);
		HAL_Delay(1000);
~~~
>代码解释：
>~~~c
>HAL_GPIO_WritePin(GPIOA, GPIO_PIN_10, GPIO_PIN_SET);
>~~~
>这段函数将某管脚置零（GPIO_PIN_SET）或者置一（GPIO_PIN_RESET）
>前两个参数则是代表操作的管脚是GPIOA10



编译一下
![在这里插入图片描述](https://img-blog.csdnimg.cn/af51c0964afb451781700b8a79d8d156.png)
发现编译失败，报错为：
![在这里插入图片描述](https://img-blog.csdnimg.cn/266fcfd69b9d4079ab33398d82f26fe6.png)
原因是ARM Complier的版本选择错误
点击魔法棒，进入target栏，选择正确的版本：
![在这里插入图片描述](https://img-blog.csdnimg.cn/b94892f2520046d0a3ea70e259f690be.png)
再编译试试看
![在这里插入图片描述](https://img-blog.csdnimg.cn/bbc857693ea24e95aa4540e8e3349336.png)
将程序烧录进开发板中
## 4. 结果:
![在这里插入图片描述](https://img-blog.csdnimg.cn/1b9360fb17de491292e659bf3682844b.gif)
## 5. 通过keil仿真模拟器查看波形
如何打开逻辑分析仪可以参考：
[https://blog.csdn.net/lxr0106/article/details/134065777](https://blog.csdn.net/lxr0106/article/details/134065777)
选择管脚：
![在这里插入图片描述](https://img-blog.csdnimg.cn/195156dbcc9c42beab384322c11a38b0.png)
运行观察：
![在这里插入图片描述](https://img-blog.csdnimg.cn/145b750bed0644259738c74e2b7b65c3.png)
可以看到三个灯完成流水的周期已经非常接近1s了
# 二、 中断点亮LED灯
## 1. 新建项目
打开cubeMX，在原有的基础上，选择一个管脚（这里选择A8）用于触发中断，选择GPIO_EXIT8，然后再NVIC里面勾选该选项：
![在这里插入图片描述](https://img-blog.csdnimg.cn/f7876f66cacc4e72821216252e9352e6.png)
在GPIO栏里面找到中断管脚选择：
![在这里插入图片描述](https://img-blog.csdnimg.cn/a784d941cc8744a1a3c604c43f89d34a.png)
生成
找到stm32f1xx_it.c
![在这里插入图片描述](https://img-blog.csdnimg.cn/f6cde083e38e44c2b81660afac97c043.png)
往最下翻即可找到中断函数：
![在这里插入图片描述](https://img-blog.csdnimg.cn/512abc0bd4b7420f83c573dd9b472194.png)
先编译以下，然后找到该函数定义
![在这里插入图片描述](https://img-blog.csdnimg.cn/437cc056ebc64355828daf27c3760ad0.png)
一般选择重写这个callback函数来定义中断功能
![在这里插入图片描述](https://img-blog.csdnimg.cn/30ced102bc884a05bb1a6c315f1c7115.png)
## 2. 填写代码
进入main.c
>### ①编写全局变量:
>~~~c
>int flag=0; //led亮灭判断
>int HIGH_NUM=0; //PA8高电平次数
>int LIGHT_NUM=0; //PA8低电平次数
>~~~


>### ② 重写回调函数
>~~~c
>void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin){
>	HIGH_NUM+=1;
>	if (flag==0){
>	flag=1;
	>}
>}
>~~~
>该函数的功能为:
>高电平时，将flag置为1，点亮led
>累加PA8高电平次数

>### ③ 编写main函数中的循环函数
>~~~c
>if (flag==1){
>			int TEST_NUM=HIGH_NUM;
>			HAL_Delay(20);
>			if (TEST_NUM==HIGH_NUM){
>			flag=0;
>			HIGH_NUM=0;
>			LIGHT_NUM=0;
>			}
>		}
 >   /* USER CODE END WHILE */
  >  if (flag==1){
>		if (LIGHT_NUM%3==0){
>			      		//红灯亮
>		HAL_GPIO_WritePin(GPIOA, >GPIO_PIN_10, GPIO_PIN_SET);
>		HAL_GPIO_WritePin(GPIOB, >GPIO_PIN_5, GPIO_PIN_RESET);
>		HAL_GPIO_WritePin(GPIOC, >GPIO_PIN_13, GPIO_PIN_SET);
>		}
>
	>	else if (LIGHT_NUM%3==1){
		>			HAL_GPIO_WritePin(GPIOA, >GPIO_PIN_10, GPIO_PIN_RESET);
>		HAL_GPIO_WritePin(GPIOB, >GPIO_PIN_5, GPIO_PIN_SET);
>		HAL_GPIO_WritePin(GPIOC, >GPIO_PIN_13, GPIO_PIN_SET);
>		}
>		else if (LIGHT_NUM%3==2){
>					HAL_GPIO_WritePin(GPIOA, >GPIO_PIN_10, GPIO_PIN_RESET);
>		HAL_GPIO_WritePin(GPIOB, >GPIO_PIN_5, GPIO_PIN_RESET);
>		HAL_GPIO_WritePin(GPIOC, >GPIO_PIN_13, GPIO_PIN_RESET);
>		}
>		LIGHT_NUM+=1;
>		HAL_Delay(1000);
  >  }
>		else {
>		HAL_GPIO_WritePin(GPIOA, >GPIO_PIN_10, GPIO_PIN_RESET);
>		HAL_GPIO_WritePin(GPIOB, >GPIO_PIN_5, GPIO_PIN_RESET);
>		HAL_GPIO_WritePin(GPIOC, >GPIO_PIN_13, GPIO_PIN_SET);
>		}
>~~~
>函数逻辑为：
>Ⅰ 若flag=1，通过判断20ms之内高电平次数有无累加PA8来判断高电平是否结束，若高电平结束则重置所有参数，flag=0，熄灭所有灯
>Ⅱ 通过LIGHT_NUM判断该点亮哪一个灯

## 3. 编译运行
设计电路：
这里我有开关就直接连接开关，没有开关可以
![在这里插入图片描述](https://img-blog.csdnimg.cn/2e3ebe8d498f42cd8ebf171ce378fd29.png)![在这里插入图片描述](https://img-blog.csdnimg.cn/ab636da0f8dc4aff9073e94c9f641978.gif)


参考链接:[STM32CubeMX 下载及安装教程](https://blog.csdn.net/Brendon_Tan/article/details/107685563)
