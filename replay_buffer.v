`timescale 1ns / 1ps
module replay_buffer(busy_n, clk, reset_n, ack_nack, seq, tim_out, ready, we, din, dout);
input busy_n, clk, reset_n, tim_out, we;
input [1:0] ack_nack;
input [11:0] seq;
input[159:0] din;
output reg [15:0] dout;
output reg ready;
wire [159:0] crc_output;
wire [3:0] crc_num;
wire [15:0] mux_output;
wire [11:0] num_to_rep;
wire[11:0] replay_index;


wire reset_internal, we_internal, rdy_internal, to_internal, ack_nack_internal;

mem1 fifo(.clk(clk), .data_in(mux_output), .data_out(dout), .rd(ack_nack_internal), .wr(we_internal), .en(busy_n), 
            .data_out(dout), .rst(reset_internal), .seq(seq), .tim_out(to_internal), .empty(1'bz), .full(1'bz),
            .last_seq_written(num_to_rep), .replay_index(replay_index));

control FSM(.reset_n(reset_n), .clk(clk), .busy_n(busy_n), .we_i(we), .seq(seq),
.to_i(tim_out), .acknak_i(ack_nack), .rst(reset_internal), .we_o(we_internal), .to_o(to_internal), 
.rdy(ready), .busy_n_o(1'bz), .acknak_o(ack_nack_internal), .crc_num(crc_num), .num_to_rep(num_to_rep), .count(replay_index)); //crc_num output control signal to mux

crc lcrc_32(.in(data_in), .reset(reset_internal), .clk(clk), .final_out(crc_output));

mx MUX10(.d0(crc_output[15:0]), .d1(crc_output[31:16]), .d2(crc_output[47:32]), .d3(crc_output[63:48]), .d4(crc_output[79:64]), 
    .d5(crc_output[95:80]), .d6(crc_output[111:96]), .d7(crc_output[127:112]), .d8(crc_output[143:128]), .d9(crc_output[159:144]),
    .s(crc_num), .y(mux_output));

endmodule