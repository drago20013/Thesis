`timescale 1ns / 100ps
module I2C_tb2;

//Internal signals declarations:
reg CLK;
reg nCLR;
tri SCL;
tri SDA;
reg SDA_DRV;
//Continous assignment for inout port "SDA".
assign SDA = SDA_DRV;

reg [7:0] DO;
reg nRD, nWR;
wire nWAIT;
wire [7:0] I2C_DQ;
reg EN;

// Unit Under Test port map
PORT_I2C PCF_22(.ADDR(7'h21), .CLK(CLK), .nCLR(nCLR), .EN(EN), .nRD(nRD), .nWR(nWR), .DI(DO), .DQ(I2C_DQ), .SDA(SDA), .SCL(SCL), .nWAIT(nWAIT));

I2C_SLV_BHV I2C_BHV(SCL, SDA);

pullup PU_SDA(SDA);
pullup PU_SCL(SCL);

initial begin
	SDA_DRV = 1'bz;
	nCLR = 1'b1;
	nRD = 1;
	nWR = 1;
	EN = 0;
	DO = 0;
	repeat(3) @(negedge CLK);
	I2C_BHV.LIST_DEV();
	nCLR = 1'b0;
	repeat(3) @(negedge CLK);
	nCLR = 1'b1;
	I2C_BHV.DATA_RD = 8'h69; //Set data to be sent from slave, master RD operation
	/* Read Data from -> 0x21 */
	@(negedge CLK);
	EN = 1;
	nRD = 0;
//	/* Write Data to -> 0x21 using repreated start */
    @(posedge nWAIT);
        EN = 0;
        nRD = 1;
    repeat(10) @(negedge CLK);
        EN = 1;
        DO = 8'h27;
        nWR = 0;
    @(posedge nWAIT)
        EN = 0;
        nWR = 1;
	repeat(100) @(negedge CLK);
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
