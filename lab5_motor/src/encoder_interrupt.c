// encoder_interrupt.c
// Lucas Lemos
// llemos@hmc.edu
// 10/7/2025

#include "../src/main.h"

// Encoder counter global variables
volatile static int A_cnt;
volatile static int B_cnt;

// EXPECT 408 PULSES PER ROTATION (PPR), AND 2 REV/S AT 10V
// STAY AWAY FROM PA3, PA4, & PA5 B/C NOT 5V TOLERANT
// maybe use PA10 & PA11 for encoderA and encoderB
// NEVERMIND: use PB0 thru PB4 b/c idk where the EXTI Line5thru9 and Line10thru15 share a single interrupt
// I guess PB0 and PB6 since they're on the ribbon cable breakout
int main(void) {
    gpioEnable(GPIO_PORT_B);
    pinMode(LED_PIN, GPIO_OUTPUT); // Enable LED as output
    pinMode(ENCODER_A_PIN, GPIO_INPUT); // Enable encoderA as input
    pinMode(ENCODER_B_PIN, GPIO_INPUT); // Enable encoderB as input
    GPIOB->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD0, 0b10); // Set PB0 as pull-down
    GPIOB->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD1, 0b10); // Set PB6 as pull-down


    // TODO: remove this timer when testing motor -- or maybe not for updating the motor velocity
    // Initialize timer
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
    initTIM(DELAY_TIM);

    /////////// Enable SYSCFG clock domain in RCC ///////////
    RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;
    // Configure EXTICR1 for the encoder signal interrupts
    SYSCFG->EXTICR[0] |= _VAL2FLD(SYSCFG_EXTICR1_EXTI0, 0b001); // Select PB0 (bits EXTI0[2:0])
    SYSCFG->EXTICR[0] |= _VAL2FLD(SYSCFG_EXTICR1_EXTI1, 0b001); // Select PB1 (bits EXTI1[2:0])

    /////////// Configure interrupt for falling edge of GPIO pin for button ///////////
    // Configure mask bit
    EXTI->IMR1 |= (1 << gpioPinOffset(ENCODER_A_PIN)); // Configure the mask bit
    EXTI->IMR1 |= (1 << gpioPinOffset(ENCODER_B_PIN)); // Configure the mask bit
    // Disable rising edge trigger
    EXTI->RTSR1 |= (1 << gpioPinOffset(ENCODER_A_PIN));// Enable rising edge trigger
    EXTI->RTSR1 |= (1 << gpioPinOffset(ENCODER_B_PIN));// Enable rising edge trigger
    // Enable falling edge trigger
    EXTI->FTSR1 &= ~(1 << gpioPinOffset(ENCODER_A_PIN));// Disable falling edge trigger
    EXTI->FTSR1 &= ~(1 << gpioPinOffset(ENCODER_B_PIN));// Disable falling edge trigger
    // Turn on EXTI interrupt in NVIC_ISER
    NVIC->ISER[0] |= (1 << EXTI0_IRQn); // EXTI0 for PB0 // EXTI0_IRQn = 6
    NVIC->ISER[0] |= (1 << EXTI1_IRQn); // EXTI9_5 for PB0 // EXTI1_IRQn = 7

    printf("DEBUG: Interrupts configured.\n");
    
    // Init encoder counter values
    A_cnt = 0;
    B_cnt = 0;

    // Enable interrupts globally
    __enable_irq();
    
    // Digital read pins for debugging
    volatile int debug_A_val = digitalRead(ENCODER_A_PIN);
    volatile int debug_B_val = digitalRead(ENCODER_B_PIN);

    while(1){   
        printf("Loop.\n");
        debug_A_val = digitalRead(ENCODER_A_PIN);
        debug_B_val = digitalRead(ENCODER_B_PIN);
        delay_millis(TIM2, 200);
    }

}

/*
int encoder_A_cnt(void) {
    volatile static int A_cnt;
    return A_cnt++;
}

int encoder_B_cnt(void) {
    volatile static int B_cnt;
    return B_cnt++;
}
*/

// encoderA interrupt request handler
void EXTI0_IRQHandler(void){
    printf("DEBUG: EXTI0 interrupt triggered.\n");
    // Check that the button was what triggered our interrupt
    if (EXTI->PR1 & (1 << gpioPinOffset(ENCODER_A_PIN))){
        printf("DEBUG: Entered EXTI0 if statement.\n");
        // If so, clear the interrupt (NB: Write 1 to reset.)
        EXTI->PR1 |= (1 << gpioPinOffset(ENCODER_A_PIN));

        // Then increment the encoder A counter
        A_cnt++;
        printf("DEBUG: A_cnt = %d.\n", A_cnt);
    }
}

// encoderB interrupt request handler
void EXTI1_IRQHandler(void){
    printf("DEBUG: EXTI1 interrupt triggered.\n");
    // Check that the button was what triggered our interrupt
    if (EXTI->PR1 & (1 << gpioPinOffset(ENCODER_B_PIN))){
        printf("DEBUG: Entered EXTI1 if statement.\n");
        // If so, clear the interrupt (NB: Write 1 to reset.)
        EXTI->PR1 |= (1 << gpioPinOffset(ENCODER_B_PIN));

        // Then increment the encoder B counter
        B_cnt++;
        printf("DEBUG: B_cnt = %d.\n", B_cnt);
    }
}

// Function used by printf to send characters to the laptop
int _write(int file, char *ptr, int len) {
  int i = 0;
  for (i = 0; i < len; i++) {
    ITM_SendChar((*ptr++));
  }
  return len;
}
