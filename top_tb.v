`timescale 1ns / 1ns
module top_tb;

reg        tim_out, we, busy_n, clk, reset_n;
reg[1:0]   ack_nack;
reg[11:0]  seq;
reg[159:0] din;


wire[15:0] dout;
wire ready;

replay_buffer u1 (busy_n, clk, reset_n, ack_nack, seq, tim_out, ready, we, din, dout);

initial clk = 0;
always #10 clk = ~clk;

initial
begin
  {reset_n, busy_n, we, tim_out, ack_nack} = 6'b010000;
  seq = 0;
  din = 160'h400000010000000ffdaff04012345678FFFFFFFF; //memory write request TLP
  #1 reset_n = 1;                    //Turn off reset, active low
  #9;                                //Exit s0
  #1 we = 1;                       //Enter s1, count to 0, trigger we_i for s2
  #9 we = 0;                       //Exit s1, we_i off 
  #440                              //enter s2, begin write cycles 
  #1 din = 160'h0000000100000c0ffdaff04000000000FFFFFFFF; we = 1; //memory write request TLP
  #19 we = 0;
  #440
  #1 din = 160'h4a0000010100000400000c4012345678FFFFFFFF; we = 1; //memory write request TLP
  #19 we = 0;
  #440
  #1  ack_nack = 2'b01; seq = 12'h001; //Go to s3 and advance read pointer
  #19 ack_nack = 2'b00;                //exit s1
  #40                                  //enter s3 ARP, exit s3, enter s1
  #1  ack_nack = 2'b10; seq = 12'h002;
  #19 ack_nack = 2'b00;
  #500
  #1  tim_out = 1;
  #19 tim_out = 0;
  #500
  #10 $stop;                         //end
end



initial begin
		$dumpfile("replay_buffer.vcd");
		$dumpvars(0, top_tb);
	end
endmodule
