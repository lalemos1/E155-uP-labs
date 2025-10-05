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
#include "../src/fur_elise.h"

// Define macros for constants
#define MUSIC_PIN           6 // PA6
#define DELAY_DURATION_MS    100
volatile uint32_t duration_ms;
volatile uint32_t pitch;


int main(void) {
    // Configure flash to add waitstates to avoid timing errors
    configureFlash();

    // Setup the PLL and switch clock source to the PLL
    configureClock();

    initTIM(TIM15); // Initialize timer 15 for pitch counting
    initTIM(TIM16); // Initialize timer 15 for duration counting

    // Turn on clock for GPIOB
    RCC->AHB2ENR |= (1 << 1);

    // Set MUSIC_PIN as output
    pinMode(MUSIC_PIN, GPIO_OUTPUT);
    
    int len_song = sizeof(fur_elise)/sizeof(fur_elise[0]);
    
    /*
    // Blink LED
    while(1) {
        delay_millis(TIM15, DELAY_DURATION_MS);
        togglePin(MUSIC_PIN);
    } 
    */
    
    
    for(int i = 0; i < len_song; i++) {
        pitch = fur_elise[i][0];
        duration_ms = fur_elise[i][1];
        
        // For debugging:
        // len_song = 1;
        //pitch = 100; //hz
        //duration_ms = 7000; // known bug: duration can't go above 6 seconds

        if   (pitch == 0) delay_millis(TIM15, duration_ms);
        else              play_note(TIM15, TIM16, duration_ms, pitch, MUSIC_PIN);
    } 
    return 0;
    
}