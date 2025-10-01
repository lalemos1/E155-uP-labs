// STIM32L432KC_TIM.c
// Source code for general purpose timer functions

#include "STM32L432KC_TIM.h"
#include "STM32L432KC_RCC.h"

const uint32_t TIM_DIV = 159; // timer peripheral clock divisor

// Relevant registers for TIMx
// CR1 to en, SMCR to disable slave, SR for update flag, EGR to force update, CCMR1 to set PWM mode, PSC to set TIMx prescaler, 
// ARR to set PWM freq, RCR to set overflows:update ratio, CCR1 to set PWM duty cycle

// TIM15/16 run off PCLK2 off HCLK off SYSCLK. HCLK and APB2 PRESC both default off
// takeaway: if something completely isn't working, it's probably b/c your thing is part of a larger system
// and you might need to enable something upstream. Use the block diagram and clock tree to help with this.

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

    // Make sure slave mode is disabled. disable via SMS=000 (i think)
    TIMx->SMCR ;

    // Set prescaler to give f_TIMx_CNT = 500kHz (f_CK_CNT = 80MHz / PSC + 1)
    TIMx->PSC &= 0;       // clear all bits
    TIMx->PSC |= TIM_DIV; // write 159

    // Set overflows:update ratio = 1 (update every overflow)
    TIMx->RCR ;
    // read the manual again--there was the weird thing about setting automatic reloading in CR1 i think

    // Init CNT=0 and PSC_CNT = 0 by causing an event generation (setting UG=1 in the TIMx_EGR register)
    TIMx->EGR |= 1;

    // Enable counter by setting CEN = 1 in the CR1 register
    TIMx->CR1 ;
    // Most important: CEN bit. Set ARPE bit in upcounting or center-aligned for PWM. UDIS bit disabled update event. 
    // I think i should just set all CR1 bits manually during init
}

/*
  Initializes PWM mode for TIMx

*/ /*
void initPWM(TIM_TypeDef* TIMx) {
    
}
*/

/*
  Locks up the program until a precise number of milliseconds have passed according to the input timer

*/
void delay_millis(TIM_TypeDef* TIMx, uint32_t ms) {
    // main writes are ARR, EGR, SR, CNT

    // for now we'll use a while loop to implement the delay, but in lab 5 we'll replace it w/ interrupts
}


/*

#include "STM32L432KC_RCC.h"

void configurePLL() {
    // Set clock to 80 MHz
    // Output freq = (src_clk) * (N/M) / R
    // (4 MHz) * (80/1) / 4 = 80 MHz
    // M: 1, N: 80, R: 4
    // Use MSI as PLLSRC

    // Turn off PLL
    RCC->CR &= ~(1 << 24);
    
    // Wait till PLL is unlocked (e.g., off)
    while ((RCC->CR >> 25 & 1) != 0);

    // Load configuration
    // Set PLL SRC to MSI
    RCC->PLLCFGR |= (1 << 0);
    RCC->PLLCFGR &= ~(1 << 1);

    // Set PLLN
    RCC->PLLCFGR &= ~(0b11111111 << 8); // Clear all bits of PLLN
    RCC->PLLCFGR |= (0b1010000 << 8); // |= 80
    
    // Set PLLM
    RCC->PLLCFGR &= ~(0b111 << 4);  // Clear all bits
    
    // Set PLLR
    RCC->PLLCFGR &= ~(1 << 26);
    RCC->PLLCFGR |= (1 << 25);
    
    // Enable PLLR output
    RCC->PLLCFGR |= (1 << 24);

    // Enable PLL
    RCC->CR |= (1 << 24);
    
    // Wait until PLL is locked
    while ((RCC->CR >> 25 & 1) != 1);
}

void configureClock(){
    // Configure and turn on PLL
    configurePLL();

    // Select PLL as clock source
    RCC->CFGR |= (0b11 << 0);
    while(!((RCC->CFGR >> 2) & 0b11));
}
*/


// Kanoa: easiest way to play the audio is to read the counter overflow from software and enable the GPIO that way----DON'T TRY TO OUTPUT THE PWM DIRECTLY!