// ARTY-S7
`timescale 1ns/100ps
module TV80_S7(
	CLK, nCLR,	
	LED, SW, PB,
	LED_RGB_0, LED_RGB_1,
	RXD, TXD, SDA, SCL);
	
input CLK, nCLR;
output [3:0] LED;
input [3:0] SW;
input [3:0] PB;
output [2:0] LED_RGB_0;
output [2:0] LED_RGB_1;
input RXD;
output TXD;
inout SCL;
inout SDA;

//Internal signals
wire [15:0] ADDR;
reg [7:0] DI;
wire [7:0] DO;
wire nRD, nWR;
wire nMREQ, nIORQ;
wire nWAIT;
wire nWAIT1;
wire nWAIT2;
wire nWAIT3;
wire nM1;
wire nINT;
wire [2:0] TS;

wire [7:0] ROM_0_DQ;
wire [7:0] RAM_0_DQ;
wire [7:0] P0_DQ;
wire [7:0] P1_DQ;
wire [7:0] P2_DQ;
wire [7:0] P3_DQ;
wire [7:0] P4_DQ;
wire [7:0] I2C_DQ1;
wire [7:0] I2C_DQ2;
wire [7:0] I2C_DQ3;

TV80_CPU CPU_0 (
	.CLK(CLK),
	.nCLR(nCLR),
	.CE(1'b1),
	.ADDR(ADDR),
	.DI(DI),
	.DO(DO),
	.nRD(nRD),
	.nWR(nWR),
	.nMREQ(nMREQ),
	.nIORQ(nIORQ),
	.nBUSRQ(1'b1),
	.nBUSAK(),
	.nWAIT(nWAIT),
	.nINT(nINT),
	.nM1(nM1),
	.TS(TS));
	
assign nINT = 1'b1; //currently no int
//assign nWAIT = nWAIT2;
assign nWAIT = (nWAIT1 && nWAIT2 && nWAIT3);
	
always @(ADDR or nMREQ or nIORQ or ROM_0_DQ or RAM_0_DQ or P0_DQ or P1_DQ or P2_DQ or P3_DQ or P4_DQ or I2C_DQ1 or I2C_DQ2) begin	
	DI = 8'hxx; //don't care
	case(1'b0) /* synthesis parallel_case full_case */
	nMREQ: begin
		case(ADDR[15:11])
		5'b0000_0: DI = ROM_0_DQ;
		5'b0000_1: DI = RAM_0_DQ;		
		endcase
	end
	nIORQ: begin
		case(ADDR[7:0])
		8'h20: DI = P0_DQ; //Push buttons
		8'h21: DI = P1_DQ;
		8'h30: DI = P2_DQ;
		8'h40: DI = P3_DQ;
		8'h41: DI = P4_DQ;
		8'h50: DI = I2C_DQ1;
		8'h51: DI = I2C_DQ2;
		8'h52: DI = I2C_DQ3;
		endcase
	end
	default: DI = 8'h00;
	endcase	
end

//ROM 2kB - 0000:07FF
ROMB ROM_0(.CLK(CLK), .A(ADDR[10:0]), .DQ(ROM_0_DQ));

//RAM 2kB - 0800:0FFF
wire RAM_0_WE = ~nMREQ & ~nWR & (ADDR[15:11] == 5'b00001);
RAMB RAM_0(.CLK(CLK), .A(ADDR[10:0]), .WE(RAM_0_WE), .DI(DI), .DQ(RAM_0_DQ));

//IO Ports
wire P0_RD = ~nIORQ & ~nRD & (ADDR[7:0] == 8'h20);
PORT_IN	#(.W(4))P_IN_0(.CLK(CLK), .RD(P0_RD), .DQ(P0_DQ), .PORT(PB));

wire P1_RD = ~nIORQ & ~nRD & (ADDR[7:0] == 8'h21);
PORT_IN	#(.W(4))P_IN_1(.CLK(CLK), .RD(P1_RD), .DQ(P1_DQ), .PORT(SW));

wire I2C_SEL22 = ~nIORQ & (ADDR[7:0] == 8'h50);
PORT_I2C PCF_22(.ADDR(7'h22), .CLK(CLK), .nCLR(nCLR), .EN(I2C_SEL22), .nRD(nRD), .nWR(nWR), .DI(DO), .DQ(I2C_DQ1), .SDA(SDA), .SCL(SCL), .nWAIT(nWAIT1));

wire I2C_SEL21 = ~nIORQ & (ADDR[7:0] == 8'h51);
PORT_I2C PCF_21(.ADDR(7'h21), .CLK(CLK), .nCLR(nCLR), .EN(I2C_SEL21), .nRD(nRD), .nWR(nWR), .DI(DO), .DQ(I2C_DQ2), .SDA(SDA), .SCL(SCL), .nWAIT(nWAIT2));

wire I2C_SEL20 = ~nIORQ & (ADDR[7:0] == 8'h52);
PORT_I2C PCF_20(.ADDR(7'h20), .CLK(CLK), .nCLR(nCLR), .EN(I2C_SEL20), .nRD(nRD), .nWR(nWR), .DI(DO), .DQ(I2C_DQ3), .SDA(SDA), .SCL(SCL), .nWAIT(nWAIT3));

wire P2_WR = ~nIORQ & ~nWR & (ADDR[7:0] == 8'h30);
PORT_OUT #(.W(4))P_OUT_0(.CLK(CLK), .WR(P2_WR), .DI(DO), .DQ(P2_DQ), .PORT(LED));

wire P3_WR = ~nIORQ & ~nWR & (ADDR[7:0] == 8'h40);
PORT_OUT #(.W(3))P_OUT_1(.CLK(CLK), .WR(P3_WR), .DI(DO), .DQ(P3_DQ), .PORT(LED_RGB_0));
wire P4_WR = ~nIORQ & ~nWR & (ADDR[7:0] == 8'h41);
PORT_OUT #(.W(3))P_OUT_2(.CLK(CLK), .WR(P4_WR), .DI(DO), .DQ(P4_DQ), .PORT(LED_RGB_1));

//UART module - diagnostic and communication
assign TXD = 1'b1;

endmodule

module ROMB(CLK, A, DQ);
input CLK;
input [10:0] A;
output reg [7:0] DQ;
reg [7:0] AQ;
	
always @(posedge CLK)	
	AQ <= A;
	
//Prograram
`include "8085_instr_set.v"
always @(AQ) begin
	case(AQ)
	0: DQ = `LXI_SP;
    1: DQ = 8'h00;
    2: DQ = 8'h10;
    3: DQ = `IN; //IN PCF22
    4: DQ = 8'h50;
    5: DQ = `CMA;
    6: DQ = `MOV_B_A;
    7: DQ = `OUT;
    8: DQ = 8'h30; 
    
    9: DQ = `IN; //IN SW
    10: DQ = 8'h21;
    11: DQ = `ORA_B;
    12: DQ = `CMA;
    13: DQ = `ANI;
    14: DQ = 8'b0000_1111;
    15: DQ = `OUT;
    16: DQ = 8'h52;
    
    17: DQ = `JMP;
    18: DQ = 8'd3;
    19: DQ = 8'd0;
    
//    3: DQ = `MVI_A;
//    4: DQ = 8'hFF;
//    5: DQ = `OUT;
//    6: DQ = 8'h30;
//    7: DQ = `CALL;
//    8: DQ = 8'd99;
//    9: DQ = 8'd0;
    
//    10: DQ = `MVI_A;
//    11: DQ = 8'h00;
//    12: DQ = `OUT;
//    13: DQ = 8'h30;
//    14: DQ = `CALL;
//    15: DQ = 8'd99;
//    16: DQ = 8'd0;
    
//    17: DQ = `JMP;
//    18: DQ = 8'd3;
//    19: DQ = 8'd0;
    
//    //DELAY
    
//    99: DQ = `PUSH_PSW;
//    100: DQ = `MVI_B;
//    101: DQ = 8'h0a;
//    102: DQ = `MVI_D;
//    103: DQ = 8'h00;
//    //DELAY_LOOP:
//    104: DQ = `DCR_B;
//    105: DQ = `JNZ;
//    106: DQ = 8'h30;
//    107: DQ = 8'h01;
//    108: DQ = `DCR_D;
//    109: DQ = `JNZ;
//    110: DQ = 8'd104;
//    111: DQ = 8'd0;
//    112: DQ = `POP_PSW;
//    113: DQ = `RET;

    //INIT LCD
    //BYTE 1 Initialization of 16X2 LCD in 8bit mode
//    3: DQ = `MVI_A;
//    4: DQ = 8'h38;
//    5: DQ = `OUT;
//    6: DQ = 8'h51;
    
//    7: DQ = `MVI_A;
//    8: DQ = 8'b1000_0000;
//    9: DQ = `OUT;
//    10: DQ = 8'h52;
    
//    11: DQ = `CALL;
//    12: DQ = 8'd200;
//    13: DQ = 8'd0;
    
//    14: DQ = `MVI_A;
//    15: DQ = 8'b0000_0000;
//    16: DQ = `OUT;
//    17: DQ = 8'h52;
    
//    18: DQ = `CALL;
//    19: DQ = 8'h2C;
//    20: DQ = 8'h01;
    
//    //BYTE 2 Display ON Cursor OFF
//    21: DQ = `MVI_A;
//    22: DQ = 8'h0C;
//    23: DQ = `OUT;
//    24: DQ = 8'h51;
    
//    25: DQ = `MVI_A;
//    26: DQ = 8'b1000_0000;
//    27: DQ = `OUT;
//    28: DQ = 8'h52;
    
//    29: DQ = `CALL;
//    30: DQ = 8'd200;
//    31: DQ = 8'd0;
    
//    32: DQ = `MVI_A;
//    33: DQ = 8'b0000_0000;
//    34: DQ = `OUT;
//    35: DQ = 8'h52;
    
//    36: DQ = `CALL;
//    37: DQ = 8'h2C;
//    38: DQ = 8'h01;
    
//    //BYTE 3 Auto Increment cursor
//    39: DQ = `MVI_A;
//    40: DQ = 8'h06;
//    41: DQ = `OUT;
//    42: DQ = 8'h51;
    
//    43: DQ = `MVI_A;
//    44: DQ = 8'b1000_0000;
//    45: DQ = `OUT;
//    46: DQ = 8'h52;
    
//    47: DQ = `CALL;
//    48: DQ = 8'd200;
//    49: DQ = 8'd0;
    
//    50: DQ = `MVI_A;
//    51: DQ = 8'b0000_0000;
//    52: DQ = `OUT;
//    53: DQ = 8'h52;
    
//    54: DQ = `CALL;
//    55: DQ = 8'h2C;
//    56: DQ = 8'h01;
    
//    //BYTE 4 Clear display
//    57: DQ = `MVI_A;
//    58: DQ = 8'h01;
//    59: DQ = `OUT;
//    60: DQ = 8'h51;
    
//    61: DQ = `MVI_A;
//    62: DQ = 8'b1000_0000;
//    63: DQ = `OUT;
//    64: DQ = 8'h52;
    
//    65: DQ = `CALL;
//    66: DQ = 8'd200;
//    67: DQ = 8'd0;
    
//    68: DQ = `MVI_A;
//    69: DQ = 8'b0000_0000;
//    70: DQ = `OUT;
//    71: DQ = 8'h52;
    
//    72: DQ = `CALL;
//    73: DQ = 8'h2C;
//    74: DQ = 8'h01;

//    //BYTE 5 Cursor at home position
//    75: DQ = `MVI_A;
//    76: DQ = 8'h80;
//    77: DQ = `OUT;
//    78: DQ = 8'h51;
    
//    79: DQ = `MVI_A;
//    80: DQ = 8'b1000_0000;
//    81: DQ = `OUT;
//    82: DQ = 8'h52;
    
//    83: DQ = `CALL;
//    84: DQ = 8'd200;
//    85: DQ = 8'd0;
    
//    86: DQ = `MVI_A;
//    87: DQ = 8'b0000_0000;
//    88: DQ = `OUT;
//    89: DQ = 8'h52;
    
//    90: DQ = `CALL;
//    91: DQ = 8'h2C;
//    92: DQ = 8'h01;
    
//    //BYTE 6 Character "H"
//    93: DQ = `MVI_A;
//    94: DQ = 8'h48;
//    95: DQ = `OUT;
//    96: DQ = 8'h51;
    
//    97: DQ = `MVI_A;
//    98: DQ = 8'b1010_0000;
//    99: DQ = `OUT;
//    100: DQ = 8'h52;
    
//    101: DQ = `CALL;
//    102: DQ = 8'd200;
//    103: DQ = 8'd0;
    
//    104: DQ = `MVI_A;
//    105: DQ = 8'b0010_0000;
//    106: DQ = `OUT;
//    107: DQ = 8'h52;
    
//    108: DQ = `CALL;
//    109: DQ = 8'h2C;
//    110: DQ = 8'h01;

//    111: DQ = `IN; //IN PCF22
//    112: DQ = 8'h50;
//    113: DQ = `CMA;
//    114: DQ = `MOV_B_A;
//    115: DQ = `OUT;
//    116: DQ = 8'h30;  
    
//    116: DQ = `IN; //IN PB
//    117: DQ = 8'h21;
//    118: DQ = `ORA_B;
//    119: DQ = `CMA;
//    120: DQ = `ANI;
//    121: DQ = 8'b0000_1111;
//    122: DQ = `OUT;
//    123: DQ = 8'h52;
     
//    124: DQ = `JMP;
//    125: DQ = 8'd3;
//    126: DQ = 8'd0;
    
//    //DELAY 1MS
//    200: DQ = `MVI_C;
//    201: DQ = 8'hC7;
//    202: DQ = `MVI_B;
//    203: DQ = 8'h2F;
//    //DELAY_LOOP:
//    204: DQ = `DCR_C;
//    205: DQ = `JNZ;
//    206: DQ = 8'd204;
//    207: DQ = 8'd00;
//    208: DQ = `DCR_B;
//    209: DQ = `JNZ;
//    210: DQ = 8'd204;
//    211: DQ = 8'd00;
//    212: DQ = `RET;

//    //DELAY 5MS
//    300: DQ = `MVI_C;
//    301: DQ = 8'h30;
//    302: DQ = `MVI_B;
//    303: DQ = 8'h3A;
//    //DELAY_LOOP:
//    304: DQ = `DCR_C;
//    305: DQ = `JNZ;
//    306: DQ = 8'h30;
//    307: DQ = 8'h01;
//    308: DQ = `DCR_B;
//    309: DQ = `JNZ;
//    310: DQ = 8'h30;
//    311: DQ = 8'h01;
//    312: DQ = `RET;
    
    default: DQ = `NOP;  
	endcase	
end	
	
endmodule


module RAMB(CLK, A, WE, DI, DQ);
input CLK;
input [10:0] A;
input WE;
input [7:0] DI;
output [7:0] DQ;

reg [7:0] MEM [2047:0];
reg [10:0] AQ;

always @(posedge CLK) begin
	AQ <= A;
	if(WE) MEM[A] <= DI;
end
	
assign DQ = MEM[AQ];

endmodule

module PORT_I2C(ADDR, CLK, nCLR, EN, nRD, nWR, DI, DQ, SDA, SCL, nWAIT);
input [6:0] ADDR;
input CLK;
input nCLR;
input EN;
input nRD;
input nWR;
input [7:0] DI;
output [7:0] DQ;
inout SDA;
inout SCL;
output reg nWAIT;

localparam [3:0]
    STATE_IDLE = 0,
    STATE_START = 1,
    STATE_ADDRESING = 2,
    STATE_WAIT_ACK = 3,
    STATE_ACK_AFTER_READ = 4,
    STATE_WAIT_ACK_AFTER_WRITE = 5,
    STATE_READ = 6,
    STATE_WRITE = 7,
    STATE_STOP = 8,
    STATE_CLEAR_WAIT = 9;
    
localparam [1:0]
    COMMAND_START = 0,
    COMMAND_STOP = 1,
    COMMAND_WR = 2,
    COMMAND_RD = 3;

//Internal signals declarations:
reg [1:0] CMD;
reg [7:0] I2C_DI;
wire [7:0] I2C_DQ;
reg [3:0] TRANSACTION_STATE;
reg change_state;
reg ff;
reg ff_delayed;

wire RDY;
reg XC_RQ;
reg ACK_I;
reg DO_READ, DO_WRITE;
wire ACK_Q;
wire BYTE_DONE;
reg [7:0] TO_WRITE;

i2c_controller_master_v2 I2C_MASTER (
	.clk(CLK),
    .reset_n(nCLR),
	.divider(11'd30),
	.scl(SCL),
	.sda(SDA),
	.ready(RDY),
	.activate(XC_RQ),
	.command(CMD),
	.data_in(I2C_DI),
	.data_out(I2C_DQ),
	.ack(ACK_Q),
	.ack_i(ACK_I),
	.byte_processed(BYTE_DONE));
	
assign DQ = I2C_DQ;

always @(posedge CLK  or negedge nCLR) begin
    if (!nCLR) begin
        TRANSACTION_STATE <= 0;
        I2C_DI <= 0;
        XC_RQ <= 0;
        ACK_I <= 1;
        CMD <= 0;
        DO_READ <= 0;
        DO_WRITE <= 0;
        ff <= 0;
        ff_delayed <= 0;
        change_state <= 0;
        nWAIT <= 1;
        TO_WRITE <= 8'hff;
    end else begin        
        ff <= ~RDY;
        ff_delayed <= ff;
        change_state <= (ff && ~ff_delayed);
    
        case (TRANSACTION_STATE)
            STATE_IDLE:
                begin
                    if (EN && RDY) begin
                    nWAIT <= 1;
                        if (~nRD) begin
                            DO_READ <= 1;
                        end else if (~nWR) begin
                            DO_WRITE <= 1;
                        end
                        TRANSACTION_STATE <= STATE_START;
                    end
                end
            STATE_START:
                begin
                    nWAIT <= 0;
                    if (~change_state) begin
                        CMD <= COMMAND_START;
                        TO_WRITE <= DI;
                        XC_RQ <= 1'b1;
                        TRANSACTION_STATE <= STATE_ADDRESING;
                    end
                end
            STATE_ADDRESING:
                begin
                    nWAIT <= 0;
                    if (change_state) begin
                        XC_RQ <= 1'b1;
                        if (DO_READ) begin
                            I2C_DI <= {ADDR, 1'b1};
                        end else if (DO_WRITE) begin
                            I2C_DI <= {ADDR, 1'b0};
                        end
                        CMD <= COMMAND_WR;
                        TRANSACTION_STATE <= STATE_WAIT_ACK;
                    end
                end
            STATE_WAIT_ACK:
                begin
                    nWAIT <= 0;
                    if(BYTE_DONE) begin
                        if (~ACK_Q) begin
                            if (DO_READ) begin
                                I2C_DI <= 8'hff;
                                TRANSACTION_STATE <= STATE_READ;
                            end else if (DO_WRITE) begin
                                ACK_I <= 1;
                                I2C_DI <= TO_WRITE;
                                TRANSACTION_STATE <= STATE_WRITE;
                            end
                        end else begin
                            TRANSACTION_STATE <= STATE_STOP;
                        end
                    end
                end
            STATE_ACK_AFTER_READ:
                begin
                    if(BYTE_DONE) begin
                        nWAIT <= 0;
                        ACK_I <= 0;
                        CMD <= COMMAND_STOP;
                        TRANSACTION_STATE <= STATE_STOP;
                        I2C_DI <= 8'hxx;
                    end
                end
            STATE_WAIT_ACK_AFTER_WRITE:
                begin
                    if(BYTE_DONE) begin
                        nWAIT <= 0;
                        CMD <= COMMAND_STOP;
                        TRANSACTION_STATE <= STATE_STOP;
                    end
                end
            STATE_READ:
                begin
                    nWAIT <= 0;
                    if (change_state) begin
                        CMD <= COMMAND_RD;
                        XC_RQ <= 1'b1;
                        TRANSACTION_STATE <= STATE_ACK_AFTER_READ;
                    end
                end
            STATE_WRITE:
                begin
                    nWAIT <= 0;
                    if (change_state) begin
                        CMD <= COMMAND_WR;
                        XC_RQ <= 1'b1;
                        TRANSACTION_STATE <= STATE_WAIT_ACK_AFTER_WRITE;
                    end
                end
            STATE_STOP:
                begin
                    nWAIT <= 0;
                    if(change_state) begin
                        XC_RQ <= 1'b1;
                        DO_READ <= 0;
                        DO_WRITE <= 0;
                        TRANSACTION_STATE <= STATE_CLEAR_WAIT;
                    end
                end
            STATE_CLEAR_WAIT:
                begin
                    if (RDY) begin
                        nWAIT <= 1;
                        TRANSACTION_STATE <= STATE_IDLE;
                    end
                end
            default: TRANSACTION_STATE <= STATE_IDLE;
        endcase
    end
end
endmodule

//W-bit port
module PORT_IN(CLK, RD, DQ, PORT);
parameter W = 8;	
input CLK;
input RD;
output [7:0] DQ;
input [W-1:0] PORT;
reg [W-1:0] PQ;

always @(posedge CLK)
	if(~RD) PQ <= PORT;	

assign DQ = {{(8 - W){1'b0}}, PQ};
		
endmodule

module PORT_OUT(CLK, WR, DI, DQ, PORT);
parameter W = 8;
input CLK;
input WR;
input [7:0] DI; 
output [7:0] DQ;
output reg [W-1:0] PORT;
	
always @(posedge CLK)
	if(WR) PORT <= DI[W-1:0];
		
assign DQ = {{(8 - W){1'b0}}, PORT};
	
endmodule