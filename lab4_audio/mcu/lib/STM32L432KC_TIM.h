//STM32L432KC_TIM.H
// Header for general purpose timer peripheral

#ifndef STM32L4_TIM_H
#define STM32L4_TIM_H

#include <stdint.h>

////////////////////////////////////////////////////

#define TIM15_BASE (0x40014400UL) // base address for TIM15
#define TIM16_BASE (0x40014000UL) // base address for TIM16

typedef struct
{ // POSSIBLE BUG: IDK HOW THE OFFSETS ARE BEING ENCODED AND IT THEREFORE MIGHT BE A PROBLEM THAT I SKIPPED SOME OF THE TIM REGISTERS
    volatile uint32_t CR1;  // Counter register 1         (offset 0x00). Most important: CEN bit. Set ARPE bit to prevent ARR updating until after an update event. UDIS bit disables update event. 
    volatile uint32_t CR2;  // Counter register 2         (offset 0x04). _____idk what for. Not important?
    volatile uint32_t SMCR; // Slave mode control reg     (offset 0x08). disable via SMS=000 (i think)
    volatile uint32_t DIER; // DMA interrupt/en register  (offset 0x0C). ______idk what for. Not important?--can generate an OCx DMA request or interrupt if configured
    volatile uint32_t SR;   // Status register            (offset 0x10). important. UIF bit is the update interrupt flag, high when repetition counter is overflows and equals zero (depending on URS bit). Useful for PWM??
    volatile uint32_t EGR;  // Event generation register  (offset 0x14). setting UG bit forces an update event. necessary during init, before enabling the counter
    volatile uint32_t CCMR1;// Capture compare mode reg   (offset 0x18). Set PWM mode with OCxM bits for each OCx channel ('110' or '111'). Must also set corresponding preload register in OCxPE bit
    volatile uint32_t CCER; // CC Enable register         (offset 0x20). for OCx polarity (if necessary). I think polarity means active hi vs lo?
    volatile uint32_t CNT;  // Counter register           (offset 0x24). count value of the timer
    volatile uint32_t PSC;  // Prescaler register         (offset 0x28). From 1 to 65536. Probs very important for changing freq.
    volatile uint32_t ARR;  // Auto-reload reg            (offset 0x2C). sets counter max value up to 65536. sets PWM freq in PWM mode. rw accesses the preload register if preload enabled in CR1. important 
    volatile uint32_t RCR;  // Repetition counter reg     (offset 0x30). after N overflows, update event (data moves from the preload registers to the shadow registers)
    volatile uint32_t CCR1; // Capture compare reg 1      (offset 0x34). determines duty cycle in PWM mode by setting OCxREF high while CNT < CCRx. I think PWM mode 2 flips the inequality? the OCxPE bit enables the preload register--can only update CCR every overflow
    volatile uint32_t CCR2; // Capture compare reg 2      (offset 0x38). _____idk what for. Not important?
    volatile uint32_t BDTR; // Break and dead time register (offset 0x44). not important.
    volatile uint32_t DCR;  // DMA control register         (offset 0x48). not important.
    volatile uint32_t DMAR; // DMA address for full transfer(offset 0x4C). not important.
    //volatile uint32_t OR1;  // option register 1            (offset 0x50). not important. also, idk how to make it 16 bytes long
    //volatile uint32_t OR2;  // option register 2            (offset 0x60). not important.
} TIM_TypeDef;
// CR1 to en, SMCR to disable slave, SR for update flag, EGR to force update, CCMR1 to set PWM mode, PSC to set TIMx prescaler, 
// ARR to set PWM freq, RCR to set overflows:update ratio, CCR1 to set PWM duty cycle

#define TIM15 ((TIM_TypeDef *) TIM15_BASE)
#define TIM16 ((TIM_TypeDef *) TIM16_BASE)


void initTIM(TIM_TypeDef* TIMx);
void delay_millis(TIM_TypeDef* TIMx, uint32_t ms);

// something about the update bit depending on configuration

/*
Output compare mode Procedure
1. Select the counter clock (internal, external, prescaler).
2. Write the desired data in the TIMx_ARR and TIMx_CCRx registers.
3. Set the CCxIE bit if an interrupt request is to be generated.
4. Select the output mode. For example:
– Write OCxM = 011 to toggle OCx output pin when CNT matches CCRx
– Write OCxPE = 0 to disable preload register
– Write CCxP = 0 to select active high polarity
– Write CCxE = 1 to enable the output
5. Enable the counter by setting the CEN bit in the TIMx_CR1 register.
The TIMx_CCRx register can be updated at any time by software to control the output
waveform, provided that the preload register is not enabled (OCxPE=’0’, else TIMx_CCRx
shadow register is updated only at the next update event UEV). 
*/


#endif