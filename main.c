// Unit test emulator for AVR
// Sends typical testing logs (like to CMocka or GTest) to USART
// Chip: ATmega328p
// External Oscillator: 11.0592MHz
// USART baudrate: 115200


#define SUCCESS		1
#define FAILURE		2
#define INFINITE_LOOP	3

// One of 3 test scenarios should be selected by definition SCENARIO
#ifndef SCENARIO
#warning SCENARIO should be defined as SUCCESS, FAILURE, INFINITE_LOOP.
#warning SUCCESS scenatio will be used as default.
#define SCENARIO SUCCESS
#endif

#define BAUD_RATE_115200_BPS  5 // 115.2k bps


#include <avr/io.h>
#include <util/delay.h>



static void print(const char *str) {
	if (str == 0) return;
	while(*str != '\0')
	{
        	while (!( UCSR0A & (1<<UDRE0)));
		UDR0 = *str++;
        }
}


int main(void)
{
	unsigned int ubrr = BAUD_RATE_115200_BPS;

	const char start[] = 
		"[==========] Running 10 test(s).\n";

	const char test_ok[] = 
		"[ RUN      ] test_bla_bla\n"
		"[       OK ] test_bla_bla\n";

#if (SCENARIO != SUCCESS)
	const char test_fail[] = 
                "[ RUN      ] test_bla_bla\n"
                "[  FAILED  ] test_bla_bla\n";

	const char end[] =
		"[==========] 10 test(s) run.\n"
		"[  PASSED  ] 9 test(s).\n"
		"[  FAILED  ] 1 test(s).\n";
#else
        const char end[] =
                "[==========] 10 test(s) run.\n"
                "[  PASSED  ] 10 test(s).\n";
#endif
	UBRR0H = (ubrr>>8); // Shift the 16bit value ubrr 8 times to the right and transfer the upper 8 bits to UBBR0H register.
	UBRR0L = (ubrr);    // Copy the 16 bit value ubrr to the 8 bit UBBR0L register,Upper 8 bits are truncated while lower 8 bits are copied
	UCSR0C = 0x06;       /* Set frame format: 8data, 1stop bit  */
	UCSR0B = (1<<TXEN0); /* Enable  transmitter                 */

	print(start);
	
	for (int i = 0; i < 10; i++)	
	{
#if (SCENARIO == SUCCESS)
		print(test_ok);
#elif (SCENARIO == FAILURE)
		if (i != 5) print(test_ok);
		else print(test_fail);
#elif (SCENARIO == INFINITE_LOOP)
		print(test_ok);
		if (i == 5) for(;;);
#else
#error Unknown SCENARIO definition. Supported values: SUCCESS, FAILURE, INFINITE_LOOP
#endif
	}

	print(end);
	return 0;
		
}//end of main
