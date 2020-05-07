# arduFPGA-mega-design-template-simple

 The simplest design with MEGA core using ATmega32u4 interrupt vector structure, one parametrized RTC as TIMER0 used to generate an interrupt every 1mS, only PORTB wired to the core, maximum 8KB of program memory and 32KB of SRAM.

 In this case I overlap the PORTB inputs and outputs, PORTB[2:0] outputs are used to drive the onboard RGB LED, PORTB[4:0] inputs are used for push buttons, this overlap in FPGA's are allowed because inputs are separated from the outputs, they can bond together at IO pin cell.

 The template application contain the main function and the TIMER0 overflow interrupt service routine.

 After reset the application light the RGB LED in Red, Green, Blue order changing the colour every second, after Blue has been lighted the LED is turned off and the application enter in infinite loop where will look for a key to be pressed.

* Key "OK" will power the Red LED.
* Key "BACK" will power the Green LED.
* Key "DN" will power the Blue LED.
* Key "UP" will light LED's Red, Green, Blue changing the colour every second, after LED Blue has been powered the application will turn OFF all LED's.
* Key "INTERRUPT" do nothing.

For timing is using a 32Bit counter incremented by interrupt service routine every millisecond and a delay routine that look at the counter and wait the specified time to pass.
