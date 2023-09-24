`include "i2c_module.v"
`timescale  1ns / 100ps

module i2c_test;

//INPUTS
reg clk;
reg reset_n;
reg cs;
reg read, write;
reg [1:0] reg_address;
reg [15:0] data_in;

//OUTPUTS
wire [15:0] data_out;

wire sda, scl;

i2c_module u1(
    .clk(clk),
    .reset_n(reset_n),
    .cs(cs),
    .read(read),
    .write(write),
    .reg_address(reg_address),
    .write_data(data_in),
    .read_data(data_out),
    .scl(scl),
    .sda(sda)
);

pullup (sda);
pullup (scl);

reg [6:0] slave_addr;
reg [7:0] byte_to_send; 
reg read_write;

always begin
    #5 clk = ~clk;
end

initial begin
    $monitor(scl, sda, clk, reset_n, cs, read, write, data_in, data_out);
    $dumpfile("i2c_test.vcd");
    $dumpvars(0, i2c_test);
    $dumpon;

    clk = 0; 
    write = 0;
    read = 0;
    cs = 1;
    data_in = 0;
    reg_address = 0;
    read_write = 0;
    slave_addr = 7'b0110101;
    byte_to_send = 8'b10101011;
    reset_n = 0; // assert reset
    #10 reset_n = 1;
    //set divider
    reg_address = 2'b01;
    data_in = 16'b0000000000000001;
    #10
    write = 1;
    #10
    //START
    reg_address = 2'b10;
    data_in = {3'b000, slave_addr, read_write};
    #20
    //WAIT FOR READY/HOLD
    //WIRTE SLAVE ADDR
    data_in = {3'b010, data_in[7:0]};
    #740
    //WAIT FOR READY
    //WRITE DATA
    data_in = {3'b010, byte_to_send};
    #840
    $finish;
end

endmodule
