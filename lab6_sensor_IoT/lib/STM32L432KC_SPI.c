// STM32L432KC_SPI.c
// Lucas Lemos
// llemos@hmc.edu
// 10/20/2025
// SPI driver for initializing SPI1 and for sending and receiving a SPI transaction. Chip select not handled here.

#include "STM32L432KC.h"
#include "STM32L432KC_SPI.h"
#include "STM32L432KC_GPIO.h"


void initSPI(int br, int cpol, int cpha) { 
    // Configure GPIO for SPI_MOSI, SPI_MISO, and SCK pins
    gpioEnable(GPIO_PORT_B);  // Enable clock for GPIOB
    pinMode(SPI_MOSI, GPIO_ALT);
    GPIOB->AFR[0] |= (0b101 << GPIO_AFRL_AFSEL5_Pos);   //AF5 for SPI1, GPIO_AFRL_AFSEL5_Pos for PB5
    pinMode(SPI_MISO, GPIO_ALT);
    GPIOB->AFR[0] |= (0b101 << GPIO_AFRL_AFSEL4_Pos);   //AF5 for SPI1, GPIO_AFRL_AFSEL4_Pos for PB4
    pinMode(SPI_SCLK, GPIO_ALT);
    GPIOB->AFR[0] |= (0b101 << GPIO_AFRL_AFSEL3_Pos);   //AF5 for SPI1, GPIO_AFRL_AFSEL3_Pos for PB3
    pinMode(SPI_NSS, GPIO_OUTPUT);
    //GPIOB->AFR[0] |= (0b101 << GPIO_AFRL_AFSEL0_Pos);   //AF5 for SPI1, GPIO_AFRL_AFSEL0_Pos for PB0
    
    // Enable SPI1 peripheral clock
    RCC->APB2ENR |= RCC_APB2ENR_SPI1EN; // Set SPI1EN
    
    // Set peripheral output speed to high
    GPIOB->OSPEEDR |= (GPIO_OSPEEDR_OSPEED3);
    
    // Set serial clock baud rate divider (BR[2:0] bits in SPI_CR1 register)
    SPI1->CR1 |= (br << SPI_CR1_BR_Pos);  // 0b000 = f_PCLK/2 (i.e. freq of peripheral clock/2)
    
    // Define clock polarity and phase depending on cpol and cpha
    cpol ? (SPI1->CR1 |= SPI_CR1_CPOL) : (SPI1->CR1 &= ~SPI_CR1_CPOL);
    cpha ? (SPI1->CR1 |= SPI_CR1_CPHA) : (SPI1->CR1 &= ~SPI_CR1_CPHA);

    // Set master configuration (MSTR bit in SPI_CR1 register)
    SPI1->CR1 |= SPI_CR1_MSTR;
    
    // Define the frame format/data order (LSBFIRST = 0 in SPI_CR1 register)
    SPI1->CR1 &= ~SPI_CR1_LSBFIRST; // set MSB first (default setting)
    
    // Select data length for the transfer (DS[3:0] bits in SPI_CR2)
    SPI1->CR2 |= (0b0111 << SPI_CR2_DS_Pos); // DS = 0b0111 (8 bit) (default value)

    // Idle NSS high
    //SPI1->CR2 |= SPI_CR2_NSSP; // CPHA needs to be = 0
    
    // Configure hardware-controlled slave select (SSOE bit in SPI_CR2 register)
    SPI1->CR2 |= SPI_CR2_SSOE; // Enable hardware slave select

    // Probs not gonna use: Configure software-controlled slave select (SSM and SSI bits in SPI_CR1 register)
    //SPI1->CR1 |= SPI_CR1_SSM;

    // Set the Rx buffer threshhold to the read access size for the SPIx_DR register (FRXTH bit in SPI_CR2 register)
    SPI1->CR2 |= SPI_CR2_FRXTH; // Set threshold to 8 bits
    
    // Enable necessary *interrupts* (which ones?)
    // Enable any necessary flags or errors?
    
    // Set chip select high
    //SPI1->CR1 |= _VAL2FLD(SPI_CR1_SSI, 0);

    // Enable SPI
    SPI1->CR1 |= (SPI_CR1_SPE);
}


// 1 byte data transfer
char spiSendReceive(char send) {
    // Wait until the transmit buffer is empty
    while(!(SPI1->SR & SPI_SR_TXE)); // || (SPI1->SR & SPI_SR_BSY)

    // Transmit the character over SPI
    *(volatile char *) (&SPI1->DR) = send; 
    
    // Wait until the peripheral data has been received
    while(!(SPI1->SR & SPI_SR_RXNE)); 

    // Return received peripheral data character
    char rec = (volatile char) SPI1->DR;
    return rec; 
}
