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
#include "stdint.h"
#include <string.h>
#include "data_structure.h"
#include <stdio.h>
#include "timer.h"
/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

void sendData(UART_HandleTypeDef *huart, const char *str);
void InitTIMER();
  		  char message[100]; // 或者足够大的数组
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
  MX_USART2_UART_Init();
  /* USER CODE BEGIN 2 */
  sendData(&huart2,"hello_world\n");
  InitTIMER();

  /* USER CODE END 2 */
    //   for (int i = 0; i < 2000; i++) {
    //     sendData(&huart2,"timerRun\n");
    //     int* device_status = timerRun(2);  // 修正 timer 函数的调用
    //     sprintf(message,"现在日期是:%d年%d月%d日,%d点%d分%d秒:\n{", getTimerDate()->year, getTimerDate()->month, getTimerDate()->day, getTimerTime()->h, getTimerTime()->m, getTimerTime()->s);
    //     sendData(&huart2,message);
    //     for (int j = 0; j < 2; j++) {
    //         sprintf(message,"%d,", device_status[j]);
    //         sendData(&huart2,message);
    //     }
    //     sendData(&huart2,"}\n");
    //     HAL_Delay(500);
    // }
  
  /* Infinite loop */

        int *device_status = (int *)malloc(2 * sizeof(int));
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

      sprintf(message, "Current date: %d-%02d-%02d, %02d:%02d:%02d\n{", getTimerDate()->year, getTimerDate()->month, getTimerDate()->day, getTimerTime()->h, getTimerTime()->m, getTimerTime()->s);
      sendData(&huart2,message);
      
      int result=timerRun(2,device_status);
      for (int j = 0; j < 2; j++) {
            sprintf(message,"%d,", device_status[j]);
            sendData(&huart2,message);
        }
        sendData(&huart2,"}\n");
      HAL_Delay(1000);
    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}
void InitTIMER()
{
  sendData(&huart2, "InitTIMER\n");
  Date *date_ = newDate(2023, 6, 1);
  Time *time_ = newTime(12, 4, 30);
  // 创建一些测试计划
  Plan *plans_ = (Plan *)malloc(2 * sizeof(Plan));
Plan plan_1 = {1, 1, /* 时间 */ {12, 5, 0}, 10, {2023, 1, 1}, {2023, 12, 31}};
Plan plan_2 = {2, 2, /* 时间 */ {13, 5, 0}, 10, {2023, 6, 1}, {2023, 6, 30}};
sprintf(message, "Plan1: beginDate:%d-%d-%d,endDate:%d-%d-%d,time:%d:%d:%d\n{", plan_1.beginDate.year, plan_1.beginDate.month, plan_1.beginDate.day,plan_1.endDate.year, plan_1.endDate.month, plan_1.endDate.day ,plan_1.time.h, plan_1.time.m,plan_1.time.s);
sendData(&huart2,message);
sprintf(message, "Plan2: beginDate:%d-%d-%d,endDate:%d-%d-%d,time:%d:%d:%d\n{", plan_2.beginDate.year, plan_2.beginDate.month, plan_2.beginDate.day,plan_2.endDate.year, plan_2.endDate.month, plan_2.endDate.day ,plan_2.time.h, plan_2.time.m,plan_2.time.s);
sendData(&huart2,message);
  plans_[0] = plan_1;
  plans_[1] = plan_2;
  sendData(&huart2, "timerInit\n");
  timerInit(date_, time_, plans_);  // 传递计划的数量
  sendData(&huart2, "timerInit_ok\n");
}
void sendData(UART_HandleTypeDef *huart, const char *str)
{
  HAL_UART_Transmit(huart, (uint8_t *)str, strlen(str), HAL_MAX_DELAY);
  HAL_Delay(20);
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
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK |
                                RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2;
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

#ifdef USE_FULL_ASSERT
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
