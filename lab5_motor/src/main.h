// main.h
// Josh Brake
// jbrake@hmc.edu
// 10/31/22 

#ifndef MAIN_H
#define MAIN_H

#include "../lib/STM32L432KC.h"
#include <stm32l432xx.h>

///////////////////////////////////////////////////////////////////////////////
// Custom defines
///////////////////////////////////////////////////////////////////////////////

#define LED_PIN    PB3
#define BUTTON_PIN PA4 
#define ENCODER_A_PIN PA10
#define ENCODER_B_PIN PA11
#define DELAY_TIM  TIM2

#endif // MAIN_H