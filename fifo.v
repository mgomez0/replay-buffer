`timescale 1ns / 1ps

module fifo(clk, data_in, rd, wr, en, data_out, rst, empty, full, seq, tim_out, rdy,num_packets_to_replay, replay_index ); 

input  clk, wr, en, rst, tim_out;

input [1:0] rd;

input [11:0] seq, replay_index;

output  empty, full;

input   [15:0]    data_in;

output reg [15:0] data_out; // internal registers 

output reg rdy;

reg [11:0] last_seq_written = 0;

output reg [11:0] num_packets_to_replay;

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
		


		else // no reset or time-out
			begin
				// receiver sends ack, advance rd pointer past sequence number transmitted 
				// with DLLP to purged replay buffer of received packets
				if(rd == 2'b01 && count != 0 && !wr) 	
					begin
						read_counter = read_counter + seq;
						rdy = 0;
					end
				// receiver sends NACK DLLP, retransmit all TLP in buffer with EARLIER
				//sequence number than seq[11:0] supplied with NACK DLLP
				else if ( (tim_out || rd == 2'b10) && count != 0 && !wr ) 											
					begin
						read_counter = read_counter + (seq * 10);
						
						num_packets_to_replay = ((last_seq_written - seq)*10) -1;
					end							
				else if (rep && !wr)
					begin
						data_out = FIFO[read_counter + replay_index];
					end
				
				else if (wr==1'b1 && count<4096) 
					
					begin
						FIFO[write_counter]  = data_in; 	   
						write_counter  = write_counter + seq; 	
						last_seq_written = last_seq_written + 1;
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