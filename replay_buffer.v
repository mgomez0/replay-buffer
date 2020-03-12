`timescale 1ns / 1ps
module replay_buffer(busy_n, clk, reset_n, ack_nack, seq, tim_out, ready, we, din, dout);
input busy_n, clk, reset_n, tim_out, we;
input [2:0] ack_nack;
input [11:0] seq;
input[15:0] din;
output reg [15:0] dout;
output ready;

mem1 fifo(clk, data_in, rd, wr, en, data_out, rst, empty, full);

if busy_n == 0;

else begin
ready = 1;

//00 = not received
//01 = ack
//10 = nack
//dllp: 32 bits + 16 bit CRC

