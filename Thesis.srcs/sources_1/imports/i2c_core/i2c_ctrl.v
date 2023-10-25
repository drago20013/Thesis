`timescale 1ns / 100ps

module I2C_PHY(
	CLK, CLR,
	DV,
	SCL, SDA,
	RDY,
	XC_RQ, START, STOP,
	DI, DQ, ACK_I, ACK_Q);

parameter IDLE = 0;
parameter START_0 = 1;
parameter START_1 = 2;
parameter START_2 = 3;
parameter START_3 = 4;
parameter ACT = 5;
parameter XC_0 = 6;
parameter XC_1 = 7;
parameter XC_2 = 8;
parameter XC_3 = 9;
parameter STOP_0 = 10;
parameter STOP_1 = 11;
parameter STOP_2 = 12;
parameter STOP_3 = 13;

parameter FDV_W = 11;

input CLK, CLR;
input [FDV_W-1:0] DV;
output SCL;
inout SDA;
output RDY;
input XC_RQ, START, STOP;
input [7:0] DI;
output [7:0] DQ;
input ACK_I;
output ACK_Q;


reg [FDV_W-1:0] FDV;
wire FDV_EN;
wire CE;
reg [3:0] CTRL;

reg [3:0] BIT_CNT;
wire BIT_CE;
wire BIT_DONE;

reg [7:0] D_TX;
reg ACK_TX;

reg [7:0] D_RX;
reg ACK_RX;

reg SDA_DRV;
reg SCL_DRV;

always @(posedge CLK) begin
	if(CLR) begin
		CTRL <= IDLE;
	end
	else begin
	case(CTRL)
	IDLE:
		if(XC_RQ) CTRL <= START_0;
	START_0:
		if(CE) CTRL <= START_1;
	START_1:
		if(CE) CTRL <= START_2;
	START_2:
		if(CE) CTRL <= START_3;
	START_3:
		if(CE) CTRL <= XC_0;
	ACT:
		if(XC_RQ) begin
			case(1'b1) /* synthesis parallel_case */
			STOP: CTRL <= STOP_0;
			START: CTRL <= START_0;
			default: CTRL <= XC_0;
			endcase
		end
	XC_0:
		if(CE) CTRL <= XC_1;
	XC_1:
		if(CE) CTRL <= XC_2;
	XC_2:
		if(CE) CTRL <= XC_3;
	XC_3:
		if(CE)
			CTRL <= BIT_DONE ? ACT : XC_0;
	STOP_0:
		if(CE) CTRL <= STOP_1;
	STOP_1:
		if(CE) CTRL <= IDLE;
	endcase
	end
	FDV <= ((FDV_EN & ~FDV[10]) ? FDV : DV) + {FDV_W{1'b1}};
	BIT_CNT <= 	(RDY ? 4'd0 : BIT_CNT) + {3'b000, BIT_CE};
	//TX Shift register
	if((CTRL == IDLE) | (CTRL == ACT)) begin
		D_TX <= DI;
		ACK_TX <= ACK_I;
	end
	else if(CE & (CTRL == XC_3)) begin
		D_TX <= {D_TX[6:0], ACK_TX};
		ACK_TX <= 1'b1;
	end
	//RX Shift register
	if(CE & (CTRL == XC_2))
		{D_RX, ACK_RX} <= {D_RX[6:0], ACK_RX, SDA};
	SDA_DRV <= 1'b1;
	case(CTRL)
		START_1, START_2, START_3:
			SDA_DRV <= 1'b0;
		XC_0, XC_1, XC_2, XC_3:
			SDA_DRV <= D_TX[7];
		STOP_0:
			SDA_DRV <= 1'b0;
	endcase
	SCL_DRV <= 1'b1;
	case(CTRL)
		START_3: SCL_DRV <= 1'b0;
		ACT: SCL_DRV <= 1'b0;
		XC_0: SCL_DRV <= 1'b0;
		XC_3: SCL_DRV <= 1'b0;
	endcase
end

assign RDY = (CTRL == IDLE) | (CTRL == ACT);
assign FDV_EN = ~RDY;
assign CE = FDV[FDV_W-1];
assign BIT_CE = CE & (CTRL == XC_2);
assign BIT_DONE = BIT_CNT[3] & BIT_CNT[0];

assign DQ = D_RX;
assign ACK_Q = ACK_RX;

assign SDA = SDA_DRV ? 1'bz : 1'b0;
assign SCL = SCL_DRV ? 1'bz : 1'b0;

/* synthesis translate_off */
pullup PU_SDA(SDA);
pullup PU_SCL(SCL);
/* synthesis translate_on */

endmodule


