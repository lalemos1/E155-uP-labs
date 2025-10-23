// DS1722.c
// TODO: <YOUR NAME>
// TODO: <YOUR EMAIL>
// TODO: <DATE>
// TODO: <SHORT DESCRIPTION OF WHAT THIS FILE DOES>

#include "STM32L432KC_GPIO.h"
#include "STM32L432KC_SPI.h"
#include <stdio.h> // for debugging

//// For debugging: Function used by printf to send characters to the laptop
//int _write(int file, char *ptr, int len) {
//  int i = 0;
//  for (i = 0; i < len; i++) {
//    ITM_SendChar((*ptr++));
//  }
//  return len;
//}

//TODO: function for reading temperature which uses SPISendReceive and decodes the 2's complement celsius value from 1-2 packets
char readTemp(void) {
    //volatile signed char MSB1 = 0;
    //volatile signed char MSB2 = 0;
    //volatile signed char MSB3 = 0;
  
    volatile signed char LSB1 = 0;
    volatile signed char LSB2 = 0;

    // Configure temp sensor
    //TODO: for excellence, make the resolution configurable
    digitalWrite(SPI_NSS, 1); // Turn on chip enable
    spiSendReceive(0x80); // address config register
    spiSendReceive(0b11100000); // 111(1SHOT off)(8-bit res)(SD off)
    digitalWrite(SPI_NSS, 0); 

    //// Read MSB register
    //digitalWrite(SPI_NSS, 1);
    //spiSendReceive(0x01); // address MSB register
    //MSB1 = spiSendReceive(0x0); // what I send doesn't matter
    //MSB2 = spiSendReceive(0x0); // what I send doesn't matter
    //MSB3 = spiSendReceive(0x0); // what I send doesn't matter
    //digitalWrite(SPI_NSS, 0);
    //printf("MSB1 = %d\n", MSB1);
    //printf("MSB2 = %d\n", MSB2);
    //printf("MSB3 = %d\n", MSB3);

    // Read LSB register
    digitalWrite(SPI_NSS, 1);
    spiSendReceive(0x02); // address LSB register
    LSB1 = spiSendReceive(0x0); // what I send doesn't matter
    LSB2 = spiSendReceive(0x0); // what I send doesn't matter
    digitalWrite(SPI_NSS, 0);
    printf("LSB1 = %d\n", LSB1);
    printf("LSB2 = %d\n", LSB2);
    
    return LSB1;
}

// TODO: for excellence, make a function which configures temp sensor resolution