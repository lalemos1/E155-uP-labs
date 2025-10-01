// main.c
// GPIO blink LED with clock configuration
// Josh Brake
// jbrake@hmc.edu
// 9/16/24

// Includes for libraries
#include "../lib/STM32L432KC_RCC.h"
#include "../lib/STM32L432KC_GPIO.h"
#include "../lib/STM32L432KC_FLASH.h"
#include "../lib/STM32L432KC_TIM.h"

// Define macros for constants
#define LED_PIN           3
#define DELAY_DURATION_MS    2000

// Function for dummy delay by executing nops
void ms_delay(int ms) {
   while (ms-- > 0) {
      volatile int x=1000;
      while (x-- > 0)
         __asm("nop");
   }
}

int main(void) {
    // Configure flash to add waitstates to avoid timing errors
    configureFlash();

    // Setup the PLL and switch clock source to the PLL
    configureClock();

    initTIM(TIM16); // Enable timer 16 as the delay counter

    // Turn on clock to GPIOB
    RCC->AHB2ENR |= (1 << 1);

    // Set LED_PIN as output
    pinMode(LED_PIN, GPIO_OUTPUT);

    // Blink LED
    while(1) {
        //ms_delay(DELAY_DURATION_MS);
        delay_millis(TIM16, DELAY_DURATION_MS);
        togglePin(LED_PIN);
    }
    return 0;
}