`timescale 1ns / 1ns
module FSM_tb;

reg        reset_n, clk, busy_n, we_i, to_i, rdy_i;
reg[1:0]   acknak_i;
reg[11:0]  seq, num_to_rep;

wire       rst, we_o, to_o, rdy_o, busy_n_o, rep;
wire[1:0]  acknak_o;
wire[3:0]  crc_num;
wire[11:0] count;

FSM u1(reset_n, clk, busy_n, we_i, to_i, acknak_i, rst, we_o, to_o, rdy_i, rdy_o, busy_n_o, acknak_o, crc_num, seq, count, num_to_rep, rep);

initial clk = 0;
always #10 clk = ~clk;

initial
begin
  {reset_n, busy_n, we_i, to_i, acknak_i, rdy_i} = 7'b0100000;
  seq = 0;
  num_to_rep = 0;
  #1 reset_n = 1;                    //Turn off reset, active low
  #9;                                //Exit s0
  #1 we_i = 1;                       //Enter s1, count to 0, trigger we_i for s2
  #9 we_i = 0;                       //Exit s1, we_i off 
  #20;                               //Enter s2, send crc_num for mux, exit s2
  #20;                               //Enter s2w, incrament count by 1, exit state s2w
  #380;                              //Repeat 8 more times, exit to s1
  #1 acknak_i = 2'b01;               //Send ACK
  #9 acknak_i = 2'b00;               //Disable ACK, exit s1
  #30;                               //Enter s3, forward ACK, exit s3, enter s1
  #1 acknak_i = 2'b10;               //Send NAK
  #9;                                //exit s1
  #1 num_to_rep = 12'b000000100111;  //enter s4, forward NAK, receive num_to_rep 39 for 4 replays,
  #19 acknak_i = 2'b00; busy_n = 0;  //enable busy_n, exit s4
  #20;                               //enter s5, store cum_to_rep into count_to, forward busy_n
  #1 busy_n = 1;                     //stay in s5, disable busy_n
  #19                                //forward busy_n, exit s5
  #20;                               //enter s4ra, send counter = 0, send rep =1, exit s4ra
  #20;                               //enter s4rb, rep = 0, incrament counter, exit s4rb
  #1560;                             //repeat 38 more times, exit to s1. 
  #10 $stop;                         //end
end

initial begin
		$dumpfile("FSM.vcd");
		$dumpvars(0, FSM_tb);
	end
endmodule
