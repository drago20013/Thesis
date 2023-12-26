`timescale 1ns / 100ps

module MCS85_INSTR(CLK, nM1, nRD, nWAIT, A, D);
input CLK;
input nM1, nRD, nWAIT;
input [15:0] A;
input [7:0] D;

reg [3:0] PREFIX;

initial begin
	$display("%m");
	PREFIX = 4'd0;
end

always @(posedge CLK) begin
	if(~nM1 & ~nRD & nWAIT) begin
		case(1'b1)
			PREFIX[0]: begin //CB
				case(D)
					default: $display("%m: (%h) :Extended instruction of Z80", A - 1);
				endcase
				PREFIX = 4'd0;
			end
			PREFIX[1]: begin //DD
				case(D)
					8'b01_000_110: $display("%m: (%h) : LD B,(X+d) ", A); 
					8'b01_001_110: $display("%m: (%h) : LD C,(X+d) ", A); 
					8'b01_010_110: $display("%m: (%h) : LD D,(X+d) ", A); 
					8'b01_011_110: $display("%m: (%h) : LD E,(X+d) ", A); 
					8'b01_100_110: $display("%m: (%h) : LD H,(X+d) ", A); 
					8'b01_101_110: $display("%m: (%h) : LD L,(X+d) ", A); 					
					8'b01_111_110: $display("%m: (%h) : LD A,(X+d) ", A); 				
					8'h70: $display("%m: (%h) : LD (X+d),B ", A); 
					8'h71: $display("%m: (%h) : LD (X+d),C ", A); 
					8'h72: $display("%m: (%h) : LD (X+d),D ", A); 
					8'h73: $display("%m: (%h) : LD (X+d),E ", A); 
					8'h74: $display("%m: (%h) : LD (X+d),H ", A); 
					8'h75: $display("%m: (%h) : LD (X+d),L ", A); 					
					8'h77: $display("%m: (%h) : LD (X+d),A ", A); 
					default: $display("%m: (%h) :Extended instruction of Z80", A - 1);
				endcase
				PREFIX = 4'd0;
			end
			PREFIX[2]: begin //ED
				case(D)
					8'h46: $display("%m: (%h) : IM0 ", A - 16'h1); 					
					8'h56: $display("%m: (%h) : IM1 ", A - 16'h1); 
					8'h5E: $display("%m: (%h) : IM2 ", A - 16'h1); 
					8'h47: $display("%m: (%h) : LD I A ", A - 16'h1); 
					8'h57: $display("%m: (%h) : LD A I ", A - 16'h1); 
					8'hA0: $display("%m: (%h) : LDI ", A - 16'h1);
					8'hA1: $display("%m: (%h) : CPI(Z80) ", A - 16'h1);
					8'hA8: $display("%m: (%h) : LDD ", A - 16'h1);
					8'hA9: $display("%m: (%h) : CPD ", A - 16'h1);
					8'hB0: $display("%m: (%h) : LDIR ", A - 16'h1);
					8'hB1: $display("%m: (%h) : CPIR(Z80) ", A - 16'h1);
					8'hB8: $display("%m: (%h) : LDDR ", A - 16'h1);					
					8'hB9: $display("%m: (%h) : CPDR ", A - 16'h1);
					default: $display("Unknown instruction for MSA85(Z80) - simulation stopped.", A);
				endcase
				PREFIX = 4'd0;
			end			
			PREFIX[3]: begin //FD
				case(D)
					8'b01_000_110: $display("%m: (%h) : LD B,(X+d) ", A); 
					8'b01_001_110: $display("%m: (%h) : LD C,(X+d) ", A); 
					8'b01_010_110: $display("%m: (%h) : LD D,(X+d) ", A); 
					8'b01_011_110: $display("%m: (%h) : LD E,(X+d) ", A); 
					8'b01_100_110: $display("%m: (%h) : LD H,(X+d) ", A); 
					8'b01_101_110: $display("%m: (%h) : LD L,(X+d) ", A); 					
					8'b01_111_110: $display("%m: (%h) : LD A,(X+d) ", A); 
					8'h70: $display("%m: (%h) : LD (Y+d) B ", A); 
					8'h71: $display("%m: (%h) : LD (Y+d) C ", A); 
					8'h72: $display("%m: (%h) : LD (Y+d) D ", A); 
					8'h73: $display("%m: (%h) : LD (Y+d) E ", A); 
					8'h74: $display("%m: (%h) : LD (Y+d) H ", A); 
					8'h75: $display("%m: (%h) : LD (Y+d) L ", A); 					
					8'h77: $display("%m: (%h) : LD (Y+d) A ", A); 
					default: $display("%m: (%h) :Extended instruction of Z80", A - 1);
				endcase
				PREFIX = 4'd0;
			end
			default:
				case(D)
					8'b01000000: $display("%m: (%h) : MOV B B ", A); 
					8'b01000001: $display("%m: (%h) : MOV B C ", A); 
					8'b01000010: $display("%m: (%h) : MOV B D ", A); 
					8'b01000011: $display("%m: (%h) : MOV B E ", A); 
					8'b01000100: $display("%m: (%h) : MOV B H ", A); 
					8'b01000101: $display("%m: (%h) : MOV B L ", A); 
					8'b01000110: $display("%m: (%h) : MOV B M ", A); 
					8'b01000111: $display("%m: (%h) : MOV B A ", A); 
					8'b01001000: $display("%m: (%h) : MOV C B ", A); 
					8'b01001001: $display("%m: (%h) : MOV C C ", A); 
					8'b01001010: $display("%m: (%h) : MOV C D ", A); 
					8'b01001011: $display("%m: (%h) : MOV C E ", A); 
					8'b01001100: $display("%m: (%h) : MOV C H ", A); 
					8'b01001101: $display("%m: (%h) : MOV C L ", A); 
					8'b01001110: $display("%m: (%h) : MOV C M ", A); 
					8'b01001111: $display("%m: (%h) : MOV C A ", A); 
					8'b01010000: $display("%m: (%h) : MOV D B ", A); 
					8'b01010001: $display("%m: (%h) : MOV D C ", A); 
					8'b01010010: $display("%m: (%h) : MOV D D ", A); 
					8'b01010011: $display("%m: (%h) : MOV D E ", A); 
					8'b01010100: $display("%m: (%h) : MOV D H ", A); 
					8'b01010101: $display("%m: (%h) : MOV D L ", A); 
					8'b01010110: $display("%m: (%h) : MOV D M ", A); 
					8'b01010111: $display("%m: (%h) : MOV D A ", A); 
					8'b01011000: $display("%m: (%h) : MOV E B ", A); 
					8'b01011001: $display("%m: (%h) : MOV E C ", A); 
					8'b01011010: $display("%m: (%h) : MOV E D ", A); 
					8'b01011011: $display("%m: (%h) : MOV E E ", A); 
					8'b01011100: $display("%m: (%h) : MOV E H ", A); 
					8'b01011101: $display("%m: (%h) : MOV E L ", A); 
					8'b01011110: $display("%m: (%h) : MOV E M ", A); 
					8'b01011111: $display("%m: (%h) : MOV E A ", A); 
					8'b01100000: $display("%m: (%h) : MOV H B ", A); 
					8'b01100001: $display("%m: (%h) : MOV H C ", A); 
					8'b01100010: $display("%m: (%h) : MOV H D ", A); 
					8'b01100011: $display("%m: (%h) : MOV H E ", A); 
					8'b01100100: $display("%m: (%h) : MOV H H ", A); 
					8'b01100101: $display("%m: (%h) : MOV H L ", A); 
					8'b01100110: $display("%m: (%h) : MOV H M ", A); 
					8'b01100111: $display("%m: (%h) : MOV H A ", A); 
					8'b01101000: $display("%m: (%h) : MOV L B ", A); 
					8'b01101001: $display("%m: (%h) : MOV L C ", A); 
					8'b01101010: $display("%m: (%h) : MOV L D ", A); 
					8'b01101011: $display("%m: (%h) : MOV L E ", A); 
					8'b01101100: $display("%m: (%h) : MOV L H ", A); 
					8'b01101101: $display("%m: (%h) : MOV L L ", A); 
					8'b01101110: $display("%m: (%h) : MOV L M ", A); 
					8'b01101111: $display("%m: (%h) : MOV L A ", A); 
					8'b01110000: $display("%m: (%h) : MOV M B ", A); 
					8'b01110001: $display("%m: (%h) : MOV M C ", A); 
					8'b01110010: $display("%m: (%h) : MOV M D ", A); 
					8'b01110011: $display("%m: (%h) : MOV M E ", A); 
					8'b01110100: $display("%m: (%h) : MOV M H ", A); 
					8'b01110101: $display("%m: (%h) : MOV M L ", A); 
					8'b01110110: $display("%m: (%h) : MOV M M ", A); 
					8'b01110111: $display("%m: (%h) : MOV M A ", A); 
					8'b01111000: $display("%m: (%h) : MOV A B ", A); 
					8'b01111001: $display("%m: (%h) : MOV A C ", A); 
					8'b01111010: $display("%m: (%h) : MOV A D ", A); 
					8'b01111011: $display("%m: (%h) : MOV A E ", A); 
					8'b01111100: $display("%m: (%h) : MOV A H ", A); 
					8'b01111101: $display("%m: (%h) : MOV A L ", A); 
					8'b01111110: $display("%m: (%h) : MOV A M ", A); 
					8'b01111111: $display("%m: (%h) : MOV A A ", A); 
					8'b00000110: $display("%m: (%h) : MVI B	", A); 
					8'b00001110: $display("%m: (%h) : MVI C	", A); 
					8'b00010110: $display("%m: (%h) : MVI D	", A); 
					8'b00011110: $display("%m: (%h) : MVI E	", A); 
					8'b00100110: $display("%m: (%h) : MVI H	", A); 
					8'b00101110: $display("%m: (%h) : MVI L	", A); 
					8'b00110110: $display("%m: (%h) : MVI M	", A); 
					8'b00111110: $display("%m: (%h) : MVI A	", A); 
					8'b00000001: $display("%m: (%h) : LXI B	", A); 
					8'b00010001: $display("%m: (%h) : LXI D	", A); 
					8'b00100001: $display("%m: (%h) : LXI H	", A); 
					8'b00110001: $display("%m: (%h) : LXI SP	", A); 
					8'b00111010: $display("%m: (%h) : LDA		", A); 
					8'b00110010: $display("%m: (%h) : STA		", A); 
					8'b00101010: $display("%m: (%h) : LHLD	", A); 
					8'b00100010: $display("%m: (%h) : SHLD	", A); 
					8'b00001010: $display("%m: (%h) : LDAX B	", A); 
					8'b00011010: $display("%m: (%h) : LDAX D	", A); 
					8'b00000010: $display("%m: (%h) : STAX B	", A); 
					8'b00010010: $display("%m: (%h) : STAX D	", A); 
					8'b11101011: $display("%m: (%h) : XCHG	", A); 
					8'b10000000: $display("%m: (%h) : ADD B	", A); 
					8'b10000001: $display("%m: (%h) : ADD C	", A); 
					8'b10000010: $display("%m: (%h) : ADD D	", A); 
					8'b10000011: $display("%m: (%h) : ADD E	", A); 
					8'b10000100: $display("%m: (%h) : ADD H	", A); 
					8'b10000101: $display("%m: (%h) : ADD L	", A); 
					8'b10000110: $display("%m: (%h) : ADD M	", A); 
					8'b10000111: $display("%m: (%h) : ADD A	", A); 
					8'b10001000: $display("%m: (%h) : ADC B	", A); 
					8'b10001001: $display("%m: (%h) : ADC C	", A); 
					8'b10001010: $display("%m: (%h) : ADC D	", A); 
					8'b10001011: $display("%m: (%h) : ADC E	", A); 
					8'b10001100: $display("%m: (%h) : ADC H	", A); 
					8'b10001101: $display("%m: (%h) : ADC L	", A); 
					8'b10001110: $display("%m: (%h) : ADC M	", A); 
					8'b10001111: $display("%m: (%h) : ADC A	", A); 
					8'b10010000: $display("%m: (%h) : SUB B	", A); 
					8'b10010001: $display("%m: (%h) : SUB C	", A); 
					8'b10010010: $display("%m: (%h) : SUB D	", A); 
					8'b10010011: $display("%m: (%h) : SUB E	", A); 
					8'b10010100: $display("%m: (%h) : SUB H	", A); 
					8'b10010101: $display("%m: (%h) : SUB L	", A); 
					8'b10010110: $display("%m: (%h) : SUB M	", A); 
					8'b10010111: $display("%m: (%h) : SUB A	", A); 
					8'b10011000: $display("%m: (%h) : SBB B	", A); 
					8'b10011001: $display("%m: (%h) : SBB C	", A); 
					8'b10011010: $display("%m: (%h) : SBB D	", A); 
					8'b10011011: $display("%m: (%h) : SBB E	", A); 
					8'b10011100: $display("%m: (%h) : SBB H	", A); 
					8'b10011101: $display("%m: (%h) : SBB L	", A); 
					8'b10011110: $display("%m: (%h) : SBB M	", A); 
					8'b10011111: $display("%m: (%h) : SBB A	", A); 
					8'b10100000: $display("%m: (%h) : ANA B	", A); 
					8'b10100001: $display("%m: (%h) : ANA C	", A); 
					8'b10100010: $display("%m: (%h) : ANA D	", A); 
					8'b10100011: $display("%m: (%h) : ANA E	", A); 
					8'b10100100: $display("%m: (%h) : ANA H	", A); 
					8'b10100101: $display("%m: (%h) : ANA L	", A); 
					8'b10100110: $display("%m: (%h) : ANA M	", A); 
					8'b10100111: $display("%m: (%h) : ANA A	", A); 
					8'b10101000: $display("%m: (%h) : XRA B	", A); 
					8'b10101001: $display("%m: (%h) : XRA C	", A); 
					8'b10101010: $display("%m: (%h) : XRA D	", A); 
					8'b10101011: $display("%m: (%h) : XRA E	", A); 
					8'b10101100: $display("%m: (%h) : XRA H	", A); 
					8'b10101101: $display("%m: (%h) : XRA L	", A); 
					8'b10101110: $display("%m: (%h) : XRA M	", A); 
					8'b10101111: $display("%m: (%h) : XRA A	", A); 
					8'b10110000: $display("%m: (%h) : ORA B	", A); 
					8'b10110001: $display("%m: (%h) : ORA C	", A); 
					8'b10110010: $display("%m: (%h) : ORA D	", A); 
					8'b10110011: $display("%m: (%h) : ORA E	", A); 
					8'b10110100: $display("%m: (%h) : ORA H	", A); 
					8'b10110101: $display("%m: (%h) : ORA L	", A); 
					8'b10110110: $display("%m: (%h) : ORA M	", A); 
					8'b10110111: $display("%m: (%h) : ORA A	", A); 
					8'b10111000: $display("%m: (%h) : CMP B	", A); 
					8'b10111001: $display("%m: (%h) : CMP C	", A); 
					8'b10111010: $display("%m: (%h) : CMP D	", A); 
					8'b10111011: $display("%m: (%h) : CMP E	", A); 
					8'b10111100: $display("%m: (%h) : CMP H	", A); 
					8'b10111101: $display("%m: (%h) : CMP L	", A); 
					8'b10111110: $display("%m: (%h) : CMP M	", A); 
					8'b10111111: $display("%m: (%h) : CMP A	", A); 
					8'b11000110: $display("%m: (%h) : ADI	", A); 
					8'b11001110: $display("%m: (%h) : ACI	", A); 
					8'b11010110: $display("%m: (%h) : SUI	", A); 
					8'b11011110: $display("%m: (%h) : SBI	", A); 
					8'b11100110: $display("%m: (%h) : ANI	", A); 
					8'b11101110: $display("%m: (%h) : XRI	", A); 
					8'b11110110: $display("%m: (%h) : ORI	", A); 
					8'b11111110: $display("%m: (%h) : CPI	", A); 
					8'b00100111: $display("%m: (%h) : DAA	", A); 
					8'b00000111: $display("%m: (%h) : RLC	", A); 
					8'b00001111: $display("%m: (%h) : RRC	", A); 
					8'b00010111: $display("%m: (%h) : RAL	", A); 
					8'b00011111: $display("%m: (%h) : RAR	", A); 
					8'b00101111: $display("%m: (%h) : CMA	", A); 
					8'b00110111: $display("%m: (%h) : STC	", A); 
					8'b00111111: $display("%m: (%h) : CMC	", A); 
					8'b00000100: $display("%m: (%h) : INR B	", A); 
					8'b00001100: $display("%m: (%h) : INR C	", A); 
					8'b00010100: $display("%m: (%h) : INR D	", A); 
					8'b00011100: $display("%m: (%h) : INR E	", A); 
					8'b00100100: $display("%m: (%h) : INR H	", A); 
					8'b00101100: $display("%m: (%h) : INR L	", A); 
					8'b00110100: $display("%m: (%h) : INR M	", A); 
					8'b00111100: $display("%m: (%h) : INR A	", A); 
					8'b00000101: $display("%m: (%h) : DCR B	", A); 
					8'b00001101: $display("%m: (%h) : DCR C	", A); 
					8'b00010101: $display("%m: (%h) : DCR D	", A); 
					8'b00011101: $display("%m: (%h) : DCR E	", A); 
					8'b00100101: $display("%m: (%h) : DCR H	", A); 
					8'b00101101: $display("%m: (%h) : DCR L	", A); 
					8'b00110101: $display("%m: (%h) : DCR M	", A); 
					8'b00111101: $display("%m: (%h) : DCR A	", A); 
					8'b00000011: $display("%m: (%h) : INX B	", A); 
					8'b00010011: $display("%m: (%h) : INX D	", A); 
					8'b00100011: $display("%m: (%h) : INX H	", A); 
					8'b00110011: $display("%m: (%h) : INX SP	", A); 
					8'b00001011: $display("%m: (%h) : DCX B	", A); 
					8'b00011011: $display("%m: (%h) : DCX D	", A); 
					8'b00101011: $display("%m: (%h) : DCX H	", A); 
					8'b00111011: $display("%m: (%h) : DCX SP	", A); 
					8'b00001001: $display("%m: (%h) : DAD B	", A); 
					8'b00011001: $display("%m: (%h) : DAD D	", A); 
					8'b00101001: $display("%m: (%h) : DAD H	", A); 
					8'b00111001: $display("%m: (%h) : DAD SP", A); 
					8'b11000011: $display("%m: (%h) : JMP	", A); 
					8'b11000010: $display("%m: (%h) : JNZ	", A); 
					8'b11001010: $display("%m: (%h) : JZ	", A); 
					8'b11010010: $display("%m: (%h) : JNC	", A); 
					8'b11011010: $display("%m: (%h) : JC	", A); 
					8'b11100010: $display("%m: (%h) : JPO	", A); 
					8'b11101010: $display("%m: (%h) : JPE	", A); 
					8'b11110010: $display("%m: (%h) : JP	", A); 
					8'b11111010: $display("%m: (%h) : JM	", A); 
					8'b11001101: $display("%m: (%h) : CALL	", A); 
					8'b11000100: $display("%m: (%h) : CNZ	", A); 
					8'b11001100: $display("%m: (%h) : CZ	", A); 
					8'b11010100: $display("%m: (%h) : CNC	", A); 
					8'b11011100: $display("%m: (%h) : CC	", A); 
					8'b11100100: $display("%m: (%h) : CPO	", A); 
					8'b11101100: $display("%m: (%h) : CPE	", A); 
					8'b11110100: $display("%m: (%h) : CP	", A); 
					8'b11111100: $display("%m: (%h) : CM	", A); 
					8'b11001001: $display("%m: (%h) : RET	", A); 
					8'b11000000: $display("%m: (%h) : RNZ	", A); 
					8'b11001000: $display("%m: (%h) : RZ	", A); 
					8'b11010000: $display("%m: (%h) : RNC	", A); 
					8'b11011000: $display("%m: (%h) : RC	", A); 
					8'b11100000: $display("%m: (%h) : RPO	", A); 
					8'b11101000: $display("%m: (%h) : RPE	", A); 
					8'b11110000: $display("%m: (%h) : RP	", A); 
					8'b11111000: $display("%m: (%h) : RM	", A); 
					8'b11000111: $display("%m: (%h) : RST 0	", A); 
					8'b11001111: $display("%m: (%h) : RST 1	", A); 
					8'b11010111: $display("%m: (%h) : RST 2	", A); 
					8'b11011111: $display("%m: (%h) : RST 3	", A); 
					8'b11100111: $display("%m: (%h) : RST 4	", A); 
					8'b11101111: $display("%m: (%h) : RST 5	", A); 
					8'b11110111: $display("%m: (%h) : RST 6	", A); 
					8'b11111111: $display("%m: (%h) : RST 7	", A); 
					8'b11101001: $display("%m: (%h) : PCHL	", A); 
					8'b11000101: $display("%m: (%h) : PUSH B", A); 
					8'b11010101: $display("%m: (%h) : PUSH D", A); 
					8'b11100101: $display("%m: (%h) : PUSH H", A); 
					8'b11110101: $display("%m: (%h) : PUSH PSW", A); 
					8'b11000001: $display("%m: (%h) : POP B	", A); 
					8'b11010001: $display("%m: (%h) : POP D	", A); 
					8'b11100001: $display("%m: (%h) : POP H	", A); 
					8'b11110001: $display("%m: (%h) : POP PSW", A); 
					8'b11100011: $display("%m: (%h) : XTHL", A); 
					8'b11111001: $display("%m: (%h) : SPHL", A); 
					8'b11011011: $display("%m: (%h) : IN", A); 
					8'b11010011: $display("%m: (%h) : OUT	", A); 
					8'b11111011: $display("%m: (%h) : EI	", A); 
					8'b11110011: $display("%m: (%h) : DI	", A); 
					8'b01110110: $display("%m: (%h) : HLT	", A); 
					8'b00000000: $display("%m: (%h) : NOP	", A); 
					8'hCB: begin					
						$display("Instruction prefix - CB");
						PREFIX = 4'b0001;
					end
					8'hDD: begin
						$display("Instruction prefix - DD");
						PREFIX = 4'b0010;
					end
					8'hED: begin
						$display("Instruction prefix - ED");
						PREFIX = 4'b0100;
					end
					8'hFD: begin
						$display("Instruction prefix - FD");
						PREFIX = 4'b1000;
					end
					default: begin
							$display("Unknown instruction for MSA85 - simulation stopped.", A);
							$stop;
						end
				endcase
		endcase
	end
end
	
endmodule

