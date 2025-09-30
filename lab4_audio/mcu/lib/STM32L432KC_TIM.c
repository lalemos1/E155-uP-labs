


// TIM15/16 run off PCLK2 off HCLK off SYSCLK. HCLK and APB2 PRESC both default off
// takeaway: if something completely isn't working, it's probably b/c your thing is part of a larger system
// and you might need to enable something upstream. Use the block diagram and clock tree to help with this.
void initTIM(TIM_Typedef * TIMx) {

    // to find which registers (the ones below) look through the functional modes and find one with a "tutorial"
    // that looks promising, like 28.5.2 Counter Modes (or the one on PWM mode)
    // main three register writes are to PSC, EGR, and CR1
}

void delay_millis(TIM_TypeDef * TIMx, uint32_t ms) {
    // main writes are ARR, EGR, SR, CNT

    // for now we'll use a while loop to implement the delay, but in lab 5 we'll replace it w/ interrupts
}