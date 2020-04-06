`timescale 1ns / 1ps
module replay_buffer(busy_n, clk, reset_n, ack_nack, seq, tim_out, ready, we, din, dout);
input busy_n, clk, reset_n, tim_out, we;
input [1:0] ack_nack;
input [11:0] seq;
input[15:0] din;
output reg [15:0] dout;
output reg ready;

mem1 fifo(.clk(clk), .data_in(din), .rd(ack_nack), .wr(we), .en(busy_n), 
            .data_out(dout), .rst(reset_n), .seq(seq));

always @ (posedge clk)

begin

if busy_n == 0;

else begin
ready = 1;

//00 = not received
//01 = ack
//10 = nack
//dllp: 32 bits + 16 bit CRC

//need to keep track of 2 sequence numbers - 1 is a counter that tracks good TLPs received, the other is the sequence number
//attached to the DLP
