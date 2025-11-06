// STIM32L432KC_TIM.c
// Source code for general purpose timer functions

#include "STM32L432KC_TIM.h"
#include "STM32L432KC_RCC.h"
#include "STM32L432KC_GPIO.h"

const uint32_t PPL_CLK_FREQ = 80000000; // system clock frequency when connected to the PLL

// Relevant registers for TIMx
// CR1 to en, SMCR to disable slave, SR for update flag, EGR to force update, CCMR1 to set PWM mode, PSC to set TIMx prescaler, 
// ARR to set PWM freq, RCR to set overflows:update ratio, CCR1 to set PWM duty cycle

/*
  Initializes the general purpose timer at the input base address TIMx.
  System clock must be configured first.
*/
void initTIM(TIM_TypeDef* TIMx) {
    ///////// Enable clocks /////////
    // Enable AHB to enable HCLK
    RCC->AHB2ENR |= (1 << 1);
    __asm("nop"); __asm("nop"); // wait for two cycle clock synchronization delay
    
    // I shouldn't need to set AHB PRESC?

    // Enable APB2 to enable PCKL2
    RCC->APB2ENR |= (1 << 16);  // Enable TIM15
    RCC->APB2ENR |= (1 << 17);  // Enable TIM16
    __asm("nop"); __asm("nop"); // wait for two cycle clock synchronization delay

    // Shouldn't need to set APB2 PRESC value b/c setting TIM PSC instead
    //RCC->CFGR 
    
    
    ///////// Init TIMx /////////
    // SMCR to disable slave, PSC to set TIMx prescaler, 
    // RCR to set overflows:update ratio, EGR to force update, CR1 to en
    /////////////////////////////

    // Make sure slave mode is disabled. Disable via SMS=0b0000
    // I THINK I MIGHT ACTUALLY WANT THIS ON? allows for resetting the register I think via a trigger signal
    TIMx->SMCR &= 0b000;      // SMS[2:0] = 0b000
    TIMx->SMCR &= ~(1 << 16); // SMS[3] = 0

    // Set overflows:update ratio = 1 (update every overflow)
    //TIMx->RCR ; // I think this is unnecessary since overflows:update ratio = 1 at reset
    // read the manual again--there was the weird thing about setting automatic reloading in CR1 i think

    // Init CNT=0 and PSC_CNT = 0 by causing an event generation (setting UG=1 in the TIMx_EGR register)
    TIMx->EGR |= 1;

    // Enable counter by setting CEN = 1 in the CR1 register
    TIMx->CR1 |= 1;
}


/*
  Initializes PWM mode for TIMx

*/ /*
void initPWM(TIM_TypeDef* TIMx) {
        // Set prescaler to give f_TIMx_CNT = 500kHz (f_CK_CNT = 80MHz / PSC + 1)
    TIMx->PSC &= 0;       // clear all bits
    TIMx->PSC |= TIM_DIV; // write 159

}
*/

/*
  Locks up the program until a precise number of milliseconds have passed according to the input timer

*/
void delay_millis(TIM_TypeDef* TIMx, uint32_t ms) {
    // Local variables
    uint32_t delay_TIM_div = 7999; // Prescaler to give f_TIMx_CNT = 10kHz (f_TIMx_CNT = 80MHz / PSC + 1)
    uint32_t TIM_clk_freq = PPL_CLK_FREQ / (delay_TIM_div + 1); // timer frequency
    uint32_t delay_cnt = ms * 0.001 * TIM_clk_freq;    // length of delay in timer counts

    // Set prescaler to give f_TIMx_CNT = 10kHz
    TIMx->PSC &= 0;       // clear all bits
    TIMx->PSC |= delay_TIM_div; // divide timer clock

    //// needs to throw an error if delay_cnt > 65536
    
    // Set timer register values
    TIMx->ARR &= 0;         // clear all bits
    TIMx->ARR |= delay_cnt; // Set counter max value
    TIMx->EGR |= 1;         // Force reset
    TIMx->SR  &= 0;         // Clear update event flag
    
    // for now we'll use a while loop to implement the delay, but in lab 5 we'll replace it w/ interrupts
    // Do nothing until the update interupt flag goes high because the counter overflowed
    while ( (TIMx->SR & 1) != 1 );  
}

/*
  Sets an output pin high and low according to a frequency for a specified amount of time in ms

*/
void play_note(TIM_TypeDef* TIMp, TIM_TypeDef* TIMd, uint32_t ms, uint32_t hz, int pin_out) {
    // p for pitch, d for note duration
    // Local variables
    uint32_t p_TIM_div = 159;                            // prescaler divider to set pitch clock frequency
    uint32_t p_freq    = PPL_CLK_FREQ / (p_TIM_div + 1); // timer frequency for pitch clock (500kHz)
    uint32_t p_cnt     = p_freq / hz;         // wavelength of pitch measured in timer counts

    uint32_t d_TIM_div = 7999;                            // prescaler divider to set duration clock frequency
    uint32_t d_freq = PPL_CLK_FREQ / (d_TIM_div + 1); // timer frequency for duration clock (10kHz)
    uint32_t d_cnt = ms * 0.001 * d_freq;           // playback duration measured in timer counts

    //// needs to throw an error if cnt > 65536

    // Set pitch prescaler to give f_TIMp_CNT = 500kHz (f_TIMx_CNT = 80MHz / PSC + 1)
    TIMp->PSC &= 0;       // clear all bits
    TIMp->PSC |= p_TIM_div; // divide pitch clock

    // Set duration prescaler to give f_TIMd_CNT = 10kHz (f_TIMx_CNT = 80MHz / PSC + 1)
    TIMd->PSC &= 0;         // clear all bits
    TIMd->PSC |= d_TIM_div; // divide duration clock

    // Set both timer register max values
    TIMd->ARR &= 0;     // clear all bits
    TIMd->ARR |= d_cnt; // Set duration counter max value
    TIMp->ARR &= 0;     // clear all bits
    TIMp->ARR |= p_cnt; // Set pitch counter max value
    
    // Reset both counters
    TIMd->EGR |= 1;     // Force reset duration counter
    TIMd->SR  &= 0;     // Clear update event flag
    TIMp->EGR |= 1;     // Force reset pitch counter

    // need to move this stuff^ into an init phase and enable the counter only once inside the while loops
    
    // Play note until the update interupt flag goes high because the counter overflowed
    while ( (TIMd->SR & 1) == 0 ) {
        TIMp->SR  &= 0; // Clear update event flag
        
        // Wait until the pitch wavelength is up
        while ( (TIMp->SR & 1) == 0); // I think this is gonna cause my pitch to be an octave lower b/c above i might want my cnt to be halved
        togglePin(pin_out);
    };  
    
    //togglePin(MUSIC_PIN);
    // clear UEV flag
}