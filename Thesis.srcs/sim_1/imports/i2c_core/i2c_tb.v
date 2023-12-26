`timescale 1ns / 100ps

module I2C_tb;

//Internal signals declarations:
reg CLK;
reg CLR;
reg [1:0] CMD;
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

localparam [1:0]
    COMMAND_START = 0,
    COMMAND_STOP = 1,
    COMMAND_WR = 2,
    COMMAND_RD = 3;

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
	CMD = 2'bx;
	repeat(3) @(negedge CLK);
	I2C_BHV.LIST_DEV();
	CLR = 1'b0;
	repeat(3) @(negedge CLK);
	I2C_BHV.DATA_RD = 8'h55; //Set data to be sent from slave, master RD operation
	/* Read Data from -> 0x21 */
	I2C_DO(8'h43, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0); /* address stage TX_ACK = 1 - allow ACK from slave */
	I2C_DO(8'hFF, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0); /* read data - Transmit all FF confirm - ACK - 0*/
	I2C_DO(8'hFF, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0); /* read data - Transmit all FF confirm - ACK - 0*/
	I2C_DO(8'hFF, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0); /* read data - Transmit all FF confirm - ACK - 1 (NAK)*/
//	/* Write Data to -> 0x21 using repreated start */
	I2C_DO(8'h42, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0); /* address stage TX_ACK = 1 - allow ACK from slave. Write with repeted start */
	I2C_DO(8'h55, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1);
	I2C_DO(8'hAA, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1);
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
input DO_STOP;
input DO_START;
input DO_READ;
input DO_WRITE;
begin
	//IF start send addr+r/w
	if(DO_START) begin
		wait(RDY);
        @(negedge CLK)
        CMD = COMMAND_START;
        XC_RQ = 1'b1;
        ACK_I = ACK;
        wait(~RDY) @(negedge CLK);
        XC_RQ = 1'b0;
        DI = 8'hxx;
        ACK_I = 1'bx;
        CMD = 2'bxx;
        wait(RDY);
        XC_RQ = 1'b1;
        DI = DATA;
        CMD = COMMAND_WR;
        wait(~RDY) @(negedge CLK);
        XC_RQ = 1'b0;
        DI = 8'hxx;
        CMD = 2'bxx;
        ACK_I = 1'bx;
    end

    if(DO_READ) begin
        wait(RDY);
        @(negedge CLK)
        CMD = COMMAND_RD;
        DI = DATA;
        ACK_I = ACK;
        XC_RQ = 1'b1;
        wait(~RDY) @(negedge CLK);
        XC_RQ = 1'b0;
        DI = 8'hxx;
        CMD = 2'bxx;
        ACK_I = 1'bx;
    end
    else if(DO_WRITE) begin
        wait(RDY);
        @(negedge CLK)
        CMD = COMMAND_WR;
        DI = DATA;
        XC_RQ = 1'b1;
        ACK_I = ACK;
        wait(~RDY) @(negedge CLK);
        XC_RQ = 1'b0;
        DI = 8'hxx;
        CMD = 2'bxx;
        ACK_I = 1'bx;
    end
    
    if(DO_STOP) begin
        wait(RDY);
        @(negedge CLK)
        CMD = COMMAND_STOP;
        XC_RQ = 1'b1;
        ACK_I = ACK;
        wait(~RDY) @(negedge CLK);
        XC_RQ = 1'b0;
        DI = 8'hxx;
        ACK_I = 1'bx;
        CMD = 2'bxx;
    end
   
	while(~RDY) @(negedge CLK);
	if(DO_STOP == 1'b1)
		$display("%6t: I2C Stop symbol sent", $time);
	else
		$display("%6t: I2C Data transaction completed [%h : %b <-> %h : %b]", $time, DATA, ACK, DQ, ACK_Q);
end
endtask

endmodule
