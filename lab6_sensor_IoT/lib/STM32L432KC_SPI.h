// STM32L432KC_SPI.h
// Lucas Lemos
// llemos@hmc.edu
// 10/20/2025
// Function prototypes and pin definitions for the SPI driver

#ifndef STM32L4_SPI_H
#define STM32L4_SPI_H

#include <stdint.h>
#include <stm32l432xx.h>

// Define SPI1 pins
#define SPI_SCLK PB3 // brown. D2 on logic analyzer (for debugging)
#define SPI_MOSI PB5 // blue.  D3
#define SPI_MISO PB4 // green. D4
#define SPI_NSS  PB0 // white. D7 // this is active low but our peripheral is active-high!!

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

/* Enables the SPI peripheral and intializes its clock speed (baud rate), polarity, and phase.
 *    -- br: (0b000 - 0b111). The SPI clk will be the master clock / 2^(BR+1).
 *    -- cpol: clock polarity (0: inactive state is logical 0, 1: inactive state is logical 1).
 *    -- cpha: clock phase (0: data captured on leading edge of clk and changed on next edge, 
 *          1: data changed on leading edge of clk and captured on next edge)
 * Refer to the datasheet for more low-level details. */ 
void initSPI(int br, int cpol, int cpha);

/* Transmits a character (1 byte) over SPI and returns the received character.
 *    -- send: the character to send over SPI
 *    -- TIMx: delay timer
 *    -- return: the character received over SPI */
char spiSendReceive(char send);

#endif