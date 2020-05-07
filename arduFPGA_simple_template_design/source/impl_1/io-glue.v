/*
 * This IP is the IO and CORE glue module implementation.
 * 
 * Copyright (C) 2020  Iulian Gheorghiu (morgoth@devboard.tech)
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

`timescale 1ns / 1ps

/* Definitions to easily change the parameters later. */
/* We will use an emulated ATMEGA32U4 and is a "MEGA_ENHANCED_128K" family. */
`define CORE_TYPE				`MEGA_ENHANCED_128K
`define ROM_ADDR_WIDTH			12// we use BLOCK RAM as ROM, we have disponoble only 12KB, for this example is enought 8KB
`define BUS_ADDR_DATA_LEN		15// RAM bus will be able to address 4KB of data space.
`define RAM_ADDR_WIDTH			15// The genuine one has 2560Bytes, we put 4K of RAM.
`define EEP_ADDR_WIDTH			10// We do not use EEPROM in this design example (1KB).
`define RESERVED_RAM_FOR_IO		12'h100// This is the reserved address space at beginning of RAM for IO's.

`define VECTOR_INT_TABLE_SIZE	43// 42 + NMI
`define WATCHDOG_CNT_WIDTH		0//27


module core # (
	parameter PLATFORM = "iCE40UP",
	parameter ROM_PATH = ""
	)(
	input core_rst,
	input core_clk,
    output [2:0] RGB_LED,
	input BTN_UP,
	input BTN_DN,
	input BTN_BACK,
	input BTN_OK,
	input BTN_INTERRUPT
);

/* CORE WIRES */
wire [`ROM_ADDR_WIDTH - 1:0]pgm_addr;
wire [15:0]pgm_data;
wire [`BUS_ADDR_DATA_LEN:0]data_addr;
wire [7:0]core_data_out;
wire data_write;
wire [7:0]core_data_in;
wire data_read;
wire ram_sel = |data_addr[`BUS_ADDR_DATA_LEN:8];

wire [7:0] io_addr = data_addr[7:0];
wire [7:0] io_out = core_data_out;
assign io_write = data_write & io_sel;
assign io_read = data_read & io_sel;
assign io_sel = ~ram_sel;
/* !CORE WIRES */

/* Interrupt wires */
/*
 We list all interrupt lines in the design, we need to mantain the order,
 the sinthetizer will use only lines that are not tied to logic 0.
 */
wire nmi_sig = 0;
wire int_int0 = 0;
wire int_int1 = 0;
wire int_int2 = 0;
wire int_int3 = 0;
wire int_reserved0 = 0;
wire int_reserved1 = 0;
wire int_int6 = 0;
wire int_reserved3 = 0;
wire int_pcint0 = 0;
wire int_usb_general = 0;
wire int_usb_endpoint = 0;
wire int_wdt = 0;
wire int_reserved4 = 0;
wire int_reserved5 = 0;
wire int_reserved6 = 0;
wire int_timer1_capt = 0;
wire int_timer1_compa = 0;
wire int_timer1_compb = 0;
wire int_timer1_compc = 0;
wire int_timer1_ovf = 0;
wire int_timer0_compa = 0;
wire int_timer0_compb = 0;
wire int_timer0_ovf;
wire int_spi_stc = 0;
wire int_usart1_rx = 0;
wire int_usart1_udre = 0;
wire int_usart1_tx = 0;
wire int_analog_comp = 0;
wire int_adc = 0;
wire int_ee_ready = 0;
wire int_timer3_capt = 0;
wire int_timer3_compa = 0;
wire int_timer3_compb = 0;
wire int_timer3_compc = 0;
wire int_timer3_ovf = 0;
wire int_twi = 0;
wire int_spm_ready = 0;
wire int_timer4_compa = 0;
wire int_timer4_compb = 0;
wire int_timer4_compd = 0;
wire int_timer4_ovf = 0;
wire int_timer4_fpf = 0;
/* !Interrupt wires */

/* Interrupt reset wires */
/*
 We list all interrupt reset lines in the design, we need to mantain the order,
 the sinthetizer will discard lines that are not tied to anithing.
 */
wire nmi_rst;
wire int_int0_rst;
wire int_int1_rst;
wire int_int2_rst;
wire int_int3_rst;
wire int_reserved0_rst;
wire int_reserved1_rst;
wire int_int6_rst;
wire int_reserved3_rst;
wire int_pcint0_rst;
wire int_usb_general_rst;
wire int_usb_endpoint_rst;
wire int_wdt_rst;
wire int_reserved4_rst;
wire int_reserved5_rst;
wire int_reserved6_rst;
wire int_timer1_capt_rst;
wire int_timer1_compa_rst;
wire int_timer1_compb_rst;
wire int_timer1_compc_rst;
wire int_timer1_ovf_rst;
wire int_timer0_compa_rst;
wire int_timer0_compb_rst;
wire int_timer0_ovf_rst;
wire int_spi_stc_rst;
wire int_usart1_rx_rst;
wire int_usart1_udre_rst;
wire int_usart1_tx_rst;
wire int_analog_comp_rst;
wire int_adc_rst;
wire int_ee_ready_rst;
wire int_timer3_capt_rst;
wire int_timer3_compa_rst;
wire int_timer3_compb_rst;
wire int_timer3_compc_rst;
wire int_timer3_ovf_rst;
wire int_twi_rst;
wire int_spm_ready_rst;
wire int_timer4_compa_rst;
wire int_timer4_compb_rst;
wire int_timer4_compd_rst;
wire int_timer4_ovf_rst;
wire int_timer4_fpf_rst;
/* !Interrupt reset wires */

/* PORTB */
wire [7:0]dat_pb_d_out;
wire [4:0]port_b_dummy_wire;
atmega_pio # (
	.PLATFORM(PLATFORM),
	.BUS_ADDR_DATA_LEN(8),
	.PORT_OUT_ADDR('h25),// We use the genuine ATmega32u4 PORTB IO addresses.
	.DDR_ADDR('h24),
	.PIN_ADDR('h23),
	.PINMASK(8'b11111111),
	.PULLUP_MASK(8'b00000000),
	.PULLDN_MASK(8'b00000000),
	.INVERSE_MASK(8'b00000000),
	.OUT_ENABLED_MASK(8'b00000111)
)pio_b(
	.rst(core_rst),
	.clk(core_clk),
	.addr(io_addr),
	.wr(io_write),
	.rd(io_read),
	.bus_in(io_out),
	.bus_out(dat_pb_d_out),

	.io_in({3'bz, BTN_INTERRUPT, BTN_UP, BTN_DN, BTN_BACK, BTN_OK}),
	.io_out({port_b_dummy_wire, RGB_LED}),
	.pio_out_io_connect()
	);
/* !PORTB */

/* RTC */
/*
 ARDUINO IDE use TIMER 0 overflow to generate 1mS interrupt for clock.
 We use a hardwritten rtc for the same purpose, to use more efficiently the available resources.
 */
rtc #(
	.PERIOD_STATIC(16000), // The core clock divided by this value give the timming when a tick will happen.
	.CNT_SIZE(14)// Counter size, is needed to count up to 16000 for 1mS tick, so a 14 bit counter is enought.
	)rtc_inst(
	.rst(core_rst),
	.clk(core_clk),
	.intr(int_timer0_ovf),
	.int_rst(int_timer0_ovf_rst)
	);
/* !RTC */


/* ROM APP */
mega_rom  #(
	.PLATFORM(PLATFORM),
	.ADDR_ROM_BUS_WIDTH(`ROM_ADDR_WIDTH),
	.ROM_PATH(ROM_PATH)// Will be initiated with the data in this file on the disk.
)rom(
	.clk(core_clk),
	.a(pgm_addr),
	.cs(1'b1),
	.d(pgm_data)
);
/* !ROM APP */

/* RAM */
wire [7:0]ram_bus_out;
wire [`RAM_ADDR_WIDTH - 1:0] ram_addr = data_addr[`RAM_ADDR_WIDTH:0] - `RESERVED_RAM_FOR_IO;
mega_ram  #(
	.PLATFORM(PLATFORM),
	.MEM_MODE("SRAM"), // "BLOCK","SRAM"// "SRAM" mode are block of 32KB of single port RAM, maybe in the future we will need all 12KB of direct programmed ROM.
	.ADDR_BUS_WIDTH(`RAM_ADDR_WIDTH),
	.ADDR_RAM_DEPTH(32768),
	.DATA_BUS_WIDTH(8),
	.RAM_PATH("")
)ram(
	.clk(core_clk),
	.cs(ram_sel),
	.re(data_read),
	.we(data_write),
	.a(ram_addr),
	.d_in(core_data_out),
	.d_out(ram_bus_out)
);
/* !RAM */

/* DATA BUS IN DEMULTIPLEXER */
io_bus_dmux #(
	.NR_OF_BUSSES_IN(2)
	)
	ram_bus_dmux_inst(
	.bus_in({
	ram_bus_out,
	dat_pb_d_out
	}),
	.bus_out(core_data_in)
	);
/* !DATA BUS IN DEMULTIPLEXER */

/* ATMEGA CORE */

mega # (
	.PLATFORM(PLATFORM),
	.CORE_TYPE(`CORE_TYPE),
	.BOOT_ADDR(0),
	.ROM_ADDR_WIDTH(`ROM_ADDR_WIDTH),
	.RAM_ADDR_WIDTH(`BUS_ADDR_DATA_LEN + 1),
	.WATCHDOG_CNT_WIDTH(`WATCHDOG_CNT_WIDTH),/* If is 0 the watchdog is disabled */
	.VECTOR_INT_TABLE_SIZE(`VECTOR_INT_TABLE_SIZE),/* If is 0 the interrupt module is disabled */
	.NMI_VECTOR('h0000),// The vector to be call on NMI interrupt, vector 1.
	.REGS_REGISTERED("FALSE"),
	.COMASATE_MUL("TRUE")
	)atmega32u4_inst(
	.rst(core_rst),
	.sys_rst_out(wdt_rst),
	// Core clock.
	.clk(core_clk),
	// Watchdog clock input that can be different from the core clock.
	.clk_wdt(core_clk),
	// FLASH space data interface.
	.pgm_addr(pgm_addr),
	.pgm_data(pgm_data),
	// RAM space data interface.
	.data_addr(data_addr),
	.data_out(core_data_out),
	.data_write(data_write),
	.data_in(core_data_in),
	.data_read(data_read),
	// Interrupt lines from all IO's for ATmega32u4, we need to put them in order, at the bottom is the first.
	.int_sig({
	int_timer4_fpf, int_timer4_ovf, int_timer4_compd, int_timer4_compb, int_timer4_compa,
	int_spm_ready,
	int_twi,
	int_timer3_ovf, int_timer3_compc, int_timer3_compb, int_timer3_compa, int_timer3_capt,
	int_ee_ready,
	int_adc,
	int_analog_comp,
	int_usart1_tx, int_usart1_udre, int_usart1_rx,
	int_spi_stc,
	int_timer0_ovf, int_timer0_compb, int_timer0_compa,
	int_timer1_ovf, int_timer1_compc, int_timer1_compb, int_timer1_compa, int_timer1_capt, 
	int_reserved6, int_reserved5, int_reserved4,
	int_wdt,
	int_usb_endpoint, int_usb_general,
	int_pcint0,
	int_reserved3,
	int_int6,
	int_reserved1, int_reserved0,
	int_int3, int_int2, int_int1, int_int0,
	nmi_sig}
	),
	// Interrupt reset lines going to all IO's for ATmega32u4, we need to put them in order, at the bottom is the first.
	.int_rst({
	int_timer4_fpf_rst, int_timer4_ovf_rst, int_timer4_compd_rst, int_timer4_compb_rst, int_timer4_compa_rst,
	int_spm_ready_rst,
	int_twi_rst,
	int_timer3_ovf_rst, int_timer3_compc_rst, int_timer3_compb_rst, int_timer3_compa_rst, int_timer3_capt_rst,
	int_ee_ready_rst,
	int_adc_rst,
	int_analog_comp_rst,
	int_usart1_tx_rst, int_usart1_udre_rst, int_usart1_rx_rst,
	int_spi_stc_rst,
	int_timer0_ovf_rst, int_timer0_compb_rst, int_timer0_compa_rst,
	int_timer1_ovf_rst, int_timer1_compc_rst, int_timer1_compb_rst, int_timer1_compa_rst, int_timer1_capt_rst, 
	int_reserved6_rst, int_reserved5_rst, int_reserved4_rst,
	int_wdt_rst,
	int_usb_endpoint_rst, int_usb_general_rst,
	int_pcint0_rst,
	int_reserved3_rst,
	int_int6_rst,
	int_reserved1_rst, int_reserved0_rst,
	int_int3_rst, int_int2_rst, int_int1_rst, int_int0_rst,
	nmi_rst}
	)
);
/* !ATMEGA CORE */

endmodule