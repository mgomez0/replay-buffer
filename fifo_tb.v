`timescale 1ns / 1ps

module fifo_tb;

 // Inputs

 reg clk;

 reg [15:0] data_in;

 reg rd;

 reg wr;

 reg en;

 reg rst;

 // Outputs

 wire [15:0] data_out;

 wire empty;

 wire full;                                                                                                                                                                                         

 // Instantiate the Unit Under Test (UUT)

 fifo uut (.clk(clk), .data_in(data_in), .rd(rd), .wr(wr), .en(en), .data_out(data_out), .rst(rst), .empty(empty), .full(full));

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

   rd = 1'b1;  

   end 

   always #10 clk = ~clk;    

// Run simulation for 500 ns.  
   initial #500 $finish;
   
   // Dump all waveforms to d_latch.vcd
   initial
      begin
                  $dumpfile("fifo.vcd");
	$dumpvars(0, fifo_tb);	 
      end // initial begin
   
   initial 
      $monitor ($time, "ns, data_in=%H, data_out=%h, rd=%h, wr=%h, en=%h, rst=%h",data_in, data_out, rd,wr, en, rst);
   
  
   

   
endmodule
