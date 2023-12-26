`timescale 1ns / 100ps
module I2C_tb3;

//Internal signals declarations:
reg CLK;
reg nCLR;
tri SCL;
tri SDA;

wire [3:0] LED;
reg [3:0] SW;
reg [3:0] PB;
wire [2:0] LED_RGB_0;
wire [2:0] LED_RGB_1;
reg RXD;
wire TXD;

// Unit Under Test port map
TV80_S7 TV80(
	CLK, nCLR,	
	LED, SW, PB,
	LED_RGB_0, LED_RGB_1,
	RXD, TXD, SDA, SCL);
	
I2C_SLV_BHV I2C_BHV(SCL, SDA);

pullup PU_SDA(SDA);
pullup PU_SCL(SCL);

initial begin
	nCLR = 1'b1;
	PB = 4'b1010;
	SW = 4'b0101;
	repeat(3) @(negedge CLK);
	I2C_BHV.LIST_DEV();
	nCLR = 1'b0;
    I2C_BHV.DATA_RD = 8'h69; //Set data to be sent from slave, master RD operation
	repeat(3) @(negedge CLK);
	nCLR = 1'b1;


	repeat(1000) @(negedge CLK);
	$finish;
end

initial begin
	CLK = 1'b0;
	forever #5 CLK = ~CLK;
end

initial begin
	$dumpfile("i2c.vcd");
	$dumpvars();
end
endmodule
