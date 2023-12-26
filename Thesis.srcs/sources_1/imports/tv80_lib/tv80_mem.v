//---------------------------------------------------------
//  Memory model
//---------------------------------------------------------

`timescale 1ns/100ps

module RAM_4K(A, nOE, nWE, nCS, DQ);

input [11:0] A; 
input nOE, nWE, nCS;
inout [7:0] DQ;

reg [7:0] MEM [4095:0];

always @(nOE or nWE or nCS or DQ or A)
	if(~nCS & ~nWE & nOE)
		MEM[A] = DQ;

assign DQ = (~nCS & nWE & ~nOE) ? MEM[A] : 8'hzz;

//---------------------------------------------------------
// Modelling tasks
//---------------------------------------------------------
integer wr_addr;
reg [6:0] label_id;

task WR_MEM;
input [7:0] DATA;
begin
	MEM[wr_addr] = DATA;
	wr_addr = wr_addr + 1;
end
endtask

task WR_MEM_W;
input [15:0] DATA;
begin
	MEM[wr_addr] = DATA[7:0];
	wr_addr = wr_addr + 1;
	MEM[wr_addr] = DATA[15:8];
	wr_addr = wr_addr + 1;
end
endtask

task INIT_MEM;
input [7:0] DATA;
begin
	wr_addr = 0;	
	while(wr_addr < 8192) begin
		MEM[wr_addr] = DATA;
		wr_addr = wr_addr + 1;
	end
	wr_addr = 0;
	label_id = 0;
end
endtask

task ORG_MEM;
input [15:0] NEW_ADDR;
begin
	wr_addr = NEW_ADDR;	
end
endtask

task INIT_LABEL;
output [23:0] L;
begin
	L = {1'bx, label_id, 16'hxxxx};
	if(label_id == 127) begin
		$display("Fatal Error: Maximal number of labels defioned. Cannot continue.");
		$finish();
	end
	label_id = label_id + 1;	
end
endtask

task WR_LABEL;
input [23:0] L;
begin
	if(^L[15:0] !== 1'bx) begin	
		MEM[wr_addr] = L[7:0];
		wr_addr = wr_addr + 1;
		MEM[wr_addr] = L[15:8];
		wr_addr = wr_addr + 1;
	end
	else begin
		MEM[wr_addr] = L[23:16];
		wr_addr = wr_addr + 1;
		MEM[wr_addr] = 8'd0;
		wr_addr = wr_addr + 1;				
	end
end
endtask

task ASSIGN_LABEL;
inout [23:0] L;
begin
	if(^L[15:0] !== 1'bx) begin	
		$display("Fatal Error: Label %d already assigned.", L[22:16]);
		$stop;
	end
	else begin
		L[15:0] = wr_addr;
	end
end
endtask

task UPDATE_LABEL;
input [23:0] L;
integer i;
reg [7:0] item;
begin
	if(^L[15:0] === 1'bx) begin
		$display("Fatal Error: Label %d not assigned.", L[22:16]);
		$stop;
	end
	for(i = 0; i < 4096; i = i + 1)	 begin
		item = MEM[i];
		if(item === L[23:16]) begin
			$display("Label adjust %d -> @%5d", L[22:16], i);
			MEM[i] = L[7:0];
			i = i + 1;
			MEM[i] = L[15:8];
		end
	end
end
endtask

endmodule

