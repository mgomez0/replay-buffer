`timescale 1ns / 1ps

module fifo(clk, data_in, rd, wr, en, data_out, rst, empty, full); 

input  clk, rd, wr, en, rst;

output  empty, full;

input   [15:0]    data_in;

output reg [15:0] data_out; // internal registers 

reg [11:0]  count = 0; 

reg [15:0] FIFO [0:4095]; 

reg [11:0]      read_counter = 0, 
                write_counter = 0; 

assign empty = (count==0)? 1'b1:1'b0; 

assign full = (count==4096)? 1'b1:1'b0; 

always @ (posedge clk) 

begin 

if (en==0); 

else begin 

if (rst) 
	begin 
		read_counter = 0; 
		write_counter = 0; 
	end 

else if (rd ==1'b1 && count!=0) 
	begin 
		data_out  = FIFO[read_counter]; 
   		read_counter = read_counter+1; 
  	end 

else if (wr==1'b1 && count<4096) 
	begin
   		FIFO[write_counter]  = data_in; 
   		write_counter  = write_counter+1; 
  	end 

else; 
end 

if (write_counter==4096) 
	write_counter=0; 

else if (read_counter==4096) 
	read_counter=0; 

else;

if (read_counter > write_counter) 
	begin 
  		count=read_counter-write_counter; 
	 end 

else if (write_counter > read_counter) 
	count=write_counter-read_counter; 

else;
end 
endmodule