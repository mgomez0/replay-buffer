module FSM(reset_n, clk, busy_n, we_i, to_i, acknak_i, rst, we_o, to_o, rdy, busy_n_o, acknak_o);
input       reset_n, clk, busy_n, we_i, to_i;
input[1:0]  acknak_i;
output      rst, we_o, to_o, rdy, busy_n_o;
output[1:0] acknak_o;
reg[2:0]    cs, ns;
reg[1:0]    acknak_o;
reg         rst, we_o, to_o, rdy, busy_n_o;

parameter s0 = 3'b000, s1 = 3'b001, s2 = 3'b010, s3 = 3'b011, s4 = 3'b100, s5 = 3'b101;

//what to do when clock or reset goes high
always @(posedge clk or posedge reset_n)
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
  s0:       ns <= s1;
       
  s1:       if(we_i)                               ns <= s2;
            else if(acknak_i == 2'b01)             ns <= s3;
            else if((acknak_i == 2'b10) || to_i)   ns <= s4;                
       
  s2:       ns <= s1;
       
  s3:       ns <= s1;
       
  s4:       ns <= s5;

  s5:       if(!busy_n) ns <= s1;
            else        ns <= s5;
       
  default:  ns <= s0;
  
  endcase
end

//Controlling what happens in each state
always @(cs)
begin
  case(cs)
    s0:      {rst,rdy,we_o,to_o,acknak_o,busy_n_o} <= 7'b1000001;
        
    s1:      {rst,rdy,we_o,to_o,acknak_o,busy_n_o} <= 7'b0100001;
    
    s2:      {rst,rdy,we_o,to_o,acknak_o,busy_n_o} <= 7'b0010001;

    s3:      {rst,rdy,we_o,to_o,acknak_o,busy_n_o} <= 7'b0000011;
        
    s4:      begin
             {rst,rdy,we_o,busy_n_o} <= 4'b0001;
             to_o                    <= to_i;
             acknak_o                <= acknak_i;
             end

    s5:      {rst,rdy,we_o,to_o,acknak_o,busy_n_o} <= 7'b0000000;
        
    default: {rst,rdy,we_o,to_o,acknak_o,busy_n_o} <= 7'b1000001;
  endcase
end

endmodule