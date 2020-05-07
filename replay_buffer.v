`timescale 1ns / 1ps
module replay_buffer(busy_n, clk, reset_n, ack_nack, seq, tim_out, ready, we, din, dout);
input busy_n, clk, reset_n, tim_out, we;
input [1:0] ack_nack;
input [11:0] seq;
input[15:0] din;
output reg [15:0] dout;
output reg ready;

wire reset_internal, we_internal, rdy_internal, to_internal, ack_nack_internal;

mem1 fifo(.clk(clk), .data_in(din), .data_out(dout), .rd(ack_nack_internal), .wr(we_internal), .en(busy_n), 
            .data_out(dout), .rst(reset_internal), .seq(seq), .tim_out(to_internal));

control FSM(.reset_n(reset_n), .clk(clk), .busy_n(busy_n), .we_i(we), 
.to_i(tim_out), .acknak_i(ack_nack), .rst(reset_internal), .we_o(we_internal), .to_o(to_internal), 
.rdy(ready), busy_n_o, .acknak_o(ack_nack_internal))


//need to keep track of 2 sequence numbers - 1 is a counter that tracks good TLPs received, the other is the sequence number
//attached to the DLP
