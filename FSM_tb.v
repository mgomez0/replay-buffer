`timescale 1ns / 1ns
module FSM_tb;
reg reset_n, clk, busy_n, we_i, to_i;
reg[1:0] acknak_i;
wire rst, we_o, to_o, rdy, busy_n_o;
wire[1:0] acknak_o;

FSM u1(reset_n, clk, busy_n, we_i, to_i, acknak_i, rst, we_o, to_o, rdy, busy_n_o, acknak_o);

initial {reset_n, clk} = 0;
always #10 clk = ~clk;

initial
begin
  {reset_n, busy_n, we_i, to_i, acknak_i} = 6'b010000;
  #1 reset_n = 1;
  #9;
  #1 we_i = 1;
  #9 we_i = 0;
  #30;
  #1 acknak_i = 2'b01;
  #9 acknak_i = 2'b00;
  #30;
  #1 acknak_i = 2'b10;
  #9;
  #20 acknak_i = 2'b00;
  #51 busy_n = 0;
  #29 busy_n   = 1;
  #10;
  #1 to_i = 1;
  #9 to_i = 0;;
  #51 busy_n = 0;
  #29 busy_n = 1;
  #100 reset_n = 0;
  #40  reset_n = 1;
  #10 $stop;
end

endmodule
