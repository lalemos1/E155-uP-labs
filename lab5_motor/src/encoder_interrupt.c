// encoder_interrupt.c
// Lucas Lemos
// llemos@hmc.edu
// 10/7/2025
// Configures the encoder interrupts and computes the angular velocity and direction

#include "../src/main.h"

// Encoder counter global variables
volatile static int A_cnt;
volatile static int B_cnt;
volatile static char leading;

void initPB0irq(void) {
    GPIOB->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD0, 0b10); // Set PB0 as pull-down
    
    // Configure EXTICR1 for the encoder signal interrupts
    SYSCFG->EXTICR[0] |= _VAL2FLD(SYSCFG_EXTICR1_EXTI0, 0b001); // Select PB0 (bits EXTI0[2:0])

    /////////// Configure interrupt for falling edge of GPIO pin for button ///////////
    EXTI->IMR1 |= (1 << gpioPinOffset(ENCODER_A_PIN));  // Configure the mask bit
    EXTI->RTSR1 |= (1 << gpioPinOffset(ENCODER_A_PIN)); // Enable rising edge trigger
    EXTI->FTSR1 &= ~(1 << gpioPinOffset(ENCODER_A_PIN));// Disable falling edge trigger
    // Turn on EXTI interrupt in NVIC_ISER
    NVIC->ISER[0] |= (1 << EXTI0_IRQn); // EXTI0 for PB0 // EXTI0_IRQn = 6
}

void initPB1irq(void) {
    GPIOB->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD1, 0b10); // Set PB6 as pull-down

    // Configure EXTICR1 for the encoder signal interrupts
    SYSCFG->EXTICR[0] |= _VAL2FLD(SYSCFG_EXTICR1_EXTI1, 0b001); // Select PB1 (bits EXTI1[2:0])
    
    /////////// Configure interrupt for falling edge of GPIO pin for button ///////////
    EXTI->IMR1 |= (1 << gpioPinOffset(ENCODER_B_PIN)); // Configure the mask bit
    EXTI->RTSR1 |= (1 << gpioPinOffset(ENCODER_B_PIN));// Enable rising edge trigger
    EXTI->FTSR1 &= ~(1 << gpioPinOffset(ENCODER_B_PIN));// Disable falling edge trigger
    // Turn on EXTI interrupt in NVIC_ISER
    NVIC->ISER[0] |= (1 << EXTI1_IRQn); // EXTI9_5 for PB0 // EXTI1_IRQn = 7
}

// STAY AWAY FROM PA3, PA4, & PA5 B/C NOT 5V TOLERANT
// Using PB0 and PB1 since they're on the ribbon cable breakout
int main(void) {
    gpioEnable(GPIO_PORT_B);
    pinMode(LED_PIN, GPIO_OUTPUT); // Enable LED as output

    pinMode(ENCODER_A_PIN, GPIO_INPUT); // Enable encoderA as input
    pinMode(ENCODER_B_PIN, GPIO_INPUT); // Enable encoderB as input
    
    // Initialize timer
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
    initTIM(DELAY_TIM);

    // Enable SYSCFG clock domain in RCC
    RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;
    
    // Initialize encoder A & B interrupt registers
    initPB0irq();
    initPB1irq();

    printf("DEBUG: Interrupts configured.\n");
    
    // Init encoder counter values
    A_cnt = 0;
    B_cnt = 0;
    float A_vel;
    float B_vel;
    float v_avg;

    // Enable interrupts globally
    __enable_irq();
    
    // Digital read pins for debugging
    volatile int debug_A_val = digitalRead(ENCODER_A_PIN);
    volatile int debug_B_val = digitalRead(ENCODER_B_PIN);

    
    // EXPECT 408 PULSES PER ROTATION (PPR), AND 2 REV/S AT 10V
    while(1){   
        // For debugging:
        //printf("Loop.\n");
        //debug_A_val = digitalRead(ENCODER_A_PIN);
        //debug_B_val = digitalRead(ENCODER_B_PIN);
        //printf("A_cnt = %d\n", A_cnt);
        //printf("B_cnt = %d\n", B_cnt);

        // Calculate angular velocity in rev/s
        A_vel = (float)A_cnt / PPR * SCAN_FREQ;
        B_vel = (float)B_cnt / PPR * SCAN_FREQ;
        v_avg = (A_vel + B_vel) / 2;
        //printf("DEBUG: A_vel = %f\n", A_vel);
        //printf("DEBUG: B_vel = %f\n", B_vel);
        printf("Angular velocity = %0.2f Rev/s.\n", v_avg);

        // Display rotation direction
        if (leading == 'A') printf("CW.\n");
        else if (leading == 'B') printf("CCW.\n");
        else printf("direction error.\n");
        
        // Reset counters
        A_cnt = 0;
        B_cnt = 0;

        delay_millis(TIM2, SCAN_PER);
    }

}

// encoderA interrupt request handler
void EXTI0_IRQHandler(void){
    //printf("DEBUG: EXTI0 interrupt triggered.\n");

    // Check that the button was what triggered our interrupt
    if (EXTI->PR1 & (1 << gpioPinOffset(ENCODER_A_PIN))){
        //printf("DEBUG: Entered EXTI0 if statement.\n");

        // If so, clear the interrupt (NB: Write 1 to reset.)
        EXTI->PR1 |= (1 << gpioPinOffset(ENCODER_A_PIN));

        // Then increment the encoder A counter
        A_cnt++;

        // Check if A or B is leading
        if (digitalRead(ENCODER_B_PIN)) { // if A & B high
            leading = 'B';
        } else if (digitalRead(ENCODER_B_PIN) == 0){ // if A high, B low
            leading = 'A';
        } else leading = 'e'; // for error

        // Debug:
        //printf("DEBUG: A_cnt = %d.\n", A_cnt);
        //printf("DEBUG: leading_A = %c.\n", leading);
    }
}

// encoderB interrupt request handler
void EXTI1_IRQHandler(void){
    //printf("DEBUG: EXTI1 interrupt triggered.\n");

    // Check that the button was what triggered our interrupt
    if (EXTI->PR1 & (1 << gpioPinOffset(ENCODER_B_PIN))){
        //printf("DEBUG: Entered EXTI1 if statement.\n");

        // If so, clear the interrupt (NB: Write 1 to reset.)
        EXTI->PR1 |= (1 << gpioPinOffset(ENCODER_B_PIN));

        // Then increment the encoder B counter
        B_cnt++;

        // Check if A or B is leading
        if (digitalRead(ENCODER_A_PIN)) { // if B & A high
            leading = 'A';
        } else if (digitalRead(ENCODER_A_PIN) == 0){ // if B high, A low
            leading = 'B';
        } else leading = 'e'; // for error

        // Debug:
        //printf("DEBUG: B_cnt = %d.\n", B_cnt);
        //printf("DEBUG: leading_B = %c.\n", leading);
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
