/* USER CODE BEGIN Header */
/**
 ******************************************************************************
 * @file           : main.c
 * @brief          : Main program body
 ******************************************************************************
 * @attention
 *
 * Copyright (c) 2024 STMicroelectronics.
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
#include "tim.h"
#include "usart.h"
#include "gpio.h"
/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <stdio.h>
#include <rtthread.h>
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
int SLOW_SPEED = 0.3 * 65536; // 100%?
int BASE_SPEED = 65536*0.35;
int STEERING_SPEED = 65536*0.8;

int now_mode = 0;
uint8_t c;                      //?? #:??  *:??
char forward[] = "Forward\n";   //????
char stop[] = "stop\n";         //????
char tips[] = "CommandError\n"; //??1
int stop_flag = 1;
int route_flags[4] = {0, 0, 0, 0};
int low_speed_flag = 0;

const int FORWARD = 1;
const int BACK = 2;
const int LEFT = 3;
const int RIGHT = 4;
const int LEFT_FORWARD =5;
const int LEFT_BACK = 6;
const int RIGHT_FORWARD = 7;
const int RIGHT_BACK = 8;
const int STOP = -1;
int state = -1;
int left_wheel_speed = 0;
int right_wheel_speed = 0;
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
  MX_TIM2_Init();
  MX_TIM3_Init();
  MX_USART1_UART_Init();
  MX_USART2_UART_Init();
  /* USER CODE BEGIN 2 */
  HAL_GPIO_WritePin(enable_L_GPIO_Port, enable_L_Pin, GPIO_PIN_SET);
  HAL_GPIO_WritePin(enable_R_GPIO_Port, enable_R_Pin, GPIO_PIN_SET);
  HAL_TIM_PWM_Start(&htim2, TIM_CHANNEL_1);
  HAL_TIM_PWM_Start(&htim2, TIM_CHANNEL_2);
  HAL_TIM_PWM_Start(&htim2, TIM_CHANNEL_3);
  HAL_TIM_PWM_Start(&htim2, TIM_CHANNEL_4);
  HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_1);
  HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_2);
  HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_3);
  HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_4);
  HAL_UART_Receive_IT(&huart1, &c, 1);

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */
    rt_thread_mdelay(1000);
    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
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
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2;
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
void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)
{
  if (huart == &huart1)
  {
    rt_kprintf("%c\n", c);
    int receivedInt = c - '0';
    rt_kprintf("%d\n", receivedInt);
    speedController(receivedInt);
    HAL_UART_Receive_IT(&huart1, &c, 1);
  }
}
// void testReceive(int actionId)
// {
//   char speed_message[64]; // 假设足够长以存放格式化后的信息
//   switch (actionId)
//   {
//   case 8:
//   {
//     // 取消后退
//     state = STOP;
//     left_wheel_speed = left_wheel_speed - BASE_SPEED;
//     right_wheel_speed = right_wheel_speed - BASE_SPEED;
//     rt_kprintf("车辆停止\n");
//     break;
//   }
//   case 7:
//   {
//     // 取消前进
//     state = STOP;
//     left_wheel_speed = left_wheel_speed - BASE_SPEED;
//     right_wheel_speed = right_wheel_speed - BASE_SPEED;
//     rt_kprintf("车辆停止\n");
//     break;
//   }
//   case 6:
//   {
//     // 取消右拐
//     left_wheel_speed = left_wheel_speed - TURNING_SPEED;
//     rt_kprintf("车辆停止右拐\n");
//     break;
//   }
//   case 5:
//   {
//     // 取消左拐
//     right_wheel_speed = right_wheel_speed - TURNING_SPEED;
//     rt_kprintf("车辆停止左拐\n");
//     break;
//   }
//   case 0:
//   {
//     // 停车
//     left_wheel_speed = 0;
//     right_wheel_speed = 0;
//     rt_kprintf("车辆停止\n");
//     state = STOP;
//     break;
//   }
//   case 1:
//   {
//     // 车辆左拐
//     right_wheel_speed = right_wheel_speed + TURNING_SPEED;
//     rt_kprintf("车辆左拐\n");
//     break;
//   }
//   case 2:
//   {
//     // 车辆右拐
//     left_wheel_speed = left_wheel_speed + TURNING_SPEED;
//     rt_kprintf("车辆右拐\n");
//     break;
//   }
//   case 3:
//   {
//     // 车辆前进
//     state = FORWARD;
//     left_wheel_speed = left_wheel_speed + BASE_SPEED;
//     right_wheel_speed = right_wheel_speed + BASE_SPEED;
//     rt_kprintf("车辆前进\n");
//     break;
//   }
//   case 4:
//   {
//     // 车辆后退
//     state = BACK;
//     left_wheel_speed = left_wheel_speed + BASE_SPEED;
//     right_wheel_speed = right_wheel_speed + BASE_SPEED;
//     rt_kprintf("车辆后退\n");
//     break;
//   }
//   }
//   snprintf(speed_message, sizeof(speed_message), "左轮速度：%d 右轮速度：%d\n", left_wheel_speed, right_wheel_speed);

//   rt_kprintf(speed_message);
// }
void speedController(int actionId)
{
  char speed_message[64]; // 假设足够长以存放格式化后的信息
  //车辆运行状态机
  switch (actionId)
  {
  case 8:
  {
    // 取消后退
    if (state == LEFT_BACK){
			state = LEFT;
		}else if (state == RIGHT_BACK){
			state = RIGHT;
		}else {
			state = STOP;
		}
    rt_kprintf("车辆停止\n");
    break;
  }
  case 7:
  {
    // 取消前进
    if (state == LEFT_FORWARD){
			state = LEFT;
		}else if (state == RIGHT_FORWARD){
			state = RIGHT;
		}else {
			state = STOP;
		}
    rt_kprintf("车辆停止\n");
    break;
  }
  case 6:
  {
    // 取消右拐
    if (state == RIGHT_FORWARD){
			state = FORWARD;
		}else if (state == RIGHT_BACK){
			state = BACK;
		}else {
			state = STOP;
		}
    rt_kprintf("车辆停止右拐\n");
    break;
  }
  case 5:
  {
    // 取消左拐
		if (state == LEFT_FORWARD){
			state = FORWARD;
		}else if (state == LEFT_BACK){
			state = BACK;
		}else {
			state = STOP;
		}
    rt_kprintf("车辆停止左拐\n");
    break;
  }
  case 0:
  {
    // 停车
    left_wheel_speed = 0;
    right_wheel_speed = 0;
    rt_kprintf("车辆停止\n");
    state = STOP;
    break;
  }
  case 1:
  {
    // 车辆左拐
		if (state == FORWARD){
			state = LEFT_FORWARD;
		}else if (state == BACK){
			state = LEFT_BACK;
		}else {
			state = LEFT;
		}
    rt_kprintf("车辆左拐\n");
    break;
  }
  case 2:
  {
    // 车辆右拐
		if (state == FORWARD){
			state = RIGHT_FORWARD;
		}else if (state == BACK){
			state = RIGHT_BACK;
		}else {
			state = RIGHT;
		}
    rt_kprintf("车辆右拐\n");
    break;
  }
  case 3:
  {
    // 车辆前进
    if (state == LEFT){
      state = LEFT_FORWARD;
    }
    else if (state == RIGHT){
      state = RIGHT_FORWARD;
    }
    else {
      state = FORWARD;
    }
    rt_kprintf("车辆前进\n");
    break;
  }
  case 4:
  {
    // 车辆后退
    if (state == LEFT){
      state = LEFT_BACK;
    }
    else if (state == RIGHT){
      state = RIGHT_BACK;
    }
    else {
      state = BACK;
    }
    rt_kprintf("车辆后退\n");
    break;
  }
  }
  rt_kprintf("状态：%d\n",state);
  //处理状态
  switch (state)
  {
    case FORWARD:{
      set_speed(1,BASE_SPEED,1);
      set_speed(2,BASE_SPEED,1);
      set_speed(3,BASE_SPEED,1);
      set_speed(4,BASE_SPEED,1);
      rt_kprintf("车辆前进\n");
      break;
    }
    case LEFT:{
      set_speed(1,BASE_SPEED,1);
      set_speed(2,BASE_SPEED,1);
      set_speed(3,BASE_SPEED,0);
      set_speed(4,BASE_SPEED,0);
      rt_kprintf("车辆左转\n");
      break;
    }
    case BACK:{
      set_speed(1,BASE_SPEED,0);
      set_speed(2,BASE_SPEED,0);
      set_speed(3,BASE_SPEED,0);
      set_speed(4,BASE_SPEED,0);
      rt_kprintf("车辆后退\n");
      break;
    }
    case RIGHT:{
      set_speed(1,BASE_SPEED,0);
      set_speed(2,BASE_SPEED,0);
      set_speed(3,BASE_SPEED,1);
      set_speed(4,BASE_SPEED,1);
      rt_kprintf("车辆右转\n");
      break;
    }
    case LEFT_FORWARD:{
      set_speed(1,STEERING_SPEED,1);
      set_speed(2,STEERING_SPEED,1);
      set_speed(3,SLOW_SPEED,1);
      set_speed(4,SLOW_SPEED,1);
      rt_kprintf("车辆左前方\n");
      break;
    }
    case LEFT_BACK:{
      set_speed(1,SLOW_SPEED,0);
      set_speed(2,SLOW_SPEED,0);
      set_speed(3,STEERING_SPEED,0);
      set_speed(4,STEERING_SPEED,0);
      rt_kprintf("车辆左后方\n");
      break;
    }
    case RIGHT_FORWARD:{
      set_speed(1,SLOW_SPEED,1);
      set_speed(2,SLOW_SPEED,1);
      set_speed(3,STEERING_SPEED,1);
      set_speed(4,STEERING_SPEED,1);
      rt_kprintf("车辆右前方\n");
      break;
    }
    case RIGHT_BACK:{
      set_speed(1,STEERING_SPEED,0);
      set_speed(2,STEERING_SPEED,0);
      set_speed(3,BASE_SPEED,0);
      set_speed(4,BASE_SPEED,0);
      rt_kprintf("车辆右后方\n");
      break;
    }
    case STOP:{
      set_speed(1,0,0);
      set_speed(2,0,0);
      set_speed(3,0,0);
      set_speed(4,0,0);
      rt_kprintf("车辆停止\n");
      break;
    }
    default:{
      set_speed(1,0,0);
      set_speed(2,0,0);
      set_speed(3,0,0);
      set_speed(4,0,0);
      rt_kprintf("车辆停止\n");
    }
  }

}
void set_speed(int i, int speed, int dir)
{
  switch (i)
  {
  case 1:
  {
    if (dir == 0)
    {
      __HAL_TIM_SET_COMPARE(&htim2, TIM_CHANNEL_3, speed);
      __HAL_TIM_SET_COMPARE(&htim2, TIM_CHANNEL_4, 0);
    }
    else
    {
      __HAL_TIM_SET_COMPARE(&htim2, TIM_CHANNEL_4, speed);
      __HAL_TIM_SET_COMPARE(&htim2, TIM_CHANNEL_3, 0);
    }
    break;
  }
  case 2:
  {
    if (dir == 0)
    {
      __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_3, speed);
      __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_4, 0);
    }
    else
    {
      __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_4, speed);
      __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_3, 0);
    }
    break;
  }
  case 3:
  {
    if (dir == 0)
    {
      __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, speed);
      __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_2, 0);
    }
    else
    {
      __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_2, speed);
      __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, 0);
    }
    break;
  }
  case 4:
  {
    if (dir == 0)
    {
      __HAL_TIM_SET_COMPARE(&htim2, TIM_CHANNEL_1, speed);
      __HAL_TIM_SET_COMPARE(&htim2, TIM_CHANNEL_2, 0);
    }
    else
    {
      __HAL_TIM_SET_COMPARE(&htim2, TIM_CHANNEL_2, speed);
      __HAL_TIM_SET_COMPARE(&htim2, TIM_CHANNEL_1, 0);
    }
    break;
  }
  }
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
