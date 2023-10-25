//-----------------------------------------------------------------------------
//
// Title       : VL53L_I2C_tb
// Design      : axi_head
// Author      : Adam
// Company     : AME
//
//-----------------------------------------------------------------------------
//
// File        : VL53L_I2C_TB.v
// Generated   : Sat Jan  7 12:26:53 2023
// From        : F:\Dyplomy\axi_head\axi_head\src\TestBench\VL53L_I2C_TB_settings.txt
// By          : tb_verilog.pl ver. ver 1.2s
//
//-----------------------------------------------------------------------------
//
// Description :
//
//-----------------------------------------------------------------------------

`timescale 1ns / 100ps

module I2C_tb;

//Internal signals declarations:
reg CLK;
reg CLR;
reg CE;
reg [2:0] CMD;
tri SCL;
tri SDA;
reg SDA_DRV;
//Continous assignment for inout port "SDA".
assign SDA = SDA_DRV;

wire RDY;
reg XC_RQ;
reg [7:0] DI;
wire [7:0] DQ;
reg ACK_I;
wire ACK_Q;

localparam [2:0]
    COMMAND_START = 0,
    COMMAND_STOP = 1,
    COMMAND_WR = 2,
    COMMAND_RD = 3,
    COMMAND_REPEAT_START = 4;

// Unit Under Test port map
i2c_controller_master_v2 UUT (
	.clk(CLK),
    .reset_n(~CLR),
	.divider(11'd4),
	.scl(SCL),
	.sda(SDA),
	.ready(RDY),
	.activate(XC_RQ),
	.command(CMD),
	.data_in(DI),
	.data_out(DQ),
	.ack(ACK_Q),
	.ack_i(ACK_I),
	.byte_processed());

I2C_SLV_BHV I2C_BHV(SCL, SDA);

pullup PU_SDA(SDA);
pullup PU_SCL(SCL);

initial begin
	SDA_DRV = 1'bz;
	CLR = 1'b1;
	DI = 8'hxx;
	ACK_I = 1'bx;
	XC_RQ = 1'b0;
	CMD = 3'bx;
	repeat(3) @(negedge CLK);
	I2C_BHV.LIST_DEV();
	CLR = 1'b0;
	repeat(3) @(negedge CLK);
	I2C_BHV.DATA_RD = 8'h55;
	/* Read Data from -> 0x21 */
	I2C_DO(8'h43, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0); /* address stage TX_ACK = 1 - allow ACK from slave */
	I2C_DO(8'hFF, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1); /* read data - Transmit all FF confirm - ACK - 0*/
	I2C_DO(8'hFF, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1); /* read data - Transmit all FF confirm - ACK - 1 (NAK)*/
	/* Write Data to -> 0x21 using repreated start */
	I2C_DO(8'h42, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0); /* address stage TX_ACK = 1, write with repeated start */
	I2C_DO(8'h55, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);
	I2C_DO(8'hAA, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);
	repeat(50) @(negedge CLK);
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

task I2C_DO;
input [7:0] DATA; //data or address + r/w
input ACK;
input REP_START;
input DO_STOP;
input DO_START;
input READ_WRITE;
begin
	wait(RDY);
	@(negedge CLK)
	DI = DATA;
	XC_RQ = 1'b1;
	if(DO_START) begin
	   CMD = COMMAND_START;
	   while(~RDY) @(negedge CLK);
       wait(RDY);
       @(negedge CLK)
       CMD = COMMAND_WR;
       XC_RQ = 1'b1;
       //wait for ack/nack
	end
	else begin
        while(~RDY) @(negedge CLK);
        wait(RDY);
        @(negedge CLK)
        if(READ_WRITE) begin
            CMD = COMMAND_RD;
            while(~RDY) @(negedge CLK);
            wait(RDY);
            @(negedge CLK)
            ACK_I = ACK;
        end
        else
            CMD = COMMAND_WR;
            XC_RQ = 1'b1;
            //wait for ack/nack
	end
    
	@(negedge CLK)
	XC_RQ = 1'b0;
	DI = 8'hxx;
	ACK_I = 1'bx;

	while(~RDY) @(negedge CLK);
	if(DO_STOP == 1'b1)
		$display("%6t: I2C Stop symbol sent", $time);
	else
		$display("%6t: I2C Data transaction completed [%h : %b <-> %h : %b]", $time, DATA, ACK, DQ, ACK_Q);
end
endtask

endmodule
