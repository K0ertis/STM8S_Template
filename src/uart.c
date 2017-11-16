#include "uart.h"






void init(){
  UART1->BRR2 = 0x01;
  UART1->BRR1 = 0x01;
}

