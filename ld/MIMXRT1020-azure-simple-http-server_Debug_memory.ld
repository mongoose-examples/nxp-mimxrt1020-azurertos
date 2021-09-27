/*
 * GENERATED FILE - DO NOT EDIT
 * Copyright (c) 2008-2013 Code Red Technologies Ltd,
 * Copyright 2015, 2018-2019 NXP
 * (c) NXP Semiconductors 2013-2021
 * Generated linker script file for MIMXRT1021xxxxx
 * Created from memory.ldt by FMCreateLinkMemory
 * Using Freemarker v2.3.30
 * MCUXpresso IDE v11.4.0 [Build 6237] [2021-08-06] on 22 Sep 2021, 3:02:20 PM
 */

MEMORY
{
  /* Define each memory region */
  BOARD_FLASH (rx) : ORIGIN = 0x60000000, LENGTH = 0x800000 /* 8M bytes (alias Flash) */  
  SRAM_DTC (rwx) : ORIGIN = 0x20000000, LENGTH = 0x10000 /* 64K bytes (alias RAM) */  
  NCACHE_REGION (rwx) : ORIGIN = 0x20200000, LENGTH = 0x20000 /* 128K bytes (alias RAM2) */  
  SRAM_ITC (rwx) : ORIGIN = 0x0, LENGTH = 0x10000 /* 64K bytes (alias RAM3) */  
  BOARD_SDRAM (rwx) : ORIGIN = 0x80000000, LENGTH = 0x2000000 /* 32M bytes (alias RAM4) */  
}

  /* Define a symbol for the top of each memory region */
  __base_BOARD_FLASH = 0x60000000  ; /* BOARD_FLASH */  
  __base_Flash = 0x60000000 ; /* Flash */  
  __top_BOARD_FLASH = 0x60000000 + 0x800000 ; /* 8M bytes */  
  __top_Flash = 0x60000000 + 0x800000 ; /* 8M bytes */  
  __base_SRAM_DTC = 0x20000000  ; /* SRAM_DTC */  
  __base_RAM = 0x20000000 ; /* RAM */  
  __top_SRAM_DTC = 0x20000000 + 0x10000 ; /* 64K bytes */  
  __top_RAM = 0x20000000 + 0x10000 ; /* 64K bytes */  
  __base_NCACHE_REGION = 0x20200000  ; /* NCACHE_REGION */  
  __base_RAM2 = 0x20200000 ; /* RAM2 */  
  __top_NCACHE_REGION = 0x20200000 + 0x20000 ; /* 128K bytes */  
  __top_RAM2 = 0x20200000 + 0x20000 ; /* 128K bytes */  
  __base_SRAM_ITC = 0x0  ; /* SRAM_ITC */  
  __base_RAM3 = 0x0 ; /* RAM3 */  
  __top_SRAM_ITC = 0x0 + 0x10000 ; /* 64K bytes */  
  __top_RAM3 = 0x0 + 0x10000 ; /* 64K bytes */  
  __base_BOARD_SDRAM = 0x80000000  ; /* BOARD_SDRAM */  
  __base_RAM4 = 0x80000000 ; /* RAM4 */  
  __top_BOARD_SDRAM = 0x80000000 + 0x2000000 ; /* 32M bytes */  
  __top_RAM4 = 0x80000000 + 0x2000000 ; /* 32M bytes */  
