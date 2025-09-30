#define TIM16_BASE (0x4001400UL) // base address for TIM16

typedef struct
{
    CR1 // important
    CR2
    SMCR
    DIER
    SMCR // important
    EGR
    ARR // important
    // there was one other that was important
}