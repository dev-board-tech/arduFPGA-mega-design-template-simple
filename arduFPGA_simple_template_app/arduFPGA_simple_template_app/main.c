/*
 * arduFPGA_simple_template_app.c
 *
 * Created: 07.05.2020 11:09:39
 * Author : MorgothCreator
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>

#define LED_B		(1 << 0)
#define LED_G		(1 << 1)
#define LED_R		(1 << 2)

volatile uint32_t tim_cnt;

/*
 In this design we use a the default TIMER0 overflow used by arduino IDE for ATmega32u4 device.
 So, we can use the standard interrupt vector table.
 */

static void delay_ms(uint32_t time)
{
	cli();
	uint32_t time_to_tick = tim_cnt + time;
	sei();
	//uint32_t rtc_cnt_int;
	while(1) {
		if(tim_cnt > time_to_tick)
			return;
	}
	/*do
	{
		rtc_cnt_int = tim_cnt;
	} while (time_to_tick > rtc_cnt_int);*/
}

int main(void)
{
    // In this example the design use a handwritten RTC as TIMER0 overflow interrupt, so we do not need to initialize the TIMER.
	// As soon as we enable the interrupts the core will receive them.
	DDRB = (LED_B | LED_G | LED_R); // Activate the outputs for LED pins.
	// We can not set up PULL UP's from software for the inputs, PULL UPs on iCE40UP device are set up from the design.
	sei();
	PORTB = LED_R;
	delay_ms(1000);
	PORTB = LED_B;
	delay_ms(1000);
	PORTB = LED_G;
	delay_ms(1000);
	PORTB = 0;
	uint8_t tmp_keys_old = 0;
    while (1) 
    {
		 // The advantage of the FPGA is that on the same IO PORT we can use outputs separate from the inputs.
		 // In this case for keyboard we use inputs 5:0, and for LED's we use outputs 2:0 of the same IO PORT, so, pins 2:0 has dual function.
		uint8_t tmp_keys = (~PINB) & 0b00011111; // Inverse the inputs from PORTB and filter them, the common for keyboard is logic 0.
		if(tmp_keys_old != tmp_keys) {
			switch(tmp_keys) {
				case 0b00000001: // BTN_OK
					PORTB = LED_R;
					break;
				case 0b00000010: // BTN_BACK
					PORTB = LED_G;
					break;
				case 0b00000100: // BTN_DN
					PORTB = LED_B;
					break;
				case 0b00001000: // BTN_UP
					PORTB = LED_R;
					delay_ms(1000);
					PORTB = LED_G;
					delay_ms(1000);
					PORTB = LED_B;
					delay_ms(1000);
					PORTB = 0;
					break;
			}
			tmp_keys_old = tmp_keys;
		}
    }
}

ISR(TIMER0_OVF_vect) {
	tim_cnt++;
}
