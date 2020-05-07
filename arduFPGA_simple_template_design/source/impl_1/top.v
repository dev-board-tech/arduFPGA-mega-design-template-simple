/*
 * This IP is the top module for a simple template implementation.
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

module top (
	input clk,
	output RGB0, 
	output RGB1, 
	output RGB2, 
	input BTN_UP,
	input BTN_DN,
	input BTN_BACK,
	input BTN_OK,
	input BTN_INTERRUPT
	);

wire pll_locked;
wire sys_clk;
/* We use the 'pll_locked' signal from the PLL to release the CORE and IO RESET line. */
wire sys_rst = ~pll_locked;
wire [2:0]LED;

/* PLL Instance */
PLL_DEV PLL_inst(
	.ref_clk_i(clk), 
	.rst_n_i(1'b1), 
	.lock_o(pll_locked), 
	.outcore_o(), 
	.outglobal_o(sys_clk) 
);
/* !PLL Instance */
 

/* CORE Instance */
core # (
	.PLATFORM("iCE40UP"),
	.ROM_PATH("simple_app")
)core_instance(
	.core_rst(sys_rst),
	.core_clk(sys_clk),
    .RGB_LED(LED),
	.BTN_UP(BTN_UP),
	.BTN_DN(BTN_DN),
	.BTN_BACK(BTN_BACK),
	.BTN_OK(BTN_OK),
	.BTN_INTERRUPT(BTN_INTERRUPT)
);
/* !CORE Instance */

/* RGB LED output drivers. */
BB_OD LED_B_Inst (
  .T_N (1'b1),  // I
  .I   (~LED[2]),  // I
  .O   (),  // O
  .B   (RGB2)   // IO
);
BB_OD LED_G_Inst (
  .T_N (1'b1),  // I
  .I   (~LED[1]),  // I
  .O   (),  // O
  .B   (RGB1)   // IO
);
BB_OD LED_R_Inst (
  .T_N (1'b1),  // I
  .I   (~LED[0]),  // I
  .O   (),  // O
  .B   (RGB0)   // IO
);
/* !RGB LED output drivers. */
endmodule