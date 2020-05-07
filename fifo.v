`timescale 1ns / 1ps

module fifo(clk, data_in, rd, wr, en, data_out, rst, empty, full, seq, tim_out, rdy); 

input  clk, wr, en, rst, tim_out;

input [1:0] rd;

input [11:0] seq;

output  empty, full;

input   [15:0]    data_in;

output reg [15:0] data_out; // internal registers 

output reg rdy;

output reg [11:0] replay_ctr = 0;

reg [11:0]  count = 0; 

reg [15:0] FIFO [0:4095]; 

reg [11:0]      read_counter = 0, 
                write_counter = 0; 
		

assign empty = (count==0)? 1'b1:1'b0; 

assign full = (count==4096)? 1'b1:1'b0; 

always @ (posedge clk) 

begin 

if (!en); //if enable is low, do nothing

else 
	begin 
		if (rst) //reset and initialize 
			begin 
				data_out = 0;
				read_counter = 0; 
				write_counter = 0;
				rdy = 1; 
			end
		
		else if (tim_out) // timeout event will cause retraining, but will preserve state of buffer
			begin
				data_out = FIFO[seq[11:0] - 1];
				rdy = 1;
			end

		else // no reset or time-out
			begin
				if(rd == 2'b01 && count != 0 && !wr) 	// receiver sends ack, advance rd pointer past sequence number transmitted 
													 	// with DLLP to purged replay buffer of received packets
					begin
						read_counter = read_counter + seq;
						rdy = 0;
					end
				
				else if (rd ==2'b10 && count != 0 && !wr) 	// receiver sends NACK DLLP, retransmit all TLP in buffer with EARLIER
															//sequence number than seq[11:0] supplied with NACK DLLP										
					begin
						data_out = FIFO[seq[11:0] - 1];  
		 												    // not sure about this - how do I retransmit the contents of the buffer,
					end										// 16 bits at a time, for every TLP?

				else if (wr==1'b1 && count<4096) 
					
					begin
						FIFO[write_counter]  = data_in; 	// Also not sure about this - the data will have to be written in 16 bits
						write_counter  = write_counter + seq; 	// at a time.
						replay_ctr = replay_ctr + 1;
					end 

				if (write_counter == 4096) 
					write_counter = 0; 

				else if (read_counter == 4096) 
					read_counter = 0; 

				if (read_counter > write_counter) 
					count = read_counter - write_counter; 

				else if (write_counter > read_counter) 
					count = write_counter - read_counter; 
				
				if(full)
					rdy = 0;
			end
	end		
end 

endmodule