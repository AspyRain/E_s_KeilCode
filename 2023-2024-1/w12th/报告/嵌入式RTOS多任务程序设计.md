﻿@[toc](目录)
# 一、 任务
1. 学习嵌入式实时操作系统（RTOS）,以uc/OS-III为例，将其移植到stm32F103上，构建至少3个任务（task）:其中两个task分别以1s和3s周期对LED等进行点亮-熄灭的控制；另外一个task以2s周期通过串口发送“hello uc/OS! 欢迎来到RTOS多任务环境！”。记录详细的移植过程。
2. RT-thread Nano的移植。
# 二、 过程
## 2.1 uc/OS-Ⅲ的移植与编程
### 2.1.1 准备工作
1. ucosiii下载
>下载地址
>百度网盘链接：
>链接：[https://pan.baidu.com/s/10RqsDRecbmVteWmDv2oUNQ](https://pan.baidu.com/s/10RqsDRecbmVteWmDv2oUNQ)
>提取码：1234

2. cubemx
3. mdk
4. stm32f103c8t6
5. usb转ttl模块
### 2.1.2 创建工程
#### ① 通过cubemx新建项目
1. 选择f103c8t6
![在这里插入图片描述](https://img-blog.csdnimg.cn/9e25a78baa21471797bee6473a2cf025.png)
2. 按照下图进行选择

![在这里插入图片描述](https://img-blog.csdnimg.cn/1159fec33fa44a7f8b350ee8cee87c6d.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/d226aa341d5a4e21bb4e18bda961d273.png)
选择pc13管脚作为点灯管脚
![在这里插入图片描述](https://img-blog.csdnimg.cn/a5fec77e9ed94a13a898917145de7160.png)

配置时钟
![在这里插入图片描述](https://img-blog.csdnimg.cn/45295e5950ca4207bc69178c45c57606.png)
在Project Manager里更改
![在这里插入图片描述](https://img-blog.csdnimg.cn/333fd0c862254e9aadad0fbd5c97203c.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/880a9a3659cb43ad845441da0320db58.png)
创建项目
#### ② 移植uciii
将下载好的uciii资源中的uc开头的文件复制到keil项目根目录的**MDK-ARM**文件夹内

![在这里插入图片描述](https://img-blog.csdnimg.cn/cb5ed6db1a534161a335e9d10ffa00ce.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/a431d42e431d46758d3682e38d15e7b5.png)

打开keil项目
点击品字按钮
![在这里插入图片描述](https://img-blog.csdnimg.cn/5a298b0c7f4542ed88c25ba7edcc860b.png)
添加以下六个组
![在这里插入图片描述](https://img-blog.csdnimg.cn/c0d2f7c5da594caeba18c39b5b41ff22.png)
分别点击Add Files添加文件(记得选择all files)
![在这里插入图片描述](https://img-blog.csdnimg.cn/669aadcf8786483793c1d49091009820.png)
参考表格添加
|组名| 文件所在位置|
|--|--|
| CPU | UCPU 注意还要额外添加一个：uC-CPU\ARM-Cortex-M3\RealView的文件 |
|LIB|UC-LIB 注意还有额外添加一个：uC-LIB\Ports\ARM-Cortex-M3\RealView的文件|
|PORT|uCOS-III\Ports\ARM-Cortex-M3\Generic\RealView|
|SOURCE|UCOS-III 这个和上面的不一样，是添加里面的一个source文件里面的.c .h文件|
|CONFIG|uC-CONFIG|
|BSP|UC-BSP|

点击魔法棒，在C/C++中点击按钮添加路径
![在这里插入图片描述](https://img-blog.csdnimg.cn/f93a2101a32547538257b366d0b9e0c5.png)
添加如下路径
![在这里插入图片描述](https://img-blog.csdnimg.cn/a6eb5f16a6d146159d9f7a602589bf35.png)

**更改文件内容**

分别添加BSP.h和BSP.c的文件内容：
BSP.h:
~~~c
#ifndef  __BSP_H__
#define  __BSP_H__

#include "stm32f1xx_hal.h"

void BSP_Init(void);

#endif

~~~
BSP.c:
~~~c
// bsp.c
#include "includes.h"

#define  DWT_CR      *(CPU_REG32 *)0xE0001000
#define  DWT_CYCCNT  *(CPU_REG32 *)0xE0001004
#define  DEM_CR      *(CPU_REG32 *)0xE000EDFC
#define  DBGMCU_CR   *(CPU_REG32 *)0xE0042004

#define  DEM_CR_TRCENA                   (1 << 24)
#define  DWT_CR_CYCCNTENA                (1 <<  0)

CPU_INT32U  BSP_CPU_ClkFreq (void)
{
    return HAL_RCC_GetHCLKFreq();
}

void BSP_Tick_Init(void)
{
	CPU_INT32U cpu_clk_freq;
	CPU_INT32U cnts;
	cpu_clk_freq = BSP_CPU_ClkFreq();
	
	#if(OS_VERSION>=3000u)
		cnts = cpu_clk_freq/(CPU_INT32U)OSCfg_TickRate_Hz;
	#else
		cnts = cpu_clk_freq/(CPU_INT32U)OS_TICKS_PER_SEC;
	#endif
	OS_CPU_SysTickInit(cnts);
}



void BSP_Init(void)
{
	BSP_Tick_Init();
	MX_GPIO_Init();
}


#if (CPU_CFG_TS_TMR_EN == DEF_ENABLED)
void  CPU_TS_TmrInit (void)
{
    CPU_INT32U  cpu_clk_freq_hz;


    DEM_CR         |= (CPU_INT32U)DEM_CR_TRCENA;                /* Enable Cortex-M3's DWT CYCCNT reg.                   */
    DWT_CYCCNT      = (CPU_INT32U)0u;
    DWT_CR         |= (CPU_INT32U)DWT_CR_CYCCNTENA;

    cpu_clk_freq_hz = BSP_CPU_ClkFreq();
    CPU_TS_TmrFreqSet(cpu_clk_freq_hz);
}
#endif


#if (CPU_CFG_TS_TMR_EN == DEF_ENABLED)
CPU_TS_TMR  CPU_TS_TmrRd (void)
{
    return ((CPU_TS_TMR)DWT_CYCCNT);
}
#endif


#if (CPU_CFG_TS_32_EN == DEF_ENABLED)
CPU_INT64U  CPU_TS32_to_uSec (CPU_TS32  ts_cnts)
{
	CPU_INT64U  ts_us;
  CPU_INT64U  fclk_freq;

 
  fclk_freq = BSP_CPU_ClkFreq();
  ts_us     = ts_cnts / (fclk_freq / DEF_TIME_NBR_uS_PER_SEC);

  return (ts_us);
}
#endif
 
 
#if (CPU_CFG_TS_64_EN == DEF_ENABLED)
CPU_INT64U  CPU_TS64_to_uSec (CPU_TS64  ts_cnts)
{
	CPU_INT64U  ts_us;
	CPU_INT64U  fclk_freq;


  fclk_freq = BSP_CPU_ClkFreq();
  ts_us     = ts_cnts / (fclk_freq / DEF_TIME_NBR_uS_PER_SEC);
	
  return (ts_us);
}
#endif

~~~
找到**startup_stm32f103xb.s**
![在这里插入图片描述](https://img-blog.csdnimg.cn/99b1dea113d846599fd07e9f695de3a7.png)
将74,75行的
**PendSVHandler**和**SysTickHandler**替换为**OS_CPU_PendSVHandler**和**OS_CPU_SysTickHandler**

![在这里插入图片描述](https://img-blog.csdnimg.cn/73dc20c9047f4f2f92c38948f6201041.png)
173行处
同样进行更改（注意**proc**之前的两个**handler**不要改）
![在这里插入图片描述](https://img-blog.csdnimg.cn/c3c23e47ac374f9fb94592fc19fc5e0a.png)
在227,228添加：
![在这里插入图片描述](https://img-blog.csdnimg.cn/0fda35ee58064096b86ef7517a87e30a.png)
在272附近添加
![在这里插入图片描述](https://img-blog.csdnimg.cn/6ac0e87ceba84f2babec243a484f9900.png)
找到**app_cfg.h**（在CONFIG组）
85行，替换为(void)
![在这里插入图片描述](https://img-blog.csdnimg.cn/d50953980e764a9bb707cee937495d82.png)
42行修改为：
![在这里插入图片描述](https://img-blog.csdnimg.cn/225fcd2f8d0e46f68d32e6a02f8e12d6.png)
找到**includes.h**
在#include <bsp.h>下面添加 #include “gpio.h” #include “app_cfg.h”
将#include <stm32f10x_lib.h> 改为 #include “stm32f1xx_hal.h”
![在这里插入图片描述](https://img-blog.csdnimg.cn/20dd4f991a8f4e888a443e688535bc9c.png)
打开**lib_cfg.h**（同样CONFIG组内）
![在这里插入图片描述](https://img-blog.csdnimg.cn/6b76c2ca77d24710ac80510884f61f4a.png)120行修改为5u
![在这里插入图片描述](https://img-blog.csdnimg.cn/3f45ca4e7aa345ca9128718de93edc2a.png)
打开魔法棒的target页面
修改为8000
![在这里插入图片描述](https://img-blog.csdnimg.cn/59d06f02a0974c31afecba3e2747a389.png)
#### ③ 编程
在usart.c里面添加重定向(记得include"stdio.h")
~~~c
/* USER CODE BEGIN 1 */

typedef struct __FILE FILE;
int fputc(int ch,FILE *f){
	HAL_UART_Transmit(&huart1,(uint8_t *)&ch,1,0xffff);
	return ch;
}

/* USER CODE END 1 */

~~~
在gpio.c里覆盖：
~~~c
void MX_GPIO_Init(void)
{

  GPIO_InitTypeDef GPIO_InitStruct = {0};

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOD_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_3, GPIO_PIN_RESET);


  /*Configure GPIO pin : PC13|PA3 */
  GPIO_InitStruct.Pin = GPIO_PIN_13|GPIO_PIN_3;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);
	HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

}

~~~
复制粘贴main.c的
~~~c
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "gpio.h"
#include "usart.h"
/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <includes.h>
#include "stm32f1xx_hal.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
/* 任务优先级 */
#define START_TASK_PRIO		3
#define LED0_TASK_PRIO		4
#define MSG_TASK_PRIO		5


/* 任务堆栈大小	*/
#define START_STK_SIZE 		96
#define LED0_STK_SIZE 		64
#define MSG_STK_SIZE 		64


/* 任务栈 */	
CPU_STK START_TASK_STK[START_STK_SIZE];
CPU_STK LED0_TASK_STK[LED0_STK_SIZE];
CPU_STK MSG_TASK_STK[MSG_STK_SIZE];


/* 任务控制块 */
OS_TCB StartTaskTCB;
OS_TCB Led0TaskTCB;
OS_TCB MsgTaskTCB;

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

/* 任务函数定义 */
void start_task(void *p_arg);
static  void  AppTaskCreate(void);
static  void  AppObjCreate(void);
static  void  led_pc13(void *p_arg);
static  void  send_msg(void *p_arg);

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /**Initializes the CPU, AHB and APB busses clocks 
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL9;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }
  /**Initializes the CPU, AHB and APB busses clocks 
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
	OS_ERR  err;
	OSInit(&err);
  HAL_Init();
	SystemClock_Config();
	//MX_GPIO_Init(); 这个在BSP的初始化里也会初始化
  MX_USART1_UART_Init();	
	/* 创建任务 */
	OSTaskCreate((OS_TCB     *)&StartTaskTCB,                /* Create the start task                                */
				 (CPU_CHAR   *)"start task",
				 (OS_TASK_PTR ) start_task,
				 (void       *) 0,
				 (OS_PRIO     ) START_TASK_PRIO,
				 (CPU_STK    *)&START_TASK_STK[0],
				 (CPU_STK_SIZE) START_STK_SIZE/10,
				 (CPU_STK_SIZE) START_STK_SIZE,
				 (OS_MSG_QTY  ) 0,
				 (OS_TICK     ) 0,
				 (void       *) 0,
				 (OS_OPT      )(OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
				 (OS_ERR     *)&err);
	/* 启动多任务系统，控制权交给uC/OS-III */
	OSStart(&err);            /* Start multitasking (i.e. give control to uC/OS-III). */
               
}


void start_task(void *p_arg)
{
	OS_ERR err;
	CPU_SR_ALLOC();
	p_arg = p_arg;
	
	/* YangJie add 2021.05.20*/
  BSP_Init();                                                   /* Initialize BSP functions */
  //CPU_Init();
  //Mem_Init();                                                 /* Initialize Memory Management Module */

#if OS_CFG_STAT_TASK_EN > 0u
   OSStatTaskCPUUsageInit(&err);  		//统计任务                
#endif
	
#ifdef CPU_CFG_INT_DIS_MEAS_EN			//如果使能了测量中断关闭时间
    CPU_IntDisMeasMaxCurReset();	
#endif

#if	OS_CFG_SCHED_ROUND_ROBIN_EN  		//当使用时间片轮转的时候
	 //使能时间片轮转调度功能,时间片长度为1个系统时钟节拍，既1*5=5ms
	OSSchedRoundRobinCfg(DEF_ENABLED,1,&err);  
#endif		
	
	OS_CRITICAL_ENTER();	//进入临界区
	/* 创建LED0任务 */
	OSTaskCreate((OS_TCB 	* )&Led0TaskTCB,		
				 (CPU_CHAR	* )"led_pc13", 		
                 (OS_TASK_PTR )led_pc13, 			
                 (void		* )0,					
                 (OS_PRIO	  )LED0_TASK_PRIO,     
                 (CPU_STK   * )&LED0_TASK_STK[0],	
                 (CPU_STK_SIZE)LED0_STK_SIZE/10,	
                 (CPU_STK_SIZE)LED0_STK_SIZE,		
                 (OS_MSG_QTY  )0,					
                 (OS_TICK	  )0,					
                 (void   	* )0,					
                 (OS_OPT      )OS_OPT_TASK_STK_CHK|OS_OPT_TASK_STK_CLR,
                 (OS_ERR 	* )&err);		

						 
				 
	/* 创建MSG任务 */
	OSTaskCreate((OS_TCB 	* )&MsgTaskTCB,		
				 (CPU_CHAR	* )"send_msg", 		
                 (OS_TASK_PTR )send_msg, 			
                 (void		* )0,					
                 (OS_PRIO	  )MSG_TASK_PRIO,     	
                 (CPU_STK   * )&MSG_TASK_STK[0],	
                 (CPU_STK_SIZE)MSG_STK_SIZE/10,	
                 (CPU_STK_SIZE)MSG_STK_SIZE,		
                 (OS_MSG_QTY  )0,					
                 (OS_TICK	  )0,					
                 (void   	* )0,				
                 (OS_OPT      )OS_OPT_TASK_STK_CHK|OS_OPT_TASK_STK_CLR, 
                 (OS_ERR 	* )&err);
				 
	OS_TaskSuspend((OS_TCB*)&StartTaskTCB,&err);		//挂起开始任务			 
	OS_CRITICAL_EXIT();	//进入临界区
}
/**
  * 函数功能: 启动任务函数体。
  * 输入参数: p_arg 是在创建该任务时传递的形参
  * 返 回 值: 无
  * 说    明：无
  */
static  void  led_pc13 (void *p_arg)
{
  OS_ERR      err;

  (void)p_arg;

  BSP_Init();                                                 /* Initialize BSP functions                             */
  CPU_Init();

  Mem_Init();                                                 /* Initialize Memory Management Module                  */

#if OS_CFG_STAT_TASK_EN > 0u
  OSStatTaskCPUUsageInit(&err);                               /* Compute CPU capacity with no task running            */
#endif

  CPU_IntDisMeasMaxCurReset();

  AppTaskCreate();                                            /* Create Application Tasks                             */

  AppObjCreate();                                             /* Create Application Objects                           */

  while (DEF_TRUE)
  {
		HAL_GPIO_WritePin(GPIOC,GPIO_PIN_13,GPIO_PIN_RESET);
		OSTimeDlyHMSM(0, 0, 1, 0,OS_OPT_TIME_HMSM_STRICT,&err);
		HAL_GPIO_WritePin(GPIOC,GPIO_PIN_13,GPIO_PIN_SET);
		OSTimeDlyHMSM(0, 0, 1, 0,OS_OPT_TIME_HMSM_STRICT,&err);
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}



static  void  send_msg (void *p_arg)
{
  OS_ERR      err;

  (void)p_arg;

  BSP_Init();                                                 /* Initialize BSP functions                             */
  CPU_Init();

  Mem_Init();                                                 /* Initialize Memory Management Module                  */

#if OS_CFG_STAT_TASK_EN > 0u
  OSStatTaskCPUUsageInit(&err);                               /* Compute CPU capacity with no task running            */
#endif

  CPU_IntDisMeasMaxCurReset();

  AppTaskCreate();                                            /* Create Application Tasks                             */

  AppObjCreate();                                             /* Create Application Objects                           */

  while (DEF_TRUE)
  {
		printf("hello uc/OS! 欢迎来到RTOS多任务环境！\r\n");
		OSTimeDlyHMSM(0, 0, 2, 0,OS_OPT_TIME_HMSM_STRICT,&err);
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}


/* USER CODE BEGIN 4 */
/**
  * 函数功能: 创建应用任务
  * 输入参数: p_arg 是在创建该任务时传递的形参
  * 返 回 值: 无
  * 说    明：无
  */
static  void  AppTaskCreate (void)
{
  
}


/**
  * 函数功能: uCOSIII内核对象创建
  * 输入参数: 无
  * 返 回 值: 无
  * 说    明：无
  */
static  void  AppObjCreate (void)
{

}

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */

  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{ 
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     tex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/

~~~
#### ④ 编译烧录
![在这里插入图片描述](https://img-blog.csdnimg.cn/e1da8093e6a04438abf9b8108524d7a5.gif)

## 2.2 RT-Thread的移植与编程（基于cubemx）
### 2.2.1 准备工作
1. cubemx和账号
2. stm32f103c8t6
3. mdk

### 2.2.2 移植
打开cubemx
点击
![在这里插入图片描述](https://img-blog.csdnimg.cn/c0248ed56ae24ccba3adaf9ad8396608.png)
点击From URL
![在这里插入图片描述](https://img-blog.csdnimg.cn/afbf88c2b5e842ee94f972d746072995.png)
输入网址:
https://www.rt-thread.org/download/cube/RealThread.RT-Thread.pdsc

![在这里插入图片描述](https://img-blog.csdnimg.cn/d6ebe76b2494483cabd1566d09dcac82.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/530814db93cc4ef88f9855310f403a1a.png)
点击下载
![在这里插入图片描述](https://img-blog.csdnimg.cn/bbca37bf88564bb8838b80cf81c07eb5.png)

下载完成之后
找到RealTHread选中3.1.5版本
![在这里插入图片描述](https://img-blog.csdnimg.cn/c33fc05c48464b8d94ea271827ce991d.png)
点击install安装
**注意，点击安装后如果没有登陆cubemx的账号则会提醒你登录，注册或者用现有账号登陆后就可以安装了**

然后就可以创建项目了

### 2.2.3 创建项目
![在这里插入图片描述](https://img-blog.csdnimg.cn/78c6b50d95254279be640ae28ef74e47.png)
点击设置组件
![在这里插入图片描述](https://img-blog.csdnimg.cn/3900ec7aaf6944b69f1ae0d0cc1ca6f5.png)
选择RT-thread的前两项
![在这里插入图片描述](https://img-blog.csdnimg.cn/274c920989ab4d5b9502e9369d393a77.png)勾选
![在这里插入图片描述](https://img-blog.csdnimg.cn/3b7be82581244231ba4cd5fe9fc147fb.png)


然后进行其余通用配置

![在这里插入图片描述](https://img-blog.csdnimg.cn/3c3a42c4d3cf4cc6acf7c34304d41092.png)
设置点灯的推挽输出管脚
![在这里插入图片描述](https://img-blog.csdnimg.cn/a2e3f0446a844ae3892a14e29f3eb03a.png)

设置串口通信
![在这里插入图片描述](https://img-blog.csdnimg.cn/18545f48de4d4377ae9909c0a43f5506.png)对中断进行配置，取消勾选所选中的三个，进行完这两部配置后说明原因。RT-Thread 操作系统重定义 HardFault_Handler、PendSV_Handler、SysTick_Handler 中断函数，为了避免重复定义的问题
![在这里插入图片描述](https://img-blog.csdnimg.cn/2f3f006d30ae4042b02017c6ca21d3cc.png)


![在这里插入图片描述](https://img-blog.csdnimg.cn/d0ad7ab1f1174802b2d9c86d26da4d97.png)

![在这里插入图片描述](https://img-blog.csdnimg.cn/24b72ff9a9bf49a9899cd5a70b7ce9ba.png)
选择版本
![在这里插入图片描述](https://img-blog.csdnimg.cn/e689cccfeecc4a0aa8a300ded6b89217.png)![在这里插入图片描述](https://img-blog.csdnimg.cn/f7baf0eb083a4355a995447afc44d4e1.png)
然后就可以点击Generate code创建项目了

### 2.2.4 MDK配置
1.宏定义配置
MDK进行最后的配置，主要是更改一下宏定义，对Shell进行配置，如果自己观察过的话，会发现cubemx里面并没有对Fish Shell进行相关的设置，这里需要添加一个头文件，**rtconfig.h**进行一些配置，以便使用shell。**rtconfig.h**在**RT-Rhread**的文件里面。

解释一下这个文件，对系统的裁剪也是在这个头文件里面进行裁剪的，通过对宏定义的修改，使用或者关闭相关功能。这里的修改和在cubemx修改的效果是一样的。

![在这里插入图片描述](https://img-blog.csdnimg.cn/de13bdead16149d7930058a69e736195.png)
返回值项目根目录，进入RT-Thread文件夹
![在这里插入图片描述](https://img-blog.csdnimg.cn/506d54f5d35f4163bdd9cab8b1e12386.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/581b186f35c647969c2955396941335d.png)
添加后进入该文件，在文件开头的6或7行添加：
~~~c
#define RT_USING_FINSH
~~~
![在这里插入图片描述](https://img-blog.csdnimg.cn/094535f9446d460886a39431919a2bf3.png)
2. 串口修改
在**board.c**里面的74行找到串口配置
默认为USART2,修改为当前使用的串口（USART1）
![在这里插入图片描述](https://img-blog.csdnimg.cn/14768bd0a0604fa1818ba6e20f9e285e.png)
在main.c里面添加头文件：
~~~c
#include <rtthread.h>
~~~
再添加任意一个rtthread的封装函数，这里添加延时函数:
~~~c
rt_thread_mdelay(1000);
~~~
然后编译一下，发现很多警告
![在这里插入图片描述](https://img-blog.csdnimg.cn/4f299251abfc41b0977328eabe5edc4d.png)
可以忽略掉，如果想要去掉警告：
再添加一个文件
![在这里插入图片描述](https://img-blog.csdnimg.cn/a08b30b049c648ae8fe53061824a7f7a.png)找到rtdef.h头文件的231行，屏蔽了，就OK了
头文件路径：当前cumemx生成文件下的Middlewares\Third_Party\RealThread_RTOS\include
![在这里插入图片描述](https://img-blog.csdnimg.cn/fcdffdde54254675af329dbf6057e21f.png)
注释掉231行：
![在这里插入图片描述](https://img-blog.csdnimg.cn/dccae12e7b174a86b3d4336ad04dac2b.png)
然后就不会警告了
![在这里插入图片描述](https://img-blog.csdnimg.cn/3340c4c00c5343ca947b656d9a7bcdda.png)
但是在实际使用过程中还会发生以下错误：
~~~c
Error: L6218E: Undefined symbol rt_thread_create (referred from main.o).
~~~
解决方法：
找到rtconfig.h内核配置文件 ——> #define RT_USING_HEAP
![在这里插入图片描述](https://img-blog.csdnimg.cn/48e64fccb0bf49f4be3db5000b4e14fe.png)

将注释去掉
即可编译成功
![在这里插入图片描述](https://img-blog.csdnimg.cn/47081d697f7743ad93ca5e0b91b1951a.png)
然后就可以写RT-thread下的代码了

### 2.2.5 编程
添加主函数：亮灯函数
在 /* USER CODE BEGIN 3 */里添加
~~~c
    HAL_GPIO_WritePin(GPIOC,GPIO_PIN_13,GPIO_PIN_RESET);
	rt_thread_mdelay(1000);
    HAL_GPIO_WritePin(GPIOC,GPIO_PIN_13,GPIO_PIN_SET);
~~~

创建线程：
在/* USER CODE BEGIN 2 */内添加:
~~~c
    /* 创建线程 */
    rt_thread_t usart_task_tid = rt_thread_create("send_data",/* 线程名称 */
                            send_data, RT_NULL,
                            1024, 3, 10); //
    if(usart_task_tid != RT_NULL)
    {
        /* 启动线程 */
        rt_thread_startup(usart_task_tid);
        rt_kprintf("usart thread is already started\n");
        
    }
    else
    {
        rt_kprintf("usart thread is not started\n");
    }
~~~
>解释：
>~~~c
>thread = rt_thread_create("send_data", //线程名称
>						  send_data, //线程函数
>						  RT_NULL, //输入参数，没有则填入RT_NULL作为空值
>						  1024, //分配堆栈大小
>						  3,    //线程的优先级 
>						  10);  //线程所分配的时间片 
>~~~
>当一个线程的优先级独一无二的时候，它的时间片这个参数将失去作用，我们不要认为上面的两个线程运行完 20 个系统 ticks 后就会主动交出 cpu 使用权，当运行完20 个 ticks 后如果它不需等待任何资源，也不主动让出 cpu使用权的话，它还会继续运行，时间片这个参数只在具有相同优先级的线程之间起作用，可是即便如此，这个参数也不能设为 0，因为你不知道后续是否还会创建线程。 

编辑线程函数：
在/* USER CODE BEGIN 0 */内添加
~~~c
void send_data(void *promt){
  while (1)
  {
    rt_thread_mdelay(1000);
    HAL_UART_Transmit(&huart1,(uint8_t*)"你好RT_thread!\r\n",rt_strlen("你好RT_thread!\r\n"),0xffff);
  }
}
~~~
注:HAL_UART_Transmit为HAL库的串口通信方法，也可以用RT-thread的串口通信方法：
~~~c
rt_kprintf("你好RT_thread!\r\n");
~~~
完整main.c的代码:
~~~c
/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2023 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "usart.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <rtthread.h>

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
void send_data(void *promt){

  while (1)
  {
    rt_thread_mdelay(1000);
    HAL_UART_Transmit(&huart1,(uint8_t*)"你好RT_thread!\r\n",rt_strlen("你好RT_thread!\r\n"),0xffff);
  }
 
}
/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_USART1_UART_Init();
  /* USER CODE BEGIN 2 */

    /* 创建线程 */
    rt_thread_t usart_task_tid = rt_thread_create("send_data",/* 线程名称 */
                            send_data, RT_NULL,
                            1024, 3, 10); //
    if(usart_task_tid != RT_NULL)
    {
        /* 启动线程 */
        rt_thread_startup(usart_task_tid);
        rt_kprintf("usart thread is already started\n");
        
    }
    else
    {
        rt_kprintf("usart thread is not started\n");
    }
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE BEGIN 3 */
    HAL_GPIO_WritePin(GPIOC,GPIO_PIN_13,GPIO_PIN_RESET);
		rt_thread_mdelay(1000);
    HAL_GPIO_WritePin(GPIOC,GPIO_PIN_13,GPIO_PIN_SET);
		rt_thread_mdelay(1000);
    /* USER CODE END 3 */
  }
	/* USER CODE END WHILE */
  
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_NONE;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_HSI;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */

~~~
### 2.2.6 编译烧录
光线原因，USB转TTL模块看上去没有亮，实际上每1秒都亮了一次
![在这里插入图片描述](https://img-blog.csdnimg.cn/1b438faadeaa406a98b57df414c23e08.gif)
# 三、 实验心得
在完成嵌入式实时操作系统（RTOS）移植任务的过程中，我深刻体会到了RTOS在提高系统实时性和多任务处理方面的重要性。选择uc/OS-III作为目标系统，并将其成功移植到stm32F103芯片上，构建了包括LED控制和串口通信在内的三个任务。

首先，移植过程中的挑战使我更深入地理解了RTOS的核心概念，如任务调度、同步与互斥等。通过配置任务的不同周期，我成功实现了对LED的定时控制和定时串口通信，体现了uc/OS-III强大的任务管理能力。

其次，通过这个实验，我更加熟悉了STM32系列的硬件平台和相关开发工具。在移植过程中，需要充分理解芯片的特性和寄存器配置，这提高了我对嵌入式系统底层的认识。

最后，在掌握uc/OS-III移植的基础上，进行了RT-thread Nano的移植，进一步加深了我对不同RTOS的理解和应用能力。整个过程不仅是技术的积累，更是对实时系统设计和开发的全面锻炼，使我对嵌入式领域有了更深的把握。这次经历让我更加自信地面对RTOS相关的项目，为将来在嵌入式领域的发展奠定了坚实基础。




参考链接:
1. [https://blog.csdn.net/qq_29618735/article/details/134541957](https://blog.csdn.net/qq_29618735/article/details/134541957)
2. [https://blog.csdn.net/weixin_46185705/article/details/122522318](https://blog.csdn.net/weixin_46185705/article/details/122522318)
3. [https://blog.csdn.net/qq_29618735/article/details/134541957](https://blog.csdn.net/qq_29618735/article/details/134541957)
4. [https://blog.csdn.net/suguolin/article/details/60770848](https://blog.csdn.net/suguolin/article/details/60770848)

