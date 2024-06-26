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
#include <rtthread.h>

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
	int base_speed=40;//100%?
	int low_speed=30;
	int correction_speed=50;
	int turning_speed=75;
	int turning_speed_low=10;
	int now_mode=0;
	char c;//?? #:??  *:??
char forward[]="Forward\n";//????
char stop[]="stop\n";//????
char tips[]="CommandError\n";//??1
int stop_flag=1;
	int route_flags[4]={0,0,0,0};
	int low_speed_flag=0;
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
void initial_speed(){
	base_speed=(base_speed*65535)/100;
	low_speed=(base_speed*65535)/100;
	correction_speed=(correction_speed*65535)/100;
	turning_speed=(turning_speed*65535)/100;
	turning_speed_low=(turning_speed_low*65535)/100;
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
  MX_TIM2_Init();
  MX_TIM3_Init();
  MX_USART1_UART_Init();
  MX_USART2_UART_Init();
  /* USER CODE BEGIN 2 */
	initial_speed();
	HAL_GPIO_WritePin(enable_L_GPIO_Port,enable_L_Pin,GPIO_PIN_SET);
	HAL_GPIO_WritePin(enable_R_GPIO_Port,enable_R_Pin,GPIO_PIN_SET);
	HAL_TIM_PWM_Start(&htim2,TIM_CHANNEL_1);
	HAL_TIM_PWM_Start(&htim2,TIM_CHANNEL_2);
	HAL_TIM_PWM_Start(&htim2,TIM_CHANNEL_3);
	HAL_TIM_PWM_Start(&htim2,TIM_CHANNEL_4);
	HAL_TIM_PWM_Start(&htim3,TIM_CHANNEL_1);
	HAL_TIM_PWM_Start(&htim3,TIM_CHANNEL_2);
	HAL_TIM_PWM_Start(&htim3,TIM_CHANNEL_3);
	HAL_TIM_PWM_Start(&htim3,TIM_CHANNEL_4);
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
void set_speed(int i,int speed,int dir){
	switch (i){
		case 1:{
			if (dir==0){
				__HAL_TIM_SET_COMPARE(&htim2,TIM_CHANNEL_3,speed);
				__HAL_TIM_SET_COMPARE(&htim2,TIM_CHANNEL_4,0);
			}else {
				__HAL_TIM_SET_COMPARE(&htim2,TIM_CHANNEL_4,speed);
				__HAL_TIM_SET_COMPARE(&htim2,TIM_CHANNEL_3,0);
			}
			break;
		}
		case 2:{
			if (dir==0){
				__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_3,speed);
				__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_4,0);
			}else {
				__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_4,speed);
				__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_3,0);
			}
			break;
		}
		case 3:{
			if (dir==0){
				__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_1,speed);
				__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_1,0);
			}else {
				__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_2,speed);
				__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_1,0);
			}
			break;
		}
		case 4:{
			if (dir==0){
				__HAL_TIM_SET_COMPARE(&htim2,TIM_CHANNEL_1,speed);
				__HAL_TIM_SET_COMPARE(&htim2,TIM_CHANNEL_2,0);
			}else {
				__HAL_TIM_SET_COMPARE(&htim2,TIM_CHANNEL_2,speed);
				__HAL_TIM_SET_COMPARE(&htim2,TIM_CHANNEL_1,0);
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
