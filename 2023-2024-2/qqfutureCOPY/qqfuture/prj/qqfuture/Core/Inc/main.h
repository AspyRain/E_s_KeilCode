/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.h
  * @brief          : Header for main.c file.
  *                   This file contains the common defines of the application.
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

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "stm32f1xx_hal.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Exported types ------------------------------------------------------------*/
/* USER CODE BEGIN ET */

/* USER CODE END ET */

/* Exported constants --------------------------------------------------------*/
/* USER CODE BEGIN EC */

/* USER CODE END EC */

/* Exported macro ------------------------------------------------------------*/
/* USER CODE BEGIN EM */

/* USER CODE END EM */

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */

/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define R2_IN1_Pin GPIO_PIN_0
#define R2_IN1_GPIO_Port GPIOA
#define R2_IN2_Pin GPIO_PIN_1
#define R2_IN2_GPIO_Port GPIOA
#define UR_TX_Pin GPIO_PIN_2
#define UR_TX_GPIO_Port GPIOA
#define UR_RX_Pin GPIO_PIN_3
#define UR_RX_GPIO_Port GPIOA
#define R1_IN1_Pin GPIO_PIN_6
#define R1_IN1_GPIO_Port GPIOA
#define R1_IN2_Pin GPIO_PIN_7
#define R1_IN2_GPIO_Port GPIOA
#define L2_IN1_Pin GPIO_PIN_0
#define L2_IN1_GPIO_Port GPIOB
#define L2_IN2_Pin GPIO_PIN_1
#define L2_IN2_GPIO_Port GPIOB
#define L1_IN1_Pin GPIO_PIN_10
#define L1_IN1_GPIO_Port GPIOB
#define L1_IN2_Pin GPIO_PIN_11
#define L1_IN2_GPIO_Port GPIOB
#define enable_R_Pin GPIO_PIN_12
#define enable_R_GPIO_Port GPIOB
#define enable_L_Pin GPIO_PIN_13
#define enable_L_GPIO_Port GPIOB
#define BT_TX_Pin GPIO_PIN_9
#define BT_TX_GPIO_Port GPIOA
#define BT_RX_Pin GPIO_PIN_10
#define BT_RX_GPIO_Port GPIOA

/* USER CODE BEGIN Private defines */
void initial_speed();
void set_speed(int i,int speed,int dir);
/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
