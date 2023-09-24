`include "./i2c_controller_master.v"
module i2c_module(
    clk,
    reset_n,
    cs,
    read,
    write,
    reg_address,
    write_data,
    read_data,
    scl,
    sda,
);

input wire clk;
input wire reset_n;
input wire cs;
input wire read;
input wire write;
input wire [1:0] reg_address;
input wire [15:0] write_data;
output wire [15:0] read_data;
inout wire scl;
inout wire sda;

reg [15:0] divider_reg;
wire activate, write_divider;
wire [7:0] data_out;
wire ready, ack;

i2c_controller_master i2c_controller(
    .clk(clk),
    .reset_n(reset_n),
    .activate(activate),
    .command(write_data[10:8]),
    .divider(divider_reg),
    .data_in(write_data[7:0]),
    .data_out(data_out),
    .byte_processed(),
    .ack(ack),
    .ready(ready),
    .scl(scl),
    .sda(sda)
);

assign write_divider = cs && write && reg_address == 2'b01;
assign activate = cs && write && reg_address == 2'b10;
assign read_data = {6'b0, ack, ready, data_out};

always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        divider_reg <= 16'b0;
    end else begin
        if(write_divider) begin
            divider_reg <= write_data;
        end
    end
end
endmodule
