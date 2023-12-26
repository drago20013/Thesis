`timescale 1ns / 100ps

module i2c_controller_master_v2(
    clk,
    reset_n,
    activate,
    command,
    divider,
    data_in,
    data_out,
    byte_processed,
    ack,
    ack_i,
    ready,
    scl,
    sda
);
localparam FDV_W = 11;

//INPUTS
input wire clk;
input wire reset_n;
input wire activate;
input wire [1:0] command;
input wire [FDV_W-1:0] divider;
input wire [7:0] data_in;
input wire ack_i;

//OUTPUTS
output wire [7:0] data_out;
output wire byte_processed;
output wire ack;
output wire ready;

//INOUTS
inout wire scl;
inout wire sda;

//INTERNAL REGISTERS
reg [3:0] current_state, next_state;
reg current_sda, next_sda;
reg current_scl, next_scl;
reg data_phase;
reg [8:0] current_transmit, next_transmit; 
reg [8:0] current_receive, next_receive; 
reg [FDV_W-1:0] fdv;
reg [1:0] current_command, next_command;
reg [3:0] current_bit, next_bit; //How many bits we tx/rx yet
reg current_byte_processed, next_byte_processed, ready_reg, next_ready_reg;
wire sda_assert, nack;
wire [15:0] half_tick, quarter_tick;
wire fdv_en;
wire ce;

//LOCAL PARAMETERS
localparam [4:0]
    STATE_IDLE = 0,
    STATE_START_1 = 1,
    STATE_START_2 = 2,
    STATE_START_3 = 3,
    STATE_START_4 = 4,
    STATE_HOLD = 5,
    STATE_STOP_1 = 6,
    STATE_STOP_2 = 7,
    STATE_STOP_3 = 8,
    STATE_STOP_4 = 9,
    STATE_DATA_1 = 10,
    STATE_DATA_2 = 11,
    STATE_DATA_3 = 12,
    STATE_DATA_4 = 13,
    STATE_DATA_END = 14,
    STATE_REPEATED_START = 15;

localparam [1:0]
    COMMAND_START = 0,
    COMMAND_STOP = 1,
    COMMAND_WR = 2,
    COMMAND_RD = 3;

//COMBINATIONAL
assign sda_assert = (data_phase && current_command == COMMAND_RD && current_bit < 8) || (data_phase && current_command == COMMAND_WR && current_bit==8);
assign sda = (sda_assert || current_sda) ? 1'bz : 1'b0;
assign scl = (current_scl) ? 1'bz : 1'b0;

assign data_out = current_receive[8:1];
assign ack = current_receive[0];
assign nack = ack_i;
assign ready = ready_reg;
assign byte_processed = current_byte_processed;

assign fdv_en = ~ready;
assign ce = fdv[FDV_W-1];

always @(*) begin
    next_state = current_state;
    next_bit = current_bit;
    next_transmit = current_transmit;
    next_receive = current_receive;
    next_command = current_command;
    next_byte_processed = current_byte_processed;
    next_ready_reg = 1'b0;
    next_sda = 1'b1;
    next_scl = 1'b1;
    data_phase = 1'b0;

    case (current_state)
        STATE_IDLE: begin
            next_ready_reg = 1'b1;
            if(activate && command == COMMAND_START) begin
                next_state = STATE_START_1;
            end
        end
        STATE_START_1: begin
            if(ce) next_state = STATE_START_2;
        end
        STATE_START_2: begin
            next_sda = 1'b0;
            if(ce) next_state = STATE_START_3;
        end
        STATE_START_3: begin
            next_sda = 1'b0;
            if(ce) next_state = STATE_START_4;
        end            
        STATE_START_4: begin
            next_sda = 1'b0;
            next_scl = 1'b0;
            if(ce) next_state = STATE_HOLD;
        end   
        STATE_HOLD: begin
            next_ready_reg = 1'b1;
            next_scl = 1'b0;
            next_sda = 1'b0;
            if(activate) begin
                next_command = command;
                next_transmit = {data_in, nack};
                case (command)
                    COMMAND_START: begin
                        next_state = STATE_REPEATED_START;
                    end
                    COMMAND_STOP: begin
                        next_state = STATE_STOP_1;
                    end
                    default: begin
                       next_bit = 4'b0;
                       next_state = STATE_DATA_1;
                    end
                endcase
            end
        end
        STATE_REPEATED_START: begin
            next_scl = 1'b0;
            if(ce) next_state = STATE_START_1;
        end  
        STATE_DATA_1: begin
            next_sda = current_transmit[8];
            next_scl = 1'b0;
            data_phase = 1'b1;
            if(ce) next_state = STATE_DATA_2;
        end
        STATE_DATA_2: begin
            next_sda = current_transmit[8];
            data_phase = 1'b1;
            if(ce) begin
                next_state = STATE_DATA_3;
                next_receive = {current_receive[7:0], sda};
            end
        end
        STATE_DATA_3: begin
            next_sda = current_transmit[8];
            data_phase = 1'b1;
            if(ce) next_state = STATE_DATA_4;
        end
        STATE_DATA_4: begin
            next_sda = current_transmit[8];
            next_scl = 1'b0;
            data_phase = 1'b1;
            if(ce) begin
                if(current_bit == 8) begin
                    next_state = STATE_DATA_END;
                    next_byte_processed = 1'b1;
                end else begin
                    next_transmit = {current_transmit[7:0], 1'b0};
                    next_state = STATE_DATA_1;
                    next_bit = current_bit + 1'b1;
                end
            end
        end
        STATE_DATA_END: begin
            next_scl = 1'b0;
            next_sda = 1'b0;
            data_phase = 1'b1;
            if(ce) begin
                next_byte_processed = 1'b0;
                next_state = STATE_HOLD;
            end
        end
        STATE_STOP_1: begin
            next_sda = 1'b0;
            next_scl = 1'b0;
            if(ce) begin
                next_state = STATE_STOP_2;
            end
        end
        STATE_STOP_2: begin
            next_sda = 1'b0;
            if(ce) begin
               next_state = STATE_STOP_3;
            end
        end
        STATE_STOP_3: begin
            next_sda = 1'b0;
            if(ce) begin
               next_state = STATE_STOP_4;
            end
        end
        STATE_STOP_4: begin
            if(ce) begin
               next_state = STATE_IDLE;
            end
        end
    endcase
end

//SEQUENTIAL
always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        //OUTPUT LINES
        fdv <= {FDV_W{1'b0}};
        current_sda <= 1'b1;
        current_scl <= 1'b1;

        //OTHER REGISTERS
        current_state <= STATE_IDLE;
        current_bit <= 4'b0;
        current_receive <= 9'b0;
        current_transmit <= 9'b0;
        current_command <= 2'b0;
        current_byte_processed <= 1'b0;
        ready_reg <= 1'b0;
    end else begin
        //OUTPUT LINES
        current_sda <= next_sda;
        current_scl <= next_scl;

        //OTHER REGISTERS
        current_state <= next_state;
        current_bit <= next_bit;
        current_receive <= next_receive;
        current_transmit <= next_transmit;
        current_command <= next_command;
        current_byte_processed <= next_byte_processed;
        ready_reg <= next_ready_reg;
        
        fdv <= ((fdv_en & ~fdv[10]) ? fdv : divider) + {FDV_W{1'b1}};

    end
end

endmodule
