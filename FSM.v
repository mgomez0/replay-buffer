module FSM(reset_n, clk, busy_n, we_i, to_i, acknak_i,
           rst, we_o, to_o, rdy_i, rdy_o, busy_n_o,
           acknak_o, crc_num, seq, count, num_to_rep, rep);
           
input        reset_n, clk, busy_n, we_i, to_i, rdy_i;
input[1:0]   acknak_i;
input[11:0]  seq, num_to_rep;

output       rst, we_o, to_o, rdy_o, busy_n_o, rep;
output[1:0]  acknak_o;
output[3:0]  crc_num;
output[11:0] count;

reg[3:0]     cs, ns;
reg[1:0]     acknak_o;
reg[11:0]    count, count_to;
reg[3:0]     crc_num = 0;
reg          rst, we_o, to_o, rdy_o, busy_n_o, rep;

parameter s0 = 4'b0000, s1 = 4'b0001, s2 = 4'b0010, s3 = 4'b0011, s4 = 4'b0100, s5 = 4'b0101, s2w = 4'b0110, s4ra = 4'b0111, s4rb = 4'b1000;

  
//what to do when clock goes high or reset goes low 
always @(posedge clk or negedge reset_n)
begin
  if(!reset_n)
    cs <= s0;
  else
    cs <= ns;
end

//Controlling the state change
always @(cs or we_i or acknak_i or to_i or busy_n)
begin
  case(cs)
    //Reset state s0: send rst for one clock cycle, move to s1
  s0:       ns <= s1;
       
    //Idle state s1: forward rdy signal from FIFO. Await we_i,
    //acknak_i, or to_i signals. Set count to 0.
  s1:       if(we_i)                               ns <= s2;
            else if(acknak_i == 2'b01)             ns <= s3;
            else if((acknak_i == 2'b10) || to_i)   ns <= s4;                

    //Write state s2: set crc_num to count which controlls the mux.
    //Exit to substate s2w.
  s2:       ns <= s2w; 

    //Write substate s2w: incraments the count by 1. If count is >= 9,
    //then exit to state s1. Otherwise, repeat state s2.
    //Goal is to write all QTY=10 16-bit sections of a TLP.
  s2w:      if(count >= 4'b1001) ns <= s1;
            else ns <= s2;

    //Advance read pointer state s3: forward ACK to FIFO to advance
    //the read pointer. Exit to state s1.
  s3:       ns <= s1;

    //Replay event state s4: Forward NAK/TO to FIFO to get num_to_rep
    //in return. Exit to state s5.
  s4:       ns <= s5;

    //Replay event substate s4ra: Forward count to FIFO for index.
    //Also send rep=1 to FIFO for state ID. Exit to substate s4rb
  s4ra:     ns <= s4rb;

    //Replay event substate s4rb: incrament counter. If Counter is >= 39,
    //then exit to idle state s1. Otherwise repeat substate s4ra. 
  s4rb:     if(count >= count_to) ns <= s1;
            else                  ns <= s4ra;
        
    //Busy_n state s5: Continue forwarding NAK/TO, assign num_to_rep from FIFO to count_to.
    //Wait busy_n to go high from physical layer (TB), then exit to s4ra.
  s5:       if(busy_n)  ns <= s4ra;
            else        ns <= s5;
       
  default:  ns <= s0;
  
  endcase
end

//Controlling what happens in each state
always @(cs)
begin
  case(cs)
        //Reset high, busy_n_o high
    s0:      {rst,we_o,to_o,rdy_o,busy_n_o,rep,acknak_o} <= 8'b10001000;
        
        //busy_n_o high, forward rdy_i to rdy_o, set count to 0
    s1:      begin
             {rst,we_o,to_o,busy_n_o,rep,acknak_o} <= 7'b0001000;
             rdy_o <= rdy_i;
             count <= 0;
             end

        //we_o high to write to FIFO buffer from mux, busy_n_o high,
        //assign count to crc_num to control the mux select
    s2:      begin
	         {rst,we_o,to_o,rdy_o,busy_n_o,rep,acknak_o} <= 8'b01001000;
             crc_num <= count;
             end   

        //busy_n_o high, +1 count to select next mux select
    s2w:     begin
	         {rst,we_o,to_o,rdy_o,busy_n_o,rep,acknak_o} <= 8'b00001000;
             count <= count + 1;
             end

        //busy_n_o high, ACK high
    s3:      {rst,we_o,to_o,rdy_o,busy_n_o,rep,acknak_o} <= 8'b00001001;
        
        //busy_n_o high, forward TO, forward NAK
    s4:      begin
             {rst,we_o,rdy_o,busy_n_o,rep} <= 5'b00010;
             to_o                      <= to_i;
             acknak_o                  <= acknak_i;
             end

        //busy_n_o high, rep high to replay from buffer using count to control FIFO index 
    s4ra:    {rst,we_o,to_o,rdy_o,busy_n_o,rep,acknak_o} <= 8'b00001100;

        //busy_n_o high, +1 count
    s4rb:    begin
             {rst,we_o,to_o,rdy_o,busy_n_o,rep,acknak_o} <= 8'b00001000;
             count = count + 1;
             end
        
        //to_o high, NAK high, assign num_to_rep to count_to for replay counter
    s5:      begin
             {rst,we_o,to_o,rdy_o,busy_n_o,rep,acknak_o} <= 8'b00100010;
             count_to                                    <= num_to_rep;
             end
        
    default: {rst,we_o,to_o,rdy_o,busy_n_o,rep,acknak_o} <= 8'b10001000;
  endcase
end

endmodule
