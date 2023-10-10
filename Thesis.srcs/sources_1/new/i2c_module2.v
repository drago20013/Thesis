`timescale  1ns / 100ps

module i2c_module2(
    clk,
    reset_n,
    cs,
    read,
    write,
    data_in,
    data_out,
    byte_processed,
    reg_address,
    scl,
    sda
);

input wire clk;
input wire reset_n;
input wire cs;
input wire read;
input wire write;
input wire [7:0] data_in;
output wire [7:0] data_out;
output wire byte_processed;
input wire [2:0] reg_address;
inout wire scl;
inout wire sda;

// Internal signals and registers
reg [3:0] transaction_state, next_transaction_state;
reg [2:0] command, next_command;
reg [7:0] div_high;
reg [7:0] div_low;
reg [7:0] slave_addr;
reg [7:0] data_buffer;
reg activate, next_activate;
reg byte_processed_reg;
reg ack_reg;
reg ready_reg;

// Wire declarations for connecting to the i2c_controller_master
wire [7:0] i2c_data_in;
wire i2c_byte_processed;
wire i2c_ack;
wire i2c_ready;
wire i2c_activate;

// Instantiate the i2c_controller_master
i2c_controller_master i2c_master(
    .clk(clk),
    .reset_n(reset_n),
    .activate(activate),
    .command(command),
    .divider({div_high, div_low}),
    .data_in(i2c_data_in),
    .data_out(data_out),
    .byte_processed(i2c_byte_processed),
    .ack(i2c_ack),
    .ready(i2c_ready),
    .scl(scl),
    .sda(sda)
);

localparam [3:0]
    STATE_IDLE = 0,
    STATE_START = 1,
    STATE_SENT_ADDR = 2,
    STATE_WAIT_ACK = 3,
    STATE_WRITE = 4,
    STATE_READ = 5,
    STATE_WAIT_ACK_WRITE = 6,
    STATE_WAIT_ACK_READ = 7,
    STATE_STOP = 8;
    
localparam [2:0]
    COMMAND_START = 0,
    COMMAND_STOP = 1,
    COMMAND_WR = 2,
    COMMAND_RD = 3,
    COMMAND_REPEAT_START = 4;
    
// Connect transaction-level outputs to external signals
assign byte_processed = byte_processed_reg;
always @(*) begin
    next_transaction_state = transaction_state;
    
    case (transaction_state)
        STATE_IDLE: begin
            if(i2c_ready && activate) begin
                next_transaction_state = STATE_START;
                next_command = COMMAND_START;
                //next_activate = 1'b0;
            end
        end
        STATE_START: begin
            if(i2c_ready) begin
                next_transaction_state = STATE_SENT_ADDR;
            end
        end
        STATE_SENT_ADDR: begin
        end
        STATE_WAIT_ACK: begin
        end
        STATE_WRITE: begin
        end
        STATE_READ: begin
        end
        STATE_WAIT_ACK_WRITE: begin
        end
        STATE_WAIT_ACK_READ: begin
        end
        STATE_STOP: begin
        end
    endcase
end

// Transaction-level logic
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        transaction_state <= 0;
        next_transaction_state <= 0;
        command <= 0;
        next_command <= 0;
        div_high <= 0;
        div_low <= 0;
        slave_addr <= 0;
        data_buffer <= 0;
        activate <= 0;
        next_activate <= 0;
        byte_processed_reg <= 0;
        ack_reg <= 0;
        ready_reg <= 0;
    end else begin
        transaction_state <= next_transaction_state;
        command <= next_command;
        //activate <= next_activate;
        if(cs && write) begin
            case(reg_address)
            3'b0000: begin
                div_high <= data_in;
            end
            3'b0001: begin
                div_low <= data_in;
            end
            3'b0010: begin
                slave_addr <= data_in;
            end
            3'b0011: begin
                data_buffer <= data_in;
            end
            3'b0100: begin
                activate <= 1'b1;
            end
            endcase
        end
    end
end
endmodule