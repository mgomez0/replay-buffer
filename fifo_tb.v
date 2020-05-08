`timescale 1ns / 1ps

module fifo_tb;

 // Inputs

 reg clk;

 reg [15:0] data_in;

 reg [1:0] rd;

 reg wr;

 reg en;

 reg rst;

 reg tim_out, rep;

 // Outputs

 wire [15:0] data_out;

 wire rdy;

 wire [11:0] num_packets_to_replay;

 wire empty;

 wire full;                                                                                                                                                                                         

 // Instantiate the Unit Under Test (UUT)

 fifo uut (clk, data_in, rd, wr, en, data_out, rst, empty, full, seq, tim_out, rdy,num_packets_to_replay, replay_index, rep);

 initial begin

  // Initialize Inputs

   clk  = 1'b0;

   data_in  = 16'h0;

   rd  = 1'b0;

   wr  = 1'b0;

   en  = 1'b0;

   rst  = 1'b1;

   // Wait 100 ns for global reset to finish

   #100;        

   // Add stimulus here

   en  = 1'b1;

   rst  = 1'b1;

   #20;

   rst  = 1'b0;

   wr  = 1'b1;

   data_in  = 16'h0;

   #20;

   data_in  = 16'h1;

   #20;

   data_in  = 16'h2;

   #20;

   data_in  = 16'h3;

   #20;

   data_in  = 16'h4;

   #20;

   wr = 1'b0;

   rd = 01'b10; //nack
   #100;

   end 

   always #10 clk = ~clk;    

// Run simulation for 500 ns.  
   initial #500 $finish;
   
   // Dump all waveforms to fifo.vcd
   initial
      begin
                  $dumpfile("fifo.vcd");
	$dumpvars(0, fifo_tb);	 
      end // initial begin
   
   initial 
      $monitor ($time, "ns, data_in=%H, data_out=%h, rd=%h, wr=%h, en=%h, rst=%h",data_in, data_out, rd,wr, en, rst);
   
  
   

   
endmodule
