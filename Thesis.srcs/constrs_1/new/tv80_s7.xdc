## Clock Signals
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports CLK]
create_clock -period 83.333 -name sys_clk_pin -waveform {0.000 41.667} -add [get_ports CLK]
#set_property -dict { PACKAGE_PIN R2    IOSTANDARD SSTL135 } [get_ports { CLK }]; #IO_L12P_T1_MRCC_34 Sch=ddr3_clk[200]
#create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5.000}  [get_ports { CLK }];

# nCLR
set_property -dict {PACKAGE_PIN C18 IOSTANDARD LVCMOS33} [get_ports nCLR]

## Switches
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports {SW[0]}]
set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS33} [get_ports {SW[1]}]
set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports {SW[2]}]
set_property -dict {PACKAGE_PIN M5 IOSTANDARD SSTL135} [get_ports {SW[3]}]

## RGB LEDs
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {LED_RGB_0[0]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {LED_RGB_0[1]}]
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports {LED_RGB_0[2]}]
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports {LED_RGB_1[0]}]
set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33} [get_ports {LED_RGB_1[1]}]
set_property -dict {PACKAGE_PIN E14 IOSTANDARD LVCMOS33} [get_ports {LED_RGB_1[2]}]

## LEDs
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports {LED[0]}]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports {LED[1]}]
set_property -dict {PACKAGE_PIN E13 IOSTANDARD LVCMOS33} [get_ports {LED[2]}]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports {LED[3]}]

## Buttons
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {PB[0]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {PB[1]}]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports {PB[2]}]
set_property -dict {PACKAGE_PIN H13 IOSTANDARD LVCMOS33} [get_ports {PB[3]}]

## USB-UART Interface
set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports TXD]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports RXD]

## Pmod Header JD
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports SDA]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports SCL]
#set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports { INT1 }]; #IO_L22N_T3_A04_D20_14 Sch=jd7/ck_io[29]
#set_property -dict { PACKAGE_PIN R11   IOSTANDARD LVCMOS33 } [get_ports { INT2 }]; #IO_L23P_T3_A03_D19_14 Sch=jd8/ck_io[28]
#set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { INT3 }]; #IO_L23N_T3_A02_D18_14 Sch=jd9/ck_io[27]

## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

## SW3 is assigned to a pin M5 in the 1.35v bank. This pin can also be used as
## the VREF for BANK 34. To ensure that SW3 does not define the reference voltage
## and to be able to use this pin as an ordinary I/O the following property must
## be set to enable an internal VREF for BANK 34. Since a 1.35v supply is being
## used the internal reference is set to half that value (i.e. 0.675v). Note that
## this property must be set even if SW3 is not used in the design.
set_property INTERNAL_VREF 0.675 [get_iobanks 34]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
