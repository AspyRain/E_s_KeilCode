#ifndef __BPC_DECODE_H
#define __BPC_DECODE_H


#include "define.h"
#include <stdint.h>
#include "stm32f1xx_hal.h"
uint8_t BPC_DECODE(uint8_t *Buff, uint8_t *DATA);
void BPC_timer_callback(void *parameter);
uint8_t GPIO_ReadInputDataBit(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin);
void startGetTime();
#endif
