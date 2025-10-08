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
#define DELAY_TIM  TIM2

#define ENCODER_A_PIN PB0
#define ENCODER_B_PIN PB1
#define PPR 408 // pulses per rotation
#define SCAN_PER 200 // ms
#define SCAN_FREQ 1000/SCAN_PER // Hz

#endif // MAIN_H